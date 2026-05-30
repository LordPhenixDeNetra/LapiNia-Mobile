import 'dart:async';

import 'package:drift/drift.dart';

import '../../data/local_db/app_database.dart';
import 'idempotency_key.dart';
import 'connectivity_checker.dart';

enum MutationType { insert, update, delete }

class SyncManager {
  final ConnectivityChecker connectivityChecker;
  final Future<dynamic> Function(
    String table,
    MutationType op,
    String payload,
    String idempotencyKey,
  ) apiCall;
  final AppDatabase db;

  bool _isSyncing = false;
  static const int _maxRetries = 5;
  static const Duration _retryDelayBase = Duration(seconds: 3);

  SyncManager({
    required this.connectivityChecker,
    required this.apiCall,
    required this.db,
  }) {
    _init();
  }

  void _init() {
    connectivityChecker.onConnectivityChanged.listen((isOnline) {
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

    await db.into(db.syncQueue).insert(
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

    if (connectivityChecker.isOnline) {
      await _processQueue(rethrowTargetId: key);
    }
  }

  Future<void> _processQueue({String? rethrowTargetId}) async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      while (connectivityChecker.isOnline) {
        final pending = await (db.select(db.syncQueue)
              ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
            .get();

        if (pending.isEmpty) return;

        for (final row in pending) {
          if (!connectivityChecker.isOnline) return;

          if (row.retryCount >= _maxRetries) {
            await (db.delete(db.syncQueue)..where((t) => t.id.equals(row.id)))
                .go();
            continue;
          }

          try {
            await apiCall(
              row.targetTable,
              MutationType.values.byName(row.operation),
              row.payload,
              row.idempotencyKey,
            );
            await (db.delete(db.syncQueue)..where((t) => t.id.equals(row.id)))
                .go();
          } catch (e) {
            final nextRetries = row.retryCount + 1;
            await (db.update(db.syncQueue)..where((t) => t.id.equals(row.id)))
                .write(
              SyncQueueCompanion(
                retryCount: Value(nextRetries),
                lastError: Value(e.toString()),
              ),
            );
            if (row.id == rethrowTargetId) {
              rethrow;
            }
            await Future.delayed(_retryDelayBase * nextRetries);
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> forceSync() async {
    if (!connectivityChecker.isOnline) {
      throw Exception('Pas de connexion internet');
    }
    await _processQueue();
  }

  Future<int> get pendingMutations async {
    final q = db.selectOnly(db.syncQueue)..addColumns([db.syncQueue.id.count()]);
    final row = await q.getSingle();
    return row.read(db.syncQueue.id.count()) ?? 0;
  }
  bool get isSyncing => _isSyncing;

  void dispose() {
  }
}
