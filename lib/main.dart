import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import 'core/config/app_config.dart';
import 'core/config/env_loader.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/di/service_locator.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/connectivity_checker.dart';
import 'core/utils/sync_manager.dart';
import 'data/local_db/app_database.dart';
import 'domain/services/session_service.dart';
import 'presentation/router/router_provider.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      'FlutterError',
      details.exception,
      details.stack ?? StackTrace.empty,
      data: {'context': details.context?.toDescription()},
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Uncaught', error, stack);
    return false;
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final env = await loadEnv(
    dotEnvAssetPath: 'assets/data/.env',
    jsonAssetPath: 'assets/data/supabase.local.json',
  );
  final config = AppConfig.fromEnv(env);

  if (!config.hasSupabase) {
    runApp(const _MissingSupabaseConfigApp());
    return;
  }

  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
  );

  final database = AppDatabase.open();
  
  final connectivityChecker = ConnectivityChecker();
  final syncManager = SyncManager(
    connectivityChecker: connectivityChecker,
    apiCall: _apiCall,
    db: database,
  );

  await setupServiceLocator(
    config: config,
    database: database,
    connectivityChecker: connectivityChecker,
    syncManager: syncManager,
  );
  await serviceLocator<SessionService>().start();
  
  runApp(
    ProviderScope(
      child: const LapiNiaApp(),
    ),
  );
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
                  'Ajoutez SUPABASE_URL et SUPABASE_ANON_KEY via `--dart-define`, ou dans `assets/data/.env`, ou dans `assets/data/supabase.local.json` (fichier local ignore).',
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

class LapiNiaApp extends HookConsumerWidget {
  const LapiNiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;

    return MaterialApp.router(
      title: 'lapiNia',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = GoogleFonts.nunitoTextTheme();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.ia,
      error: AppColors.danger,
      surface: isDark ? const Color(0xFF121212) : AppColors.white,
    );
    final themedTextTheme = baseTextTheme
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        )
        .copyWith(
          headlineLarge: GoogleFonts.poppins(textStyle: AppTypography.headline1),
          headlineMedium: GoogleFonts.poppins(textStyle: AppTypography.headline2),
          headlineSmall: GoogleFonts.poppins(textStyle: AppTypography.headline3),
          titleLarge: GoogleFonts.poppins(textStyle: AppTypography.headline3),
          titleMedium: baseTextTheme.titleMedium,
          titleSmall: baseTextTheme.titleSmall,
          bodyLarge: baseTextTheme.bodyLarge,
          bodyMedium: baseTextTheme.bodyMedium,
          bodySmall: baseTextTheme.bodySmall,
          labelLarge: baseTextTheme.labelLarge,
          labelMedium: baseTextTheme.labelMedium,
          labelSmall: baseTextTheme.labelSmall,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0F1115) : AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          textStyle: AppTypography.headline3.copyWith(color: AppColors.white),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1A1D23) : AppColors.white,
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
        fillColor: isDark ? const Color(0xFF1A1D23) : AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
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
        labelStyle: AppTypography.body2.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: AppTypography.body2.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
        ),
        helperStyle: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle: AppTypography.caption.copyWith(color: colorScheme.error),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1A1D23) : AppColors.white,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(fontWeight: FontWeight.w600);
          }
          return AppTypography.caption;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.greyMedium);
        }),
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
      textTheme: themedTextTheme,
    );
  }
}
