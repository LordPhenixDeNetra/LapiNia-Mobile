import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/models/pesel.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/utils/idempotency_key.dart';
import '../../core/utils/sync_manager.dart';
import 'core_providers.dart';
import 'lapin_provider.dart';

class PeseesListState {
  final List<Pesee> items;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final int offset;

  const PeseesListState({
    this.items = const [],
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.offset = 0,
  });

  PeseesListState copyWith({
    List<Pesee>? items,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    int? offset,
    bool resetOffset = false,
  }) {
    return PeseesListState(
      items: items ?? this.items,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: resetOffset ? 0 : (offset ?? this.offset),
    );
  }
}

class PeseesController extends AsyncNotifier<PeseesListState> {
  static const int _pageSize = 50;

  final String lapinId;

  PeseesController(this.lapinId);

  @override
  FutureOr<PeseesListState> build() async {
    final items = await _loadPage(offset: 0);
    return PeseesListState(
      items: items,
      hasMore: items.length == _pageSize,
      offset: 0,
    );
  }

  Future<List<Pesee>> _loadPage({required int offset}) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return const [];

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);

    if (!connectivity.isOnline) {
      final all = await cache.getPeseesByLapin(userId: userId, lapinId: lapinId);
      return all.skip(offset).take(_pageSize).toList();
    }

    try {
      final response = await supabase
          .from('pesees')
          .select('*, lapins(*)')
          .eq('lapin_id', lapinId)
          .order('date', ascending: false)
          .range(offset, offset + _pageSize - 1);
      final page = (response as List).map((e) => Pesee.fromJson(e)).toList();
      if (offset == 0) {
        await cache.cachePesees(userId: userId, lapinId: lapinId, pesees: page);
      } else {
        for (final p in page) {
          await cache.upsertPesee(p);
        }
      }
      return page;
    } catch (e) {
      await connectivity.checkConnectivity();
      if (!connectivity.isOnline) {
        final all = await cache.getPeseesByLapin(userId: userId, lapinId: lapinId);
        return all.skip(offset).take(_pageSize).toList();
      }
      throw humanizeError(e);
    }
  }

  Future<void> refresh() async {
    final current = state.asData?.value ?? const PeseesListState();
    state = AsyncValue.data(current.copyWith(isRefreshing: true, resetOffset: true));
    state = await AsyncValue.guard(() async {
      final items = await _loadPage(offset: 0);
      return PeseesListState(
        items: items,
        hasMore: items.length == _pageSize,
        offset: 0,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.asData?.value ?? const PeseesListState();
    if (!current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final nextOffset = current.items.length;
      final page = await _loadPage(offset: nextOffset);
      final merged = [
        ...current.items,
        ...page.where((p) => current.items.every((e) => e.id != p.id)),
      ];
      state = AsyncValue.data(
        current.copyWith(
          items: merged,
          isLoadingMore: false,
          hasMore: page.length == _pageSize,
          offset: nextOffset,
        ),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Pesee> addPesee({
    required int poidsG,
    required DateTime date,
    String? notes,
    int? gmqTargetG,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final id = IdempotencyKey.generate();
    final createdAt = DateTime.now();
    final temp = Pesee(
      id: id,
      lapinId: lapinId,
      userId: userId,
      date: DateTime(date.year, date.month, date.day),
      poidsG: poidsG,
      notes: notes?.trim().isEmpty ?? true ? null : notes?.trim(),
      createdAt: createdAt,
    );

    double? gmq;
    int? deltaDays;
    final current = state.asData?.value ?? const PeseesListState();
    final asc = [...current.items, temp]..sort((a, b) {
      final c = a.date.compareTo(b.date);
      if (c != 0) return c;
      return a.createdAt.compareTo(b.createdAt);
    });
    final idx = asc.indexWhere((p) => p.id == id);
    if (idx > 0) {
      final prev = asc[idx - 1];
      final days = temp.date.difference(prev.date).inDays;
      deltaDays = days <= 0 ? 1 : days;
      gmq = (temp.poidsG - prev.poidsG) / deltaDays;
    }

    final pesee = temp.copyWith(gmqDepuisDerniere: gmq);

    state = AsyncValue.data(
      current.copyWith(
        items: [pesee, ...current.items.where((p) => p.id != id)],
      ),
    );
    await cache.upsertPesee(pesee);

    await ref.read(lapinsProvider.notifier).setLapinPoidsOptimistic(
          lapinId: lapinId,
          poidsActuelG: poidsG,
        );

    await syncManager.addMutation(
      tableName: 'pesees',
      operation: MutationType.insert,
      payload: jsonEncode({
        'id': id,
        'lapin_id': lapinId,
        'user_id': userId,
        'date': pesee.date.toIso8601String().split('T')[0],
        'poids_g': poidsG,
        'gmq_depuis_derniere': gmq,
        'notes': pesee.notes,
        'created_at': createdAt.toIso8601String(),
      }),
    );

    await syncManager.addMutation(
      tableName: 'lapins',
      operation: MutationType.update,
      payload: jsonEncode({
        'id': lapinId,
        'user_id': userId,
        'poids_actuel_g': poidsG,
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );

    if (gmqTargetG != null &&
        gmq != null &&
        deltaDays != null &&
        deltaDays >= 7 &&
        gmq < gmqTargetG * 0.8) {
      await _createLowGmqAlert(
        connectivity: connectivity,
        syncManager: syncManager,
        userId: userId,
        gmq: gmq,
        gmqTargetG: gmqTargetG,
      );
    }

    return pesee;
  }

  Future<void> _createLowGmqAlert({
    required dynamic connectivity,
    required SyncManager syncManager,
    required String userId,
    required double gmq,
    required int gmqTargetG,
  }) async {
    final now = DateTime.now();
    if (connectivity.isOnline) {
      try {
        final supabase = ref.read(supabaseClientProvider);
        final existing = await supabase
            .from('alertes')
            .select('id')
            .eq('user_id', userId)
            .eq('lapin_id', lapinId)
            .eq('type', 'PESEE')
            .eq('lue', false)
            .order('created_at', ascending: false)
            .limit(1);
        if (existing.isNotEmpty) return;
      } catch (_) {}
    }

    await syncManager.addMutation(
      tableName: 'alertes',
      operation: MutationType.insert,
      payload: jsonEncode({
        'id': IdempotencyKey.generate(),
        'user_id': userId,
        'lapin_id': lapinId,
        'type': 'PESEE',
        'message':
            'GMQ faible (${gmq.toStringAsFixed(1)} g/j) vs cible ($gmqTargetG g/j).',
        'priorite': 2,
        'date_echeance': now.toIso8601String(),
        'created_at': now.toIso8601String(),
      }),
    );
  }
}

final peseesProvider = AsyncNotifierProvider.family<PeseesController, PeseesListState, String>(
  (lapinId) => PeseesController(lapinId),
);
