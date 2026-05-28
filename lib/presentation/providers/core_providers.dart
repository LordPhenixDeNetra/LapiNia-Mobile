import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/connectivity_checker.dart';
import '../../core/utils/sync_manager.dart';
import '../../data/local_db/app_database.dart';
import '../../data/local_db/local_cache_service.dart';
import '../../domain/services/file_share_service.dart';
import '../../domain/services/onboarding_service.dart';
import '../../domain/services/session_service.dart';
import '../../domain/services/theme_service.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return serviceLocator<AppConfig>();
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return serviceLocator<SupabaseClient>();
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  return serviceLocator<SessionService>();
});

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return serviceLocator<OnboardingService>();
});

final themeServiceProvider = Provider<ThemeService>((ref) {
  return serviceLocator<ThemeService>();
});

final fileShareServiceProvider = Provider<FileShareService>((ref) {
  return serviceLocator<FileShareService>();
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return serviceLocator<AppDatabase>();
});

final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  return serviceLocator<LocalCacheService>();
});

final connectivityCheckerProvider = Provider<ConnectivityChecker>((ref) {
  return serviceLocator<ConnectivityChecker>();
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  return serviceLocator<SyncManager>();
});
