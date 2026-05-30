import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/consanguinity.dart';

class ConsanguinityService {
  final SupabaseClient supabase;

  ConsanguinityService({required this.supabase});

  Future<ConsanguinityResult> check({
    required String mereId,
    required String pereId,
  }) async {
    final res = await supabase.functions.invoke(
      'consanguinity-check',
      body: {
        'mereId': mereId,
        'pereId': pereId,
      },
    );

    final data = res.data;
    if (data is Map) {
      return ConsanguinityResult.fromJson(Map<String, dynamic>.from(data));
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return ConsanguinityResult.fromJson(Map<String, dynamic>.from(decoded));
      }
    }
    throw Exception('Invalid consanguinity-check response');
  }
}

