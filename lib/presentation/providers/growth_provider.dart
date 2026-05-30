import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/models/growth_prediction.dart';
import 'core_providers.dart';
import 'lapin_provider.dart';

final growthPredictionProvider =
    FutureProvider.family<GrowthPrediction, String>((ref, lapinId) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  final lapin = await ref.watch(lapinDetailProvider(lapinId).future);
  final raceId = lapin.raceId;
  final poids = lapin.poidsActuelG;
  final ageJours = lapin.ageJours;
  if (raceId == null || poids == null || ageJours == null) {
    throw Exception('Missing lapin data for prediction');
  }

  return ref.read(growthPredictionServiceProvider).predictGrowth(
        userId: userId,
        raceId: raceId,
        poidsActuelG: poids,
        ageJours: ageJours,
      );
});

