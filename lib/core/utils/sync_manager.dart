import 'dart:async';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'idempotency_key.dart';
import 'connectivity_checker.dart';

enum MutationType { insert, update, delete }

class PendingMutation {
  final String id;
  final String tableName;
  final MutationType operation;
  final String payload;
  final String idempotencyKey;
  final DateTime createdAt;

  PendingMutation({
    required this.id,
    required this.tableName,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    required this.createdAt,
  });
}

class SyncManager {
  final ConnectivityChecker _connectivityChecker;
  final Future<dynamic> Function(String table, MutationType op, String payload, String idempotencyKey) _apiCall;
  
  final List<PendingMutation> _queue = [];
  bool _isSyncing = false;
  Timer? _retryTimer;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  SyncManager({
    required ConnectivityChecker connectivityChecker,
    required Future<dynamic> Function(String table, MutationType op, String payload, String idempotencyKey) apiCall,
  }) : _connectivityChecker = connectivityChecker,
       _apiCall = apiCall {
    _init();
  }

  void _init() {
    _connectivityChecker.onConnectivityChanged.listen((isOnline) {
      if (isOnline && !_isSyncing) {
        _processQueue();
      }
    });
  }

  Future<void> addMutation({
    required String tableName,
    required MutationType operation,
    required String payload,
  }) async {
    final mutation = PendingMutation(
      id: IdempotencyKey.generate(),
      tableName: tableName,
      operation: operation,
      payload: payload,
      idempotencyKey: IdempotencyKey.generate(),
      createdAt: DateTime.now(),
    );
    
    _queue.add(mutation);
    
    if (_connectivityChecker.isOnline) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_isSyncing || _queue.isEmpty) return;
    
    _isSyncing = true;
    
    while (_queue.isNotEmpty && _connectivityChecker.isOnline) {
      final mutation = _queue.first;
      int retries = 0;
      
      while (retries < _maxRetries) {
        try {
          await _apiCall(
            mutation.tableName,
            mutation.operation,
            mutation.payload,
            mutation.idempotencyKey,
          );
          _queue.removeAt(0);
          break;
        } catch (e) {
          retries++;
          if (retries >= _maxRetries) {
            _queue.removeAt(0);
            break;
          }
          await Future.delayed(_retryDelay * retries);
        }
      }
    }
    
    _isSyncing = false;
  }

  Future<void> forceSync() async {
    if (!_connectivityChecker.isOnline) {
      throw Exception('Pas de connexion internet');
    }
    await _processQueue();
  }

  int get pendingMutations => _queue.length;
  bool get isSyncing => _isSyncing;

  void dispose() {
    _retryTimer?.cancel();
  }
}

abstract class Disposable {
  Future<void> dispose();
}

class LocalDatabase implements Disposable {
  late LazyDatabase _db;

  LocalDatabase() {
    _db = LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(
        '${dbFolder.path}${Platform.pathSeparator}lapinia_local.sqlite',
      );
      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  Future<void> dispose() async {
    await _db.close();
  }
}
