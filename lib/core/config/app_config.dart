enum AppEnvironment { dev, staging, prod }

class AppConfig {
  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final int apiTimeoutMs;
  final bool supabaseFunctionsEnabled;
  final bool offlineEnabled;
  final bool aiEnabled;

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.apiTimeoutMs,
    required this.supabaseFunctionsEnabled,
    required this.offlineEnabled,
    required this.aiEnabled,
  });

  static AppEnvironment parseEnvironment(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'dev':
      case 'development':
        return AppEnvironment.dev;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      default:
        return AppEnvironment.prod;
    }
  }

  static bool parseBool(String raw, {required bool defaultValue}) {
    final v = raw.trim().toLowerCase();
    if (v.isEmpty) return defaultValue;
    if (v == '1' || v == 'true' || v == 'yes' || v == 'y') return true;
    if (v == '0' || v == 'false' || v == 'no' || v == 'n') return false;
    return defaultValue;
  }

  static int parseInt(String raw, {required int defaultValue}) {
    final parsed = int.tryParse(raw.trim());
    return parsed ?? defaultValue;
  }

  factory AppConfig.fromEnv(Map<String, String> env) {
    final environment = parseEnvironment(env['APP_ENV'] ?? '');

    final apiTimeoutMs = parseInt(
      env['API_TIMEOUT_MS'] ?? '',
      defaultValue: 20000,
    );

    final supabaseFunctionsEnabled = parseBool(
      env['SUPABASE_FUNCTIONS_ENABLED'] ?? '',
      defaultValue: true,
    );

    final offlineEnabled = parseBool(
      env['OFFLINE_ENABLED'] ?? '',
      defaultValue: true,
    );

    final aiEnabled = parseBool(
      env['AI_ENABLED'] ?? '',
      defaultValue: true,
    );

    return AppConfig(
      environment: environment,
      supabaseUrl: (env['SUPABASE_URL'] ?? '').trim(),
      supabaseAnonKey: (env['SUPABASE_ANON_KEY'] ?? '').trim(),
      apiTimeoutMs: apiTimeoutMs,
      supabaseFunctionsEnabled: supabaseFunctionsEnabled,
      offlineEnabled: offlineEnabled,
      aiEnabled: aiEnabled,
    );
  }

  bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

