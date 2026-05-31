import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/male_suggestion.dart';

class SuggestMalesService {
  final SupabaseClient supabase;

  SuggestMalesService({required this.supabase});

  Future<MaleSuggestionResult> suggest({
    required String femelleId,
    required MaleSuggestionObjective objective,
  }) async {
    final res = await supabase.functions.invoke(
      'suggest-males',
      body: {
        'femelleId': femelleId,
        'objectif': objective.apiValue,
      },
    );

    final data = res.data;
    final decoded = data is String ? jsonDecode(data) : data;
    if (decoded is Map) {
      return MaleSuggestionResult.fromJson(Map<String, dynamic>.from(decoded));
    }
    throw Exception('Invalid suggest-males response');
  }
}

