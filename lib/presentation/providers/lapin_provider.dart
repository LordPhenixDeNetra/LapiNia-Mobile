import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/models/lapin.dart';
import '../../core/models/race.dart';
import '../../core/utils/idempotency_key.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/utils/sync_manager.dart';
import 'core_providers.dart';

class LapinsController extends AsyncNotifier<List<Lapin>> {
  @override
  FutureOr<List<Lapin>> build() async {
    return _loadLapins();
  }

  Future<List<Lapin>> _loadLapins() async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

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
          .order('created_at', ascending: false);

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
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadLapins);
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

    state = AsyncValue.data([
      optimistic,
      ...(state.asData?.value ?? const []),
    ]);
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
      'updated_at': now.toIso8601String(),
    };

    if (!connectivity.isOnline) {
      await syncManager.addMutation(
        tableName: 'lapins',
        operation: MutationType.insert,
        payload: jsonEncode(data),
      );
      return optimistic;
    }

    try {
      final response = await supabase
          .from('lapins')
          .insert(data)
          .select('*, races(*)')
          .single();

      final created = Lapin.fromJson(response);
      await cache.upsertLapin(created);
      state = AsyncValue.data([
        created,
        ...(state.asData?.value ?? const []).where((l) => l.id != created.id),
      ]);
      return created;
    } catch (e) {
      await connectivity.checkConnectivity();
      if (!connectivity.isOnline) {
        await syncManager.addMutation(
          tableName: 'lapins',
          operation: MutationType.insert,
          payload: jsonEncode(data),
        );
        return optimistic;
      }
      throw humanizeError(e);
    }
  }

  Future<Lapin> updateLapin(Lapin lapin) async {
    final supabase = ref.read(supabaseClientProvider);
    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final now = DateTime.now();
    final optimistic = lapin.copyWith(updatedAt: now);
    state = AsyncValue.data([
      for (final l in (state.asData?.value ?? const []))
        if (l.id == optimistic.id) optimistic else l,
    ]);
    await cache.upsertLapin(optimistic);

    final data = optimistic.toJson();
    data['updated_at'] = now.toIso8601String();

    if (!connectivity.isOnline) {
      await syncManager.addMutation(
        tableName: 'lapins',
        operation: MutationType.update,
        payload: jsonEncode(data),
      );
      return optimistic;
    }

    try {
      await supabase.from('lapins').update(data).eq('id', optimistic.id);
      final response = await supabase
          .from('lapins')
          .select('*, races(*)')
          .eq('id', optimistic.id)
          .single();

      final updated = Lapin.fromJson(response);
      await cache.upsertLapin(updated);
      state = AsyncValue.data([
        for (final l in (state.asData?.value ?? const []))
          if (l.id == updated.id) updated else l,
      ]);
      return updated;
    } catch (e) {
      await connectivity.checkConnectivity();
      if (!connectivity.isOnline) {
        await syncManager.addMutation(
          tableName: 'lapins',
          operation: MutationType.update,
          payload: jsonEncode(data),
        );
        return optimistic;
      }
      throw humanizeError(e);
    }
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

    state = AsyncValue.data([
      ...(state.asData?.value ?? const []).where((l) => l.id != id),
    ]);
    await cache.markLapinDeleted(id: id, userId: userId);

    final payload = {'id': id, 'user_id': userId};

    if (!connectivity.isOnline) {
      await syncManager.addMutation(
        tableName: 'lapins',
        operation: MutationType.delete,
        payload: jsonEncode(payload),
      );
      return;
    }

    try {
      await supabase.from('lapins').delete().eq('id', id);
    } catch (e) {
      await connectivity.checkConnectivity();
      if (!connectivity.isOnline) {
        await syncManager.addMutation(
          tableName: 'lapins',
          operation: MutationType.delete,
          payload: jsonEncode(payload),
        );
        return;
      }
      throw humanizeError(e);
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
}

final lapinsProvider =
    AsyncNotifierProvider<LapinsController, List<Lapin>>(LapinsController.new);

final lapinDetailProvider = FutureProvider.family<Lapin, String>((ref, id) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('lapins')
      .select('*, races(*), pesees(*), sante(*), genealogie(*)')
      .eq('id', id)
      .single();
  return Lapin.fromJson(response);
});

final racesProvider = FutureProvider<List<Race>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase.from('races').select().order('nom');
  return (response as List).map((e) => Race.fromJson(e)).toList();
});
