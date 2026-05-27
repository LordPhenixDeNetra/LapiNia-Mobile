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
  
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
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
