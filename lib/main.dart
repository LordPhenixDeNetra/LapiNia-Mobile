import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/utils/connectivity_checker.dart';
import 'core/utils/sync_manager.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/lapin/lapin_bloc.dart';
import 'presentation/blocs/portee/portee_bloc.dart';
import 'presentation/blocs/alerte/alerte_bloc.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final config = await _loadSupabaseConfig();
  final supabaseUrl = config.url;
  final supabaseAnonKey = config.anonKey;

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const _MissingSupabaseConfigApp());
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  final connectivityChecker = ConnectivityChecker();
  final syncManager = SyncManager(
    connectivityChecker: connectivityChecker,
    apiCall: _apiCall,
  );
  
  runApp(LapiNiaApp(
    connectivityChecker: connectivityChecker,
    syncManager: syncManager,
  ));
}

class _SupabaseConfig {
  final String url;
  final String anonKey;

  const _SupabaseConfig({
    required this.url,
    required this.anonKey,
  });
}

Future<_SupabaseConfig> _loadSupabaseConfig() async {
  const envUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const envAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  if (envUrl.isNotEmpty && envAnonKey.isNotEmpty) {
    return const _SupabaseConfig(
      url: envUrl,
      anonKey: envAnonKey,
    );
  }

  try {
    final rawConfig = await rootBundle.loadString(
      'assets/data/supabase.local.json',
    );
    final json = jsonDecode(rawConfig) as Map<String, dynamic>;
    return _SupabaseConfig(
      url: (json['SUPABASE_URL'] as String? ?? '').trim(),
      anonKey: (json['SUPABASE_ANON_KEY'] as String? ?? '').trim(),
    );
  } catch (_) {
    return const _SupabaseConfig(url: '', anonKey: '');
  }
}

class _MissingSupabaseConfigApp extends StatelessWidget {
  const _MissingSupabaseConfigApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Configuration Supabase manquante',
                  style: AppTypography.headline1.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ajoutez SUPABASE_URL et SUPABASE_ANON_KEY soit via `--dart-define`, soit dans `assets/data/supabase.local.json` (fichier local ignore).',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textDark.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    'assets/data/supabase.local.json',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textDark,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Format du fichier JSON:',
                  style: AppTypography.label.copyWith(color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textDark.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    '{\n  "SUPABASE_URL": "https://...",\n  "SUPABASE_ANON_KEY": "..."\n}',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textDark,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ensuite, vous pouvez lancer simplement:',
                  style: AppTypography.label.copyWith(color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textDark.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    'flutter run',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textDark,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<dynamic> _apiCall(String table, MutationType op, String payload, String idempotencyKey) async {
  final supabase = Supabase.instance.client;
  final data = {'table': table, 'operation': op.name, 'payload': payload};
  
  return await supabase.functions.invoke(
    'sync',
    body: data,
    headers: {'Idempotency-Key': idempotencyKey},
  );
}

class LapiNiaApp extends StatelessWidget {
  final ConnectivityChecker connectivityChecker;
  final SyncManager syncManager;

  const LapiNiaApp({
    super.key,
    required this.connectivityChecker,
    required this.syncManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ConnectivityChecker>.value(value: connectivityChecker),
        RepositoryProvider<SyncManager>.value(value: syncManager),
        RepositoryProvider<SupabaseClient>.value(value: Supabase.instance.client),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              supabaseClient: context.read<SupabaseClient>(),
            ),
          ),
          BlocProvider<LapinBloc>(
            create: (context) => LapinBloc(
              supabaseClient: context.read<SupabaseClient>(),
              syncManager: context.read<SyncManager>(),
            ),
          ),
          BlocProvider<PorteeBloc>(
            create: (context) => PorteeBloc(
              supabaseClient: context.read<SupabaseClient>(),
            ),
          ),
          BlocProvider<AlerteBloc>(
            create: (context) => AlerteBloc(
              supabaseClient: context.read<SupabaseClient>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'lapiNia',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.ia,
        error: AppColors.danger,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headline3.copyWith(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.greyLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.greyLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTypography.body2.copyWith(color: AppColors.greyMedium),
        hintStyle: AppTypography.body2.copyWith(color: AppColors.greyMedium),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.greyMedium,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.caption,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.greyLight,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.label,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.headline1,
        headlineMedium: AppTypography.headline2,
        headlineSmall: AppTypography.headline3,
        titleLarge: AppTypography.headline3,
        titleMedium: AppTypography.subtitle1,
        titleSmall: AppTypography.subtitle2,
        bodyLarge: AppTypography.body1,
        bodyMedium: AppTypography.body2,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.label,
        labelSmall: AppTypography.caption,
      ),
    );
  }
}
