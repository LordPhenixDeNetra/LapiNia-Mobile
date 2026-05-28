import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/models/portee.dart';
import 'core_providers.dart';

class PorteesController extends AsyncNotifier<List<Portee>> {
  @override
  FutureOr<List<Portee>> build() async {
    return _load();
  }

  Future<List<Portee>> _load() async {
    final supabase = ref.read(supabaseClientProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('portees')
        .select('*, lapins_mere:lapins!mere_id(*), lapins_pere:lapins!pere_id(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Portee.fromJson(e)).toList();
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

    final dateMiseBasPrevue = portee.dateSaillie.add(const Duration(days: 31));

    final data = {
      'id': portee.id,
      'user_id': userId,
      'mere_id': portee.mereId,
      'pere_id': portee.pereId,
      'date_saillie': portee.dateSaillie.toIso8601String().split('T')[0],
      'date_mise_bas_prevue': dateMiseBasPrevue.toIso8601String().split('T')[0],
      'statut': portee.statut.dbValue,
      'notes': portee.notes,
    };

    await supabase.from('portees').insert(data);
    await supabase
        .from('lapins')
        .update({'statut': 'EN_GESTATION'})
        .eq('id', portee.mereId);
    await refresh();
  }

  Future<void> recordMiseBas({
    required String porteeId,
    required String mereId,
    required DateTime dateMiseBas,
    required int nbVivants,
    required int nbMorts,
    required int poidsTotalG,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from('portees').update({
      'date_mise_bas_reelle': dateMiseBas.toIso8601String().split('T')[0],
      'nb_vivants': nbVivants,
      'nb_morts': nbMorts,
      'poids_total_portee_g': poidsTotalG,
      'statut': 'LACTATION',
    }).eq('id', porteeId);

    await supabase.from('lapins').update({'statut': 'LACTATION'}).eq('id', mereId);
    await refresh();
  }

  Future<void> recordSevrage({
    required String porteeId,
    required String mereId,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from('portees').update({'statut': 'SEVRAGE'}).eq('id', porteeId);
    await supabase.from('lapins').update({'statut': 'REPOS'}).eq('id', mereId);
    await refresh();
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

