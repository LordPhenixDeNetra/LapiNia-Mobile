import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/rentability_score.dart';

class RentabilityService {
  final SupabaseClient supabase;

  RentabilityService({required this.supabase});

  Future<RentabilityScore> getScore({
    required bool isOnline,
    required String userId,
    required Map<String, dynamic> context,
    required int pendingMutations,
  }) async {
    if (!isOnline) {
      return _fallback(
        pendingMutations: pendingMutations,
        lapinsCount: context['lapins_count'] as int? ?? 0,
        gestantesCount: context['gestantes_count'] as int? ?? 0,
        porteesCount: context['portees_count'] as int? ?? 0,
      );
    }

    try {
      final res = await supabase.functions.invoke(
        'rentability-score',
        body: {'user_id': userId, ...context},
      );

      final data = res.data;
      if (data is Map<String, dynamic>) {
        final score = RentabilityScore.fromJson(data);
        if (score.actions.isNotEmpty) return score;
      } else if (data is Map) {
        final score = RentabilityScore.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (score.actions.isNotEmpty) return score;
      }
    } catch (_) {}

    return _fallback(
      pendingMutations: pendingMutations,
      lapinsCount: context['lapins_count'] as int? ?? 0,
      gestantesCount: context['gestantes_count'] as int? ?? 0,
      porteesCount: context['portees_count'] as int? ?? 0,
    );
  }

  static RentabilityScore _fallback({
    required int pendingMutations,
    required int lapinsCount,
    required int gestantesCount,
    required int porteesCount,
  }) {
    final actions = <String>[];
    var score = 60;

    if (lapinsCount <= 0) {
      score = 20;
      actions.add('Ajoutez vos premiers lapins pour suivre vos performances.');
    } else if (lapinsCount < 5) {
      score -= 10;
      actions.add('Ajoutez le reste de vos lapins pour un suivi complet.');
    }

    if (gestantesCount <= 0) {
      score -= 10;
      actions.add('Planifiez une saillie pour relancer la production.');
    }

    if (porteesCount <= 0) {
      score -= 10;
      actions.add('Enregistrez vos portées pour estimer vos lapereaux attendus.');
    }

    if (pendingMutations > 0) {
      score -= 5;
      actions.add('Synchronisez vos données pour éviter les écarts.');
    }

    if (actions.isEmpty) {
      actions.add('Suivez vos pesées régulièrement (au moins 1 fois/semaine).');
      actions.add('Anticipez les mises bas et préparez le nid à J25.');
      actions.add('Gardez vos stocks à jour pour éviter les ruptures.');
    }

    if (actions.length > 3) {
      actions.removeRange(3, actions.length);
    }

    return RentabilityScore(score: score.clamp(0, 100), actions: actions);
  }
}

