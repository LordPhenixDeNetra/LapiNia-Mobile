import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../utils/connectivity_checker.dart';
import '../utils/sync_manager.dart';
import '../../data/local_db/app_database.dart';
import '../../data/local_db/local_cache_service.dart';
import '../../domain/services/onboarding_profile_service.dart';
import '../../domain/services/onboarding_service.dart';
import '../../domain/services/session_service.dart';
import '../../domain/services/theme_service.dart';
import '../../domain/services/file_share_service.dart';
import '../../domain/services/daily_advice_service.dart';
import '../../domain/services/planned_events_service.dart';
import '../../domain/services/rentability_service.dart';
import '../../domain/services/lapin_photo_service.dart';
import '../../domain/services/growth_prediction_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator({
  required AppConfig config,
  required AppDatabase database,
  required ConnectivityChecker connectivityChecker,
  required SyncManager syncManager,
}) async {
  if (serviceLocator.isRegistered<AppConfig>()) {
    return;
  }

  serviceLocator.registerSingleton<AppConfig>(config);
  serviceLocator.registerSingleton<SupabaseClient>(Supabase.instance.client);
  serviceLocator.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(),
  );
  serviceLocator.registerSingleton<AppDatabase>(database);
  serviceLocator.registerSingleton<LocalCacheService>(
    LocalCacheService(db: database),
  );
  serviceLocator.registerSingleton<ConnectivityChecker>(connectivityChecker);
  serviceLocator.registerSingleton<SyncManager>(syncManager);
  serviceLocator.registerSingleton<SessionService>(
    SessionService(
      supabase: serviceLocator<SupabaseClient>(),
      storage: serviceLocator<FlutterSecureStorage>(),
    ),
  );
  serviceLocator.registerSingleton<OnboardingService>(OnboardingService());
  serviceLocator.registerSingleton<OnboardingProfileService>(
    OnboardingProfileService(),
  );
  serviceLocator.registerSingleton<ThemeService>(ThemeService());
  serviceLocator.registerSingleton<FileShareService>(FileShareService());
  serviceLocator.registerSingleton<DailyAdviceService>(
    DailyAdviceService(
      db: serviceLocator<AppDatabase>(),
      supabase: serviceLocator<SupabaseClient>(),
    ),
  );
  serviceLocator.registerSingleton<PlannedEventsService>(
    PlannedEventsService(db: serviceLocator<AppDatabase>()),
  );
  serviceLocator.registerSingleton<RentabilityService>(
    RentabilityService(supabase: serviceLocator<SupabaseClient>()),
  );
  serviceLocator.registerSingleton<LapinPhotoService>(
    LapinPhotoService(
      supabase: serviceLocator<SupabaseClient>(),
      config: serviceLocator<AppConfig>(),
    ),
  );
  serviceLocator.registerSingleton<GrowthPredictionService>(
    GrowthPredictionService(supabase: serviceLocator<SupabaseClient>()),
  );
}
