import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local_db/app_database.dart';

class DailyAdviceService {
  final AppDatabase db;
  final SupabaseClient supabase;

  DailyAdviceService({
    required this.db,
    required this.supabase,
  });

  Future<String?> getAdvice({
    required String userId,
    required Map<String, dynamic> context,
  }) async {
    final now = DateTime.now();
    final cacheId = _cacheId(userId, now);

    final cached = await (db.select(db.dailyAdviceCache)
          ..where((t) => t.id.equals(cacheId)))
        .getSingleOrNull();

    if (cached != null && now.difference(cached.cachedAt) <= const Duration(hours: 24)) {
      final content = cached.content.trim();
      if (content.isNotEmpty) return content;
    }

    try {
      final res = await supabase.functions.invoke(
        'daily-advice',
        body: context,
      );
      final message = _parseAdvice(res.data);
      if (message == null) return cached?.content;

      await db.into(db.dailyAdviceCache).insert(
            DailyAdviceCacheCompanion.insert(
              id: cacheId,
              userId: userId,
              content: message,
              cachedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
      return message;
    } catch (_) {
      return cached?.content;
    }
  }

  static String _cacheId(String userId, DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$userId-$y$m$d';
  }

  static String? _parseAdvice(dynamic data) {
    if (data is String) {
      final text = data.trim();
      return text.isEmpty ? null : text;
    }
    if (data is Map) {
      final message = data['advice'] ?? data['message'] ?? data['content'];
      if (message is String) {
        final text = message.trim();
        return text.isEmpty ? null : text;
      }
    }
    return null;
  }
}
