import 'dart:convert';

import 'package:flutter/services.dart';

Map<String, String> parseDotEnv(String raw) {
  final result = <String, String>{};
  final lines = raw.split(RegExp(r'\r?\n'));
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    if (trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx <= 0) continue;
    final key = trimmed.substring(0, idx).trim();
    var value = trimmed.substring(idx + 1).trim();
    if (value.length >= 2) {
      final first = value[0];
      final last = value[value.length - 1];
      if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
        value = value.substring(1, value.length - 1);
      }
    }
    if (key.isEmpty) continue;
    result[key] = value;
  }
  return result;
}

Future<Map<String, String>> loadEnv({
  required String dotEnvAssetPath,
  required String jsonAssetPath,
}) async {
  final env = <String, String>{};

  const dartDefineSupabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const dartDefineSupabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  const dartDefineAppEnv = String.fromEnvironment('APP_ENV', defaultValue: '');
  const dartDefineApiTimeout =
      String.fromEnvironment('API_TIMEOUT_MS', defaultValue: '');
  const dartDefineFunctionsEnabled = String.fromEnvironment(
    'SUPABASE_FUNCTIONS_ENABLED',
    defaultValue: '',
  );
  const dartDefineOfflineEnabled =
      String.fromEnvironment('OFFLINE_ENABLED', defaultValue: '');
  const dartDefineAiEnabled = String.fromEnvironment('AI_ENABLED', defaultValue: '');

  if (dartDefineSupabaseUrl.isNotEmpty) {
    env['SUPABASE_URL'] = dartDefineSupabaseUrl;
  }
  if (dartDefineSupabaseAnonKey.isNotEmpty) {
    env['SUPABASE_ANON_KEY'] = dartDefineSupabaseAnonKey;
  }
  if (dartDefineAppEnv.isNotEmpty) {
    env['APP_ENV'] = dartDefineAppEnv;
  }
  if (dartDefineApiTimeout.isNotEmpty) {
    env['API_TIMEOUT_MS'] = dartDefineApiTimeout;
  }
  if (dartDefineFunctionsEnabled.isNotEmpty) {
    env['SUPABASE_FUNCTIONS_ENABLED'] = dartDefineFunctionsEnabled;
  }
  if (dartDefineOfflineEnabled.isNotEmpty) {
    env['OFFLINE_ENABLED'] = dartDefineOfflineEnabled;
  }
  if (dartDefineAiEnabled.isNotEmpty) {
    env['AI_ENABLED'] = dartDefineAiEnabled;
  }

  if (env.containsKey('SUPABASE_URL') && env.containsKey('SUPABASE_ANON_KEY')) {
    return env;
  }

  try {
    final rawEnv = await rootBundle.loadString(dotEnvAssetPath);
    env.addAll(parseDotEnv(rawEnv));
  } catch (_) {}

  if (env.containsKey('SUPABASE_URL') && env.containsKey('SUPABASE_ANON_KEY')) {
    return env;
  }

  try {
    final rawConfig = await rootBundle.loadString(jsonAssetPath);
    final json = jsonDecode(rawConfig) as Map<String, dynamic>;
    for (final entry in json.entries) {
      final k = entry.key;
      final v = entry.value;
      if (v is String) {
        env[k] = v;
      }
    }
    return env;
  } catch (_) {
    return env;
  }
}

