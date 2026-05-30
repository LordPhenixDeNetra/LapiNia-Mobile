import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/models/lapin.dart';
import '../../core/models/race.dart';
import '../../core/utils/idempotency_key.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/utils/sync_manager.dart';
import 'core_providers.dart';

class LapinOfflineNotFoundException implements Exception {
  const LapinOfflineNotFoundException();
}

class RacesOfflineNotFoundException implements Exception {
  const RacesOfflineNotFoundException();
}

class LapinsListState {
  final List<Lapin> items;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final String? lastNom;
  final String? lastId;
  final StatutLapin? statut;
  final SexeLapin? sexe;
  final String? raceId;

  const LapinsListState({
    this.items = const [],
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.lastNom,
    this.lastId,
    this.statut,
    this.sexe,
    this.raceId,
  });

  LapinsListState copyWith({
    List<Lapin>? items,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    String? lastNom,
    String? lastId,
    StatutLapin? statut,
    SexeLapin? sexe,
    String? raceId,
    bool clearCursor = false,
  }) {
    return LapinsListState(
      items: items ?? this.items,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastNom: clearCursor ? null : (lastNom ?? this.lastNom),
      lastId: clearCursor ? null : (lastId ?? this.lastId),
      statut: statut ?? this.statut,
      sexe: sexe ?? this.sexe,
      raceId: raceId ?? this.raceId,
    );
  }
}

class LapinsController extends AsyncNotifier<LapinsListState> {
  static const int _pageSize = 20;

  @override
  FutureOr<LapinsListState> build() async {
    final items = await _loadFirstPage(
      statut: null,
      sexe: null,
      raceId: null,
    );
    return items;
  }

  Future<LapinsListState> _loadFirstPage({
    required StatutLapin? statut,
    required SexeLapin? sexe,
    required String? raceId,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return LapinsListState(
        items: const [],
        hasMore: false,
        statut: statut,
        sexe: sexe,
        raceId: raceId,
      );
    }

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);

    if (!connectivity.isOnline) {
      final all = await cache.getLapins(userId: userId);
      final page = _offlinePage(
        all: all,
        statut: statut,
        sexe: sexe,
        raceId: raceId,
        afterNom: null,
        afterId: null,
      );
      return LapinsListState(
        items: page,
        hasMore: page.length == _pageSize,
        lastNom: page.isNotEmpty ? page.last.nom : null,
        lastId: page.isNotEmpty ? page.last.id : null,
        statut: statut,
        sexe: sexe,
        raceId: raceId,
      );
    }

    try {
      final page = await _fetchOnlinePage(
        userId: userId,
        statut: statut,
        sexe: sexe,
        raceId: raceId,
        afterNom: null,
        afterId: null,
      );
      await cache.cacheLapins(userId: userId, lapins: page);
      return LapinsListState(
        items: page,
        hasMore: page.length == _pageSize,
        lastNom: page.isNotEmpty ? page.last.nom : null,
        lastId: page.isNotEmpty ? page.last.id : null,
        statut: statut,
        sexe: sexe,
        raceId: raceId,
      );
    } catch (e) {
      await connectivity.checkConnectivity();
      if (!connectivity.isOnline) {
        final all = await cache.getLapins(userId: userId);
        final page = _offlinePage(
          all: all,
          statut: statut,
          sexe: sexe,
          raceId: raceId,
          afterNom: null,
          afterId: null,
        );
        return LapinsListState(
          items: page,
          hasMore: page.length == _pageSize,
          lastNom: page.isNotEmpty ? page.last.nom : null,
          lastId: page.isNotEmpty ? page.last.id : null,
          statut: statut,
          sexe: sexe,
          raceId: raceId,
        );
      }
      throw humanizeError(e);
    }
  }

  Future<void> refresh() async {
    final current = state.asData?.value ?? const LapinsListState();
    state = AsyncValue.data(current.copyWith(isRefreshing: true));
    state = await AsyncValue.guard(() async {
      final next = await _loadFirstPage(
        statut: current.statut,
        sexe: current.sexe,
        raceId: current.raceId,
      );
      return next.copyWith(isRefreshing: false);
    });
  }

  Future<void> loadMore() async {
    final current = state.asData?.value ?? const LapinsListState();
    if (!current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        state = AsyncValue.data(current.copyWith(isLoadingMore: false));
        return;
      }

      final connectivity = ref.read(connectivityCheckerProvider);
      final cache = ref.read(localCacheServiceProvider);

      List<Lapin> page;
      if (!connectivity.isOnline) {
        final all = await cache.getLapins(userId: userId);
        page = _offlinePage(
          all: all,
          statut: current.statut,
          sexe: current.sexe,
          raceId: current.raceId,
          afterNom: current.lastNom,
          afterId: current.lastId,
        );
      } else {
        page = await _fetchOnlinePage(
          userId: userId,
          statut: current.statut,
          sexe: current.sexe,
          raceId: current.raceId,
          afterNom: current.lastNom,
          afterId: current.lastId,
        );
        await cache.cacheLapins(userId: userId, lapins: page);
      }

      final merged = [
        ...current.items,
        ...page.where((p) => current.items.every((e) => e.id != p.id)),
      ];

      state = AsyncValue.data(
        current.copyWith(
          items: merged,
          isLoadingMore: false,
          hasMore: page.length == _pageSize,
          lastNom: merged.isNotEmpty ? merged.last.nom : null,
          lastId: merged.isNotEmpty ? merged.last.id : null,
        ),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> setFilters({
    required StatutLapin? statut,
    required SexeLapin? sexe,
    required String? raceId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _loadFirstPage(
        statut: statut,
        sexe: sexe,
        raceId: raceId,
      );
    });
  }

  Future<void> setLapinStatutOptimistic({
    required String lapinId,
    required StatutLapin statut,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final now = DateTime.now();

    final nextItems = [
      for (final l in current.items)
        if (l.id == lapinId) l.copyWith(statut: statut, updatedAt: now) else l,
    ];

    state = AsyncValue.data(current.copyWith(items: nextItems));

    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final cache = ref.read(localCacheServiceProvider);
    final match = nextItems.where((e) => e.id == lapinId).toList();
    if (match.isEmpty) return;
    await cache.upsertLapin(match.first);
  }

  Future<void> setLapinPoidsOptimistic({
    required String lapinId,
    required int poidsActuelG,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final now = DateTime.now();

    final nextItems = [
      for (final l in current.items)
        if (l.id == lapinId)
          l.copyWith(poidsActuelG: poidsActuelG, updatedAt: now)
        else
          l,
    ];

    state = AsyncValue.data(current.copyWith(items: nextItems));

    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final cache = ref.read(localCacheServiceProvider);
    final match = nextItems.where((e) => e.id == lapinId).toList();
    if (match.isEmpty) return;
    await cache.upsertLapin(match.first);
  }

  Future<Lapin> create(Lapin lapin) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final now = DateTime.now();
    final optimistic = lapin.copyWith(
      userId: userId,
      updatedAt: now,
    );

    final current = state.asData?.value ?? const LapinsListState();
    state = AsyncValue.data(
      current.copyWith(
        items: [optimistic, ...current.items.where((l) => l.id != optimistic.id)],
      ),
    );
    await cache.upsertLapin(optimistic);

    final data = {
      'id': optimistic.id,
      'user_id': userId,
      'nom': optimistic.nom,
      'race_id': optimistic.raceId,
      'sexe': optimistic.sexe.dbValue,
      'date_naissance':
          optimistic.dateNaissance?.toIso8601String().split('T')[0],
      'poids_actuel_g': optimistic.poidsActuelG,
      'statut': optimistic.statut.dbValue,
      'numero_identification': optimistic.numeroIdentification,
      'photo_url': optimistic.photoUrl,
      'notes': optimistic.notes,
      'created_at': optimistic.createdAt.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    await syncManager.addMutation(
      tableName: 'lapins',
      operation: MutationType.insert,
      payload: jsonEncode(data),
    );

    if (connectivity.isOnline) {
      unawaited(refresh());
    }
    return optimistic;
  }

  Future<Lapin> updateLapin(Lapin lapin) async {
    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final now = DateTime.now();
    final optimistic = lapin.copyWith(updatedAt: now);
    final current = state.asData?.value ?? const LapinsListState();
    final nextItems = [
      for (final l in current.items) if (l.id == optimistic.id) optimistic else l,
    ];
    state = AsyncValue.data(current.copyWith(items: nextItems));
    await cache.upsertLapin(optimistic);

    final data = optimistic.toJson();
    data['updated_at'] = now.toIso8601String();

    await syncManager.addMutation(
      tableName: 'lapins',
      operation: MutationType.update,
      payload: jsonEncode(data),
    );

    if (connectivity.isOnline) {
      unawaited(refresh());
    }
    return optimistic;
  }

  Future<void> remove(String id) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final current = state.asData?.value ?? const LapinsListState();
    state = AsyncValue.data(
      current.copyWith(items: current.items.where((l) => l.id != id).toList()),
    );
    await cache.markLapinDeleted(id: id, userId: userId);

    final payload = {'id': id, 'user_id': userId};

    await syncManager.addMutation(
      tableName: 'lapins',
      operation: MutationType.delete,
      payload: jsonEncode(payload),
    );

    if (connectivity.isOnline) {
      unawaited(refresh());
    }
  }

  Future<void> recordPesee({
    required String lapinId,
    required int poidsG,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final connectivity = ref.read(connectivityCheckerProvider);
    if (!connectivity.isOnline) {
      throw Exception('Action indisponible hors ligne');
    }

    final peseeData = {
      'id': IdempotencyKey.generate(),
      'lapin_id': lapinId,
      'user_id': userId,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'poids_g': poidsG,
    };

    await supabase.from('pesees').insert(peseeData);
    await supabase.from('lapins').update({'poids_actuel_g': poidsG}).eq('id', lapinId);
  }

  List<Lapin> _offlinePage({
    required List<Lapin> all,
    required StatutLapin? statut,
    required SexeLapin? sexe,
    required String? raceId,
    required String? afterNom,
    required String? afterId,
  }) {
    final items = [...all];
    items.sort((a, b) {
      final c = a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
      if (c != 0) return c;
      return a.id.compareTo(b.id);
    });

    Iterable<Lapin> filtered = items;
    if (statut != null) {
      filtered = filtered.where((l) => l.statut == statut);
    }
    if (sexe != null) {
      filtered = filtered.where((l) => l.sexe == sexe);
    }
    if (raceId != null) {
      filtered = filtered.where((l) => l.raceId == raceId);
    }

    if (afterNom != null && afterId != null) {
      filtered = filtered.where((l) {
        final c = l.nom.toLowerCase().compareTo(afterNom.toLowerCase());
        if (c > 0) return true;
        if (c < 0) return false;
        return l.id.compareTo(afterId) > 0;
      });
    }

    return filtered.take(_pageSize).toList();
  }

  Future<List<Lapin>> _fetchOnlinePage({
    required String userId,
    required StatutLapin? statut,
    required SexeLapin? sexe,
    required String? raceId,
    required String? afterNom,
    required String? afterId,
  }) async {
    final supabase = ref.read(supabaseClientProvider);

    dynamic q = supabase
        .from('lapins')
        .select('*, races(*)')
        .eq('user_id', userId);

    if (statut != null) {
      q = q.eq('statut', statut.dbValue);
    }
    if (sexe != null) {
      q = q.eq('sexe', sexe.dbValue);
    }
    if (raceId != null) {
      q = q.eq('race_id', raceId);
    }

    if (afterNom != null && afterId != null) {
      q = q.or(_buildKeysetOr(afterNom, afterId));
    }

    final response = await q.order('nom', ascending: true).order('id', ascending: true).limit(_pageSize);
    return (response as List).map((e) => Lapin.fromJson(e)).toList();
  }

  String _buildKeysetOr(String lastNom, String lastId) {
    final n = _quoteForPostgrest(lastNom);
    final id = _quoteForPostgrest(lastId);
    return 'nom.gt.$n,and(nom.eq.$n,id.gt.$id)';
  }

  String _quoteForPostgrest(String value) {
    final escaped = value.replaceAll('"', r'\"');
    return '"$escaped"';
  }
}

final lapinsProvider =
    AsyncNotifierProvider<LapinsController, LapinsListState>(LapinsController.new);

final lapinDetailProvider = FutureProvider.family<Lapin, String>((ref, id) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  final connectivity = ref.read(connectivityCheckerProvider);
  final cache = ref.read(localCacheServiceProvider);

  final cached = await cache.getLapinById(userId: userId, lapinId: id);

  if (!connectivity.isOnline) {
    if (cached != null) return cached;
    throw const LapinOfflineNotFoundException();
  }

  if (cached != null) {
    unawaited(() async {
      try {
        final response = await supabase
            .from('lapins')
            .select('*, races(*)')
            .eq('id', id)
            .single();
        final remote = Lapin.fromJson(response);
        await cache.upsertLapin(remote);
        ref.invalidateSelf();
      } catch (_) {}
    }());
    return cached;
  }

  final response = await supabase
      .from('lapins')
      .select('*, races(*)')
      .eq('id', id)
      .single();
  final remote = Lapin.fromJson(response);
  await cache.upsertLapin(remote);
  return remote;
});

final racesProvider = FutureProvider<List<Race>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final connectivity = ref.read(connectivityCheckerProvider);
  final cache = ref.read(localCacheServiceProvider);

  const ttl = Duration(days: 7);
  final cached = await cache.getRacesRef();

  if (!connectivity.isOnline) {
    if (cached != null) return cached.races;
    throw const RacesOfflineNotFoundException();
  }

  if (cached != null) {
    final age = DateTime.now().difference(cached.cachedAt);
    if (age > ttl) {
      unawaited(() async {
        try {
          final response = await supabase.from('races').select().order('nom');
          final races = (response as List).map((e) => Race.fromJson(e)).toList();
          await cache.setRacesRef(races);
          ref.invalidateSelf();
        } catch (_) {}
      }());
    }
    return cached.races;
  }

  try {
    final response = await supabase.from('races').select().order('nom');
    final races = (response as List).map((e) => Race.fromJson(e)).toList();
    await cache.setRacesRef(races);
    return races;
  } catch (e) {
    await connectivity.checkConnectivity();
    final retryCached = await cache.getRacesRef();
    if (!connectivity.isOnline && retryCached != null) {
      return retryCached.races;
    }
    throw humanizeError(e);
  }
});

final lapinsSelectionProvider = FutureProvider<List<Lapin>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return const [];

  final connectivity = ref.read(connectivityCheckerProvider);
  final cache = ref.read(localCacheServiceProvider);

  if (!connectivity.isOnline) {
    return cache.getLapins(userId: userId);
  }

  try {
    final response = await supabase
        .from('lapins')
        .select('*, races(*)')
        .eq('user_id', userId)
        .order('nom', ascending: true)
        .order('id', ascending: true);
    final lapins = (response as List).map((e) => Lapin.fromJson(e)).toList();
    await cache.cacheLapins(userId: userId, lapins: lapins);
    return lapins;
  } catch (e) {
    await connectivity.checkConnectivity();
    if (!connectivity.isOnline) {
      return cache.getLapins(userId: userId);
    }
    throw humanizeError(e);
  }
});
