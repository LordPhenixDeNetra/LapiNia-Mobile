import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/models/lapin.dart';
import '../../core/models/race.dart';
import '../../core/utils/idempotency_key.dart';
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

    final response = await supabase
        .from('lapins')
        .select('*, races(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Lapin.fromJson(e)).toList();
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

    final data = {
      'id': lapin.id,
      'user_id': userId,
      'nom': lapin.nom,
      'race_id': lapin.raceId,
      'sexe': lapin.sexe.dbValue,
      'date_naissance': lapin.dateNaissance?.toIso8601String().split('T')[0],
      'poids_actuel_g': lapin.poidsActuelG,
      'statut': lapin.statut.dbValue,
      'numero_identification': lapin.numeroIdentification,
      'photo_url': lapin.photoUrl,
      'notes': lapin.notes,
    };

    await ref.read(syncManagerProvider).addMutation(
          tableName: 'lapins',
          operation: MutationType.insert,
          payload: data.toString(),
        );

    final response =
        await supabase.from('lapins').insert(data).select('*, races(*)').single();

    final created = Lapin.fromJson(response);
    await refresh();
    return created;
  }

  Future<Lapin> updateLapin(Lapin lapin) async {
    final supabase = ref.read(supabaseClientProvider);
    final data = lapin.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    await supabase.from('lapins').update(data).eq('id', lapin.id);
    final response = await supabase
        .from('lapins')
        .select('*, races(*)')
        .eq('id', lapin.id)
        .single();

    final updated = Lapin.fromJson(response);
    await refresh();
    return updated;
  }

  Future<void> remove(String id) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from('lapins').delete().eq('id', id);
    await refresh();
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
