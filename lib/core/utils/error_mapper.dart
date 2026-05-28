import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

bool isNetworkError(Object error) {
  if (error is SocketException) return true;
  if (error is TimeoutException) return true;
  final raw = error.toString().toLowerCase();
  return raw.contains('socketexception') ||
      raw.contains('timed out') ||
      raw.contains('network') ||
      raw.contains('connection');
}

String humanizeError(Object error) {
  if (error is String) return error;

  if (isNetworkError(error)) {
    return 'Pas de connexion internet. Réessayez plus tard.';
  }

  if (error is AuthException) {
    final raw = error.message.trim();
    final lower = raw.toLowerCase();

    if (lower.contains('invalid login credentials')) {
      return 'Email ou mot de passe incorrect.';
    }

    if (lower.contains('user already registered')) {
      return 'Ce compte existe déjà. Essayez “Se connecter”.';
    }

    if (lower.contains('confirmation email')) {
      return 'Inscription impossible: Supabase n’arrive pas à envoyer l’email de confirmation (SMTP non configuré ou bloqué).';
    }

    return raw.isEmpty ? 'Erreur d’authentification.' : raw;
  }

  if (error is PostgrestException) {
    final code = (error.code ?? '').toUpperCase();
    final msg = error.message.trim();
    final lower = msg.toLowerCase();

    if (code == '42501' || lower.contains('permission') || lower.contains('rls')) {
      return 'Accès refusé. Vérifiez vos permissions.';
    }

    if (lower.contains('duplicate key') ||
        lower.contains('already exists') ||
        code.startsWith('23')) {
      return 'Conflit: cette donnée existe déjà.';
    }

    if (code == 'PGRST116' || lower.contains('not found')) {
      return 'Introuvable.';
    }

    return msg.isEmpty ? 'Erreur de base de données.' : msg;
  }

  return error.toString().trim().isEmpty ? 'Une erreur est survenue.' : error.toString();
}

