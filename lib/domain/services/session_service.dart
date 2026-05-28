import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionService {
  static const _kRefreshToken = 'supabase_refresh_token';
  static const _readTimeout = Duration(seconds: 2);
  static const _setSessionTimeout = Duration(seconds: 6);

  final SupabaseClient supabase;
  final FlutterSecureStorage storage;

  StreamSubscription<AuthState>? _sub;

  SessionService({
    required this.supabase,
    required this.storage,
  });

  Future<void> start() async {
    _sub?.cancel();
    _sub = supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session == null) {
        await storage.delete(key: _kRefreshToken);
        return;
      }
      final refreshToken = session.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await storage.write(key: _kRefreshToken, value: refreshToken);
      }
    });
  }

  Future<bool> restore() async {
    final refreshToken = await storage.read(key: _kRefreshToken).timeout(_readTimeout);
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      return false;
    }

    try {
      await supabase.auth.setSession(refreshToken.trim()).timeout(_setSessionTimeout);
      return supabase.auth.currentSession != null;
    } catch (_) {
      await storage.delete(key: _kRefreshToken);
      return false;
    }
  }

  Future<void> clear() async {
    await storage.delete(key: _kRefreshToken);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
