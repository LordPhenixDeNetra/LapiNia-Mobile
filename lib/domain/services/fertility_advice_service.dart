import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class FertilityAdviceService {
  final SupabaseClient supabase;

  FertilityAdviceService({required this.supabase});

  Future<List<String>> getRecommendations({
    required String lapinId,
    required int scoreNow,
    int? scoreBefore,
    String? context,
  }) async {
    final res = await supabase.functions.invoke(
      'fertility-advice',
      body: {
        'lapinId': lapinId,
        'scoreNow': scoreNow,
        'scoreBefore': scoreBefore,
        'context': context,
      },
    );

    final data = res.data;
    final decoded = data is String ? jsonDecode(data) : data;
    if (decoded is! Map) {
      throw Exception('Invalid fertility-advice response');
    }

    final map = Map<String, dynamic>.from(decoded);
    final raw = map['recommendations'];
    if (raw is List) {
      return raw.whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }
}

