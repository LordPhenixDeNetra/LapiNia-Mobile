import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/models/fertility_score.dart';
import '../../core/models/genealogy_tree.dart';
import '../../core/models/genealogie.dart';
import '../../data/local_db/app_database.dart';
import 'core_providers.dart';
import 'lapin_provider.dart';

final fertilityScoreProvider = FutureProvider.family<FertilityScoreResult, String>((ref, lapinId) async {
  final lapin = await ref.watch(lapinDetailProvider(lapinId).future);
  final service = ref.read(fertilityScoreServiceProvider);
  return service.recalculateAndPersist(lapin: lapin);
});

final fertilityScoreHistoryProvider =
    FutureProvider.family<List<FertilityScoresLocalData>, String>((ref, lapinId) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return const [];
  final cache = ref.read(localCacheServiceProvider);
  return cache.getFertilityScoresHistory(userId: userId, lapinId: lapinId);
});

final genealogyProvider = FutureProvider.family<GenealogyTree, String>((ref, lapinId) async {
  final supabase = ref.read(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  final maxDepth = 3;
  final parentsByChild = <String, GenealogyParents>{};
  var frontier = <String>{lapinId};
  final allIds = <String>{lapinId};

  for (var depth = 1; depth <= maxDepth; depth++) {
    if (frontier.isEmpty) break;
    final ids = frontier.toList();
    final response = await supabase.from('genealogie').select().inFilter('lapin_id', ids);
    final rows = (response as List).map((e) => Genealogie.fromJson(e)).toList();

    final next = <String>{};
    for (final row in rows) {
      final current = parentsByChild[row.lapinId] ?? const GenealogyParents(pereId: null, mereId: null);
      final nextParents = row.role == 'PERE'
          ? GenealogyParents(pereId: row.parentId, mereId: current.mereId)
          : GenealogyParents(pereId: current.pereId, mereId: row.parentId);
      parentsByChild[row.lapinId] = nextParents;
      next.add(row.parentId);
      allIds.add(row.parentId);
    }
    frontier = next;
  }

  final lapinsResponse = await supabase
      .from('lapins')
      .select('id, nom, sexe, race_id, races(nom)')
      .eq('user_id', userId)
      .inFilter('id', allIds.toList());

  final personsById = <String, GenealogyPerson>{};
  for (final raw in (lapinsResponse as List)) {
    final m = Map<String, dynamic>.from(raw);
    final id = m['id'] as String;
    final race = m['races'] is Map ? Map<String, dynamic>.from(m['races'] as Map) : null;
    personsById[id] = GenealogyPerson(
      id: id,
      nom: m['nom'] as String? ?? '—',
      sexe: m['sexe'] != null ? SexeLapin.fromDbValue(m['sexe'] as String) : null,
      raceNom: race?['nom'] as String?,
    );
  }

  return GenealogyTree(
    centerId: lapinId,
    personsById: personsById,
    parentsByChildId: parentsByChild,
  );
});
