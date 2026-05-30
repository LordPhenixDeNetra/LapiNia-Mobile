import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/race_recommendation.dart';

class RaceRecommendationNotConfiguredException implements Exception {
  const RaceRecommendationNotConfiguredException();
}

class RaceRecommendationService {
  final SupabaseClient supabase;

  RaceRecommendationService({required this.supabase});

  Future<RaceRecommendationResult> recommend(
    RaceRecommendationRequest request,
  ) async {
    final res = await supabase.functions.invoke(
      'recommend-race',
      body: request.toJson(),
    );

    if (res.status == 501) {
      throw const RaceRecommendationNotConfiguredException();
    }

    final data = res.data;
    if (data is Map) {
      return RaceRecommendationResult.fromJson(Map<String, dynamic>.from(data));
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return RaceRecommendationResult.fromJson(Map<String, dynamic>.from(decoded));
      }
    }
    throw Exception('Invalid recommend-race response');
  }
}

