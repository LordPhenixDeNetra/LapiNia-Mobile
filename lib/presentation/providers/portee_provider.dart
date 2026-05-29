import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/models/portee.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/utils/sync_manager.dart';
import 'core_providers.dart';
import 'lapin_provider.dart';

class PorteesController extends AsyncNotifier<List<Portee>> {
  @override
  FutureOr<List<Portee>> build() async {
    return _load();
  }

  Future<List<Portee>> _load() async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);

    if (!connectivity.isOnline) {
      return cache.getPortees(userId: userId);
    }

    try {
      final response = await supabase
          .from('portees')
          .select(
              '*, lapins_mere:lapins!mere_id(*), lapins_pere:lapins!pere_id(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final portees = (response as List).map((e) => Portee.fromJson(e)).toList();
      await cache.cachePortees(userId: userId, portees: portees);
      return portees;
    } catch (e) {
      await connectivity.checkConnectivity();
      if (!connectivity.isOnline) {
        return cache.getPortees(userId: userId);
      }
      throw humanizeError(e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> create(Portee portee) async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final connectivity = ref.read(connectivityCheckerProvider);
    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final now = DateTime.now();
    final optimistic = portee.copyWith(
      userId: userId,
      updatedAt: now,
    );
    state = AsyncValue.data([
      optimistic,
      ...(state.asData?.value ?? const []),
    ]);
    await cache.upsertPortee(optimistic);

    final dateMiseBasPrevue = portee.dateSaillie.add(const Duration(days: 31));

    final data = {
      'id': optimistic.id,
      'user_id': userId,
      'mere_id': optimistic.mereId,
      'pere_id': optimistic.pereId,
      'date_saillie': optimistic.dateSaillie.toIso8601String().split('T')[0],
      'date_mise_bas_prevue': dateMiseBasPrevue.toIso8601String().split('T')[0],
      'statut': optimistic.statut.dbValue,
      'notes': optimistic.notes,
      'updated_at': now.toIso8601String(),
    };

    await syncManager.addMutation(
      tableName: 'portees',
      operation: MutationType.insert,
      payload: jsonEncode(data),
    );

    await ref.read(lapinsProvider.notifier).setLapinStatutOptimistic(
          lapinId: optimistic.mereId,
          statut: StatutLapin.enGestation,
        );

    await syncManager.addMutation(
      tableName: 'lapins',
      operation: MutationType.update,
      payload: jsonEncode({
        'id': optimistic.mereId,
        'user_id': userId,
        'statut': StatutLapin.enGestation.dbValue,
        'updated_at': now.toIso8601String(),
      }),
    );

    if (connectivity.isOnline) {
      unawaited(refresh());
      unawaited(ref.read(lapinsProvider.notifier).refresh());
    }
  }

  Future<void> recordMiseBas({
    required String porteeId,
    required String mereId,
    required DateTime dateMiseBas,
    required int nbVivants,
    required int nbMorts,
    required int poidsTotalG,
  }) async {
    final connectivity = ref.read(connectivityCheckerProvider);
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final now = DateTime.now();
    final current = state.asData?.value ?? const [];
    final index = current.indexWhere((p) => p.id == porteeId);
    if (index != -1) {
      final updatedPortee = current[index].copyWith(
        dateMiseBasReelle: dateMiseBas,
        nbVivants: nbVivants,
        nbMorts: nbMorts,
        poidsTotalPorteeG: poidsTotalG,
        statut: StatutPortee.lactation,
        updatedAt: now,
      );
      state = AsyncValue.data([
        for (final p in current) if (p.id == porteeId) updatedPortee else p,
      ]);
      await cache.upsertPortee(updatedPortee);
    }

    await ref.read(lapinsProvider.notifier).setLapinStatutOptimistic(
          lapinId: mereId,
          statut: StatutLapin.lactation,
        );

    await syncManager.addMutation(
      tableName: 'portees',
      operation: MutationType.update,
      payload: jsonEncode({
        'id': porteeId,
        'user_id': userId,
        'date_mise_bas_reelle': dateMiseBas.toIso8601String().split('T')[0],
        'nb_vivants': nbVivants,
        'nb_morts': nbMorts,
        'poids_total_portee_g': poidsTotalG,
        'statut': StatutPortee.lactation.dbValue,
        'updated_at': now.toIso8601String(),
      }),
    );

    await syncManager.addMutation(
      tableName: 'lapins',
      operation: MutationType.update,
      payload: jsonEncode({
        'id': mereId,
        'user_id': userId,
        'statut': StatutLapin.lactation.dbValue,
        'updated_at': now.toIso8601String(),
      }),
    );

    if (connectivity.isOnline) {
      unawaited(refresh());
      unawaited(ref.read(lapinsProvider.notifier).refresh());
    }
  }

  Future<void> recordSevrage({
    required String porteeId,
    required String mereId,
  }) async {
    final connectivity = ref.read(connectivityCheckerProvider);
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final cache = ref.read(localCacheServiceProvider);
    final syncManager = ref.read(syncManagerProvider);

    final now = DateTime.now();
    final current = state.asData?.value ?? const [];
    final index = current.indexWhere((p) => p.id == porteeId);
    if (index != -1) {
      final updatedPortee = current[index].copyWith(
        statut: StatutPortee.sevrage,
        updatedAt: now,
      );
      state = AsyncValue.data([
        for (final p in current) if (p.id == porteeId) updatedPortee else p,
      ]);
      await cache.upsertPortee(updatedPortee);
    }

    await ref.read(lapinsProvider.notifier).setLapinStatutOptimistic(
          lapinId: mereId,
          statut: StatutLapin.repos,
        );

    await syncManager.addMutation(
      tableName: 'portees',
      operation: MutationType.update,
      payload: jsonEncode({
        'id': porteeId,
        'user_id': userId,
        'statut': StatutPortee.sevrage.dbValue,
        'updated_at': now.toIso8601String(),
      }),
    );

    await syncManager.addMutation(
      tableName: 'lapins',
      operation: MutationType.update,
      payload: jsonEncode({
        'id': mereId,
        'user_id': userId,
        'statut': StatutLapin.repos.dbValue,
        'updated_at': now.toIso8601String(),
      }),
    );

    if (connectivity.isOnline) {
      unawaited(refresh());
      unawaited(ref.read(lapinsProvider.notifier).refresh());
    }
  }
}

final porteesProvider =
    AsyncNotifierProvider<PorteesController, List<Portee>>(PorteesController.new);

final porteeDetailProvider =
    FutureProvider.family<Portee, String>((ref, id) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('portees')
      .select('*, lapins_mere:lapins!mere_id(*), lapins_pere:lapins!pere_id(*)')
      .eq('id', id)
      .single();
  return Portee.fromJson(response);
});
