import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/growth_prediction.dart';

class GrowthPredictionService {
  final SupabaseClient supabase;

  GrowthPredictionService({required this.supabase});

  Future<GrowthPrediction> predictGrowth({
    required String userId,
    required String raceId,
    required int poidsActuelG,
    required int ageJours,
  }) async {
    final res = await supabase.functions.invoke(
      'predict-growth',
      body: {
        'userId': userId,
        'raceId': raceId,
        'poidsActuelG': poidsActuelG,
        'ageJours': ageJours,
      },
    );

    final data = res.data;
    if (data is Map) {
      return GrowthPrediction.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Invalid prediction response');
  }
}

