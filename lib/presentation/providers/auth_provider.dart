import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core_providers.dart';

final authUserProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final controller = StreamController<User?>(sync: true);

  controller.add(supabase.auth.currentUser);

  final sub = supabase.auth.onAuthStateChange.listen((data) {
    controller.add(data.session?.user);
  });

  ref.onDispose(() async {
    await sub.cancel();
    await controller.close();
  });

  return controller.stream.distinct((a, b) => a?.id == b?.id);
});

class AuthController extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    final sub = supabase.auth.onAuthStateChange.listen((data) {
      state = AsyncValue.data(data.session?.user);
    });
    ref.onDispose(sub.cancel);
    return supabase.auth.currentUser;
  }

  SupabaseClient get _supabase => ref.read(supabaseClientProvider);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    });
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
      return response;
    } on AuthException catch (e) {
      state = AsyncValue.error(_humanizeAuthError(e), StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await _supabase.auth.signOut();
    await ref.read(sessionServiceProvider).clear();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);

String _humanizeAuthError(AuthException e) {
  final raw = e.message.trim();
  final lower = raw.toLowerCase();

  if (lower.contains('error sending confirmation email') ||
      lower.contains('confirmation email')) {
    return 'Inscription impossible: Supabase n’arrive pas à envoyer l’email de confirmation (SMTP non configuré ou bloqué).';
  }

  if (lower.contains('invalid login credentials')) {
    return 'Email ou mot de passe incorrect.';
  }

  if (lower.contains('user already registered')) {
    return 'Ce compte existe déjà. Essayez “Se connecter”.';
  }

  return raw.isEmpty ? 'Erreur d’authentification.' : raw;
}
