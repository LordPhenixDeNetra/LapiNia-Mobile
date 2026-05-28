import 'dart:async';

import 'package:drift/drift.dart';

import '../../data/local_db/app_database.dart';
import 'idempotency_key.dart';
import 'connectivity_checker.dart';

enum MutationType { insert, update, delete }

class SyncManager {
  final ConnectivityChecker _connectivityChecker;
  final Future<dynamic> Function(
    String table,
    MutationType op,
    String payload,
    String idempotencyKey,
  ) _apiCall;
  final AppDatabase _db;

  bool _isSyncing = false;
  static const int _maxRetries = 5;
  static const Duration _retryDelayBase = Duration(seconds: 3);

  SyncManager({
    required ConnectivityChecker connectivityChecker,
    required Future<dynamic> Function(
      String table,
      MutationType op,
      String payload,
      String idempotencyKey,
    ) apiCall,
    required AppDatabase database,
  }) : _connectivityChecker = connectivityChecker,
       _apiCall = apiCall,
       _db = database {
    _init();
  }

  void _init() {
    _connectivityChecker.onConnectivityChanged.listen((isOnline) {
      if (isOnline && !_isSyncing) {
        unawaited(_processQueue());
      }
    });
  }

  Future<void> addMutation({
    required String tableName,
    required MutationType operation,
    required String payload,
  }) async {
    final key = IdempotencyKey.generate();

    await _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            id: key,
            targetTable: tableName,
            operation: operation.name,
            payload: payload,
            idempotencyKey: key,
            createdAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );

    if (_connectivityChecker.isOnline) {
      await _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      while (_connectivityChecker.isOnline) {
        final pending = await (_db.select(_db.syncQueue)
              ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
            .get();

        if (pending.isEmpty) return;

        for (final row in pending) {
          if (!_connectivityChecker.isOnline) return;

          if (row.retryCount >= _maxRetries) {
            await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(row.id)))
                .go();
            continue;
          }

          try {
            await _apiCall(
              row.targetTable,
              MutationType.values.byName(row.operation),
              row.payload,
              row.idempotencyKey,
            );
            await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(row.id)))
                .go();
          } catch (e) {
            final nextRetries = row.retryCount + 1;
            await (_db.update(_db.syncQueue)..where((t) => t.id.equals(row.id)))
                .write(
              SyncQueueCompanion(
                retryCount: Value(nextRetries),
                lastError: Value(e.toString()),
              ),
            );
            await Future.delayed(_retryDelayBase * nextRetries);
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> forceSync() async {
    if (!_connectivityChecker.isOnline) {
      throw Exception('Pas de connexion internet');
    }
    await _processQueue();
  }

  Future<int> get pendingMutations async {
    final q = _db.selectOnly(_db.syncQueue)..addColumns([_db.syncQueue.id.count()]);
    final row = await q.getSingle();
    return row.read(_db.syncQueue.id.count()) ?? 0;
  }
  bool get isSyncing => _isSyncing;

  void dispose() {
  }
}
