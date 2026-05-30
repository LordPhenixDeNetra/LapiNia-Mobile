import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/models/lapereau.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/utils/sync_manager.dart';
import 'core_providers.dart';

class LapereauxController extends AsyncNotifier<List<Lapereau>> {
  final String porteeId;

  LapereauxController(this.porteeId);

  @override
  FutureOr<List<Lapereau>> build() async {
    return _load();
  }

  Future<List<Lapereau>> _load() async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return const [];

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);

    if (!connectivity.isOnline) {
      return cache.getLapereaux(userId: userId, porteeId: porteeId);
    }

    try {
      final response = await supabase
          .from('lapereaux')
          .select('*, lapins(*)')
          .eq('user_id', userId)
          .eq('portee_id', porteeId)
          .order('created_at', ascending: true);

      final items = (response as List).map((e) => Lapereau.fromJson(e)).toList();
      await cache.cacheLapereaux(userId: userId, porteeId: porteeId, lapereaux: items);
      return items;
    } catch (e) {
      await connectivity.checkConnectivity();
      if (!connectivity.isOnline) {
        return cache.getLapereaux(userId: userId, porteeId: porteeId);
      }
      throw humanizeError(e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> createBatch(List<Lapereau> lapereaux) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final current = state.asData?.value ?? const [];
    final next = [...current, ...lapereaux];
    state = AsyncValue.data(next);

    for (final l in lapereaux) {
      await cache.upsertLapereau(l);
      await syncManager.addMutation(
        tableName: 'lapereaux',
        operation: MutationType.insert,
        payload: jsonEncode(l.toJson()),
      );
    }

    if (connectivity.isOnline) {
      unawaited(refresh());
    }
  }

  Future<void> updateLapereau(Lapereau lapereau) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final current = state.asData?.value ?? const [];
    state = AsyncValue.data([
      for (final l in current) if (l.id == lapereau.id) lapereau else l,
    ]);
    await cache.upsertLapereau(lapereau);

    final data = lapereau.toJson();
    data['user_id'] = userId;

    await syncManager.addMutation(
      tableName: 'lapereaux',
      operation: MutationType.update,
      payload: jsonEncode(data),
    );

    if (connectivity.isOnline) {
      unawaited(refresh());
    }
  }
}

final lapereauxProvider = AsyncNotifierProvider.family<LapereauxController, List<Lapereau>, String>(
  (porteeId) => LapereauxController(porteeId),
);

