import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient supabaseClient;

  AuthBloc({required this.supabaseClient}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthEmailPasswordSignInRequested>(_onEmailPasswordSignInRequested);
    on<AuthEmailPasswordSignUpRequested>(_onEmailPasswordSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserProfileUpdated>(_onUserProfileUpdated);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final session = supabaseClient.auth.currentSession;
      if (session != null) {
        final user = supabaseClient.auth.currentUser;
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onEmailPasswordSignInRequested(
    AuthEmailPasswordSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      final user = response.user;
      if (user == null) {
        emit(const AuthError(message: 'Connexion echouee'));
        return;
      }
      emit(AuthAuthenticated(user: user));
    } on AuthException catch (e) {
      emit(AuthError(message: _humanizeAuthError(e)));
    } catch (e) {
      emit(AuthError(message: 'Erreur: ${e.toString()}'));
    }
  }

  Future<void> _onEmailPasswordSignUpRequested(
    AuthEmailPasswordSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
      );
      final user = response.user;
      final session = response.session;
      if (user == null) {
        emit(const AuthError(message: 'Creation de compte echouee'));
        return;
      }
      if (session == null) {
        emit(AuthEmailConfirmationRequired(email: event.email));
        return;
      }
      emit(AuthAuthenticated(user: user));
    } on AuthException catch (e) {
      emit(AuthError(message: _humanizeAuthError(e)));
    } catch (e) {
      emit(AuthError(message: 'Erreur: ${e.toString()}'));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await supabaseClient.auth.signOut();
      emit(AuthUnauthenticated());
    } on AuthException catch (e) {
      emit(AuthError(message: _humanizeAuthError(e)));
    } catch (e) {
      emit(AuthError(message: 'Erreur: ${e.toString()}'));
    }
  }

  Future<void> _onUserProfileUpdated(
    AuthUserProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      emit(AuthAuthenticated(user: currentState.user));
    }
  }

  String _humanizeAuthError(AuthException e) {
    final raw = e.message.trim();
    final lower = raw.toLowerCase();

    if (lower.contains('error sending confirmation email') ||
        lower.contains('confirmation email')) {
      return 'Inscription impossible: Supabase n’arrive pas à envoyer l’email de confirmation (SMTP non configuré ou bloqué). Solution: configurer SMTP sur le serveur Supabase, ou désactiver la confirmation email (auto-confirm).';
    }

    if (lower.contains('invalid login credentials')) {
      return 'Email ou mot de passe incorrect.';
    }

    if (lower.contains('user already registered')) {
      return 'Ce compte existe déjà. Essayez “Se connecter”.';
    }

    return raw.isEmpty ? 'Erreur d’authentification.' : raw;
  }
}
