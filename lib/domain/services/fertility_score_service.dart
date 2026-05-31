import 'dart:convert';

import 'package:drift/drift.dart';
import '../../core/constants/enums.dart';
import '../../core/models/fertility_score.dart';
import '../../core/models/lapin.dart';
import '../../core/models/portee.dart';
import '../../core/utils/connectivity_checker.dart';
import '../../core/utils/idempotency_key.dart';
import '../../core/utils/sync_manager.dart';
import '../../data/local_db/local_cache_service.dart';
import 'fertility_advice_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FertilityScoreService {
  final LocalCacheService cache;
  final SyncManager syncManager;
  final ConnectivityChecker connectivity;
  final SupabaseClient supabase;
  final FertilityAdviceService adviceService;

  FertilityScoreService({
    required this.cache,
    required this.syncManager,
    required this.connectivity,
    required this.supabase,
    required this.adviceService,
  });

  Future<FertilityScoreResult> recalculateAndPersist({
    required Lapin lapin,
  }) async {
    final now = DateTime.now();
    final windowStart = DateTime(now.year, now.month - 6, now.day);

    final portees = await cache.getPortees(userId: lapin.userId);
    final relevant = portees
        .where((p) {
          final belongsTo = lapin.sexe == SexeLapin.femelle ? p.mereId == lapin.id : p.pereId == lapin.id;
          return belongsTo && !p.dateSaillie.isBefore(windowStart);
        })
        .toList()
      ..sort((a, b) => a.dateSaillie.compareTo(b.dateSaillie));

    final porteesWithMiseBas = relevant
        .where((p) => p.dateMiseBasReelle != null || p.statut != StatutPortee.enGestation)
        .toList();

    final acceptation = _scoreAcceptation(
      total: relevant.length,
      withMiseBas: porteesWithMiseBas.length,
    );

    final avgLitterSize = _avgLitterSize(porteesWithMiseBas);
    final taillePortees = _scoreLitterSize(avgLitterSize);

    final (:survivalRate, :survieLapereaux) = await _computeSurvivalScore(
      userId: lapin.userId,
      porteesWithMiseBas: porteesWithMiseBas,
    );

    final (:avgIntervalDays, :regularite) = _computeRegularityScore(relevant);

    final result = FertilityScoreResult(
      breakdown: FertilityScoreBreakdown(
        acceptation: acceptation,
        taillePortees: taillePortees,
        survieLapereaux: survieLapereaux,
        regularite: regularite,
      ),
      porteesCount: relevant.length,
      porteesWithMiseBasCount: porteesWithMiseBas.length,
      avgLitterSize: avgLitterSize,
      survivalRate: survivalRate,
      avgIntervalDays: avgIntervalDays,
    );

    final monthKey = _monthKey(now);
    await cache.upsertFertilityScoreMonthly(
      userId: lapin.userId,
      lapinId: lapin.id,
      monthKey: monthKey,
      score: result.total,
      data: jsonEncode(result.toHistoryDataJson()),
    );

    if (lapin.scoreFertilite != result.total) {
      final updatedLapin = lapin.copyWith(
        scoreFertilite: result.total,
        updatedAt: now,
      );
      await cache.upsertLapin(updatedLapin);
      await syncManager.addMutation(
        tableName: 'lapins',
        operation: MutationType.update,
        payload: jsonEncode({
          'id': lapin.id,
          'user_id': lapin.userId,
          'score_fertilite': result.total,
          'updated_at': now.toIso8601String(),
        }),
      );
    }

    final monthMinus3 = DateTime(now.year, now.month - 3, 1);
    final before = await cache.getFertilityScoreForMonth(
      userId: lapin.userId,
      lapinId: lapin.id,
      monthKey: _monthKey(monthMinus3),
    );

    if (before != null && result.total <= before - 21) {
      await _maybeCreateFertilityDropAlert(
        lapin: lapin,
        scoreNow: result.total,
        scoreBefore: before,
      );
    }

    return result;
  }

  int _scoreAcceptation({required int total, required int withMiseBas}) {
    if (total <= 0) return 12;
    final ratio = withMiseBas / total;
    return (ratio * 25).round().clamp(0, 25);
  }

  double? _avgLitterSize(List<Portee> porteesWithMiseBas) {
    final sizes = porteesWithMiseBas
        .map((p) => p.nbVivants + p.nbMorts)
        .where((n) => n > 0)
        .toList();
    if (sizes.isEmpty) return null;
    final total = sizes.fold<int>(0, (s, v) => s + v);
    return total / sizes.length;
  }

  int _scoreLitterSize(double? avgLitterSize) {
    if (avgLitterSize == null) return 12;
    const min = 2.0;
    const max = 8.0;
    final clamped = avgLitterSize.clamp(min, max);
    final ratio = (clamped - min) / (max - min);
    return (ratio * 25).round().clamp(0, 25);
  }

  Future<({double? survivalRate, int survieLapereaux})> _computeSurvivalScore({
    required String userId,
    required List<Portee> porteesWithMiseBas,
  }) async {
    var total = 0;
    var survived = 0;

    for (final p in porteesWithMiseBas) {
      final lapereaux = await cache.getLapereaux(userId: userId, porteeId: p.id);
      if (lapereaux.isNotEmpty) {
        total += lapereaux.length;
        survived += lapereaux.where((l) => l.statut != StatutLapereau.mort).length;
      } else {
        final born = p.nbVivants + p.nbMorts;
        if (born > 0) {
          total += born;
          survived += p.nbVivants;
        }
      }
    }

    if (total <= 0) {
      return (survivalRate: null, survieLapereaux: 12);
    }

    final rate = survived / total;
    final score = (rate * 25).round().clamp(0, 25);
    return (survivalRate: rate, survieLapereaux: score);
  }

  ({double? avgIntervalDays, int regularite}) _computeRegularityScore(List<Portee> relevantPortees) {
    if (relevantPortees.length < 2) {
      return (avgIntervalDays: null, regularite: 12);
    }

    final intervals = <int>[];
    for (var i = 1; i < relevantPortees.length; i++) {
      final prev = relevantPortees[i - 1].dateSaillie;
      final cur = relevantPortees[i].dateSaillie;
      final d = cur.difference(prev).inDays;
      if (d > 0) intervals.add(d);
    }

    if (intervals.isEmpty) {
      return (avgIntervalDays: null, regularite: 12);
    }

    final sum = intervals.fold<int>(0, (s, v) => s + v);
    final avg = sum / intervals.length;

    const ideal = 50.0;
    const worst = 120.0;
    final clamped = avg.clamp(ideal, worst);
    final ratio = 1 - ((clamped - ideal) / (worst - ideal));
    final score = (ratio * 25).round().clamp(0, 25);
    return (avgIntervalDays: avg, regularite: score);
  }

  Future<void> _maybeCreateFertilityDropAlert({
    required Lapin lapin,
    required int scoreNow,
    required int scoreBefore,
  }) async {
    final now = DateTime.now();

    try {
      final pending = await (syncManager.db.select(syncManager.db.syncQueue)
            ..where((t) =>
                t.targetTable.equals('alertes') &
                t.operation.equals(MutationType.insert.name)))
          .get();
      for (final row in pending) {
        final decoded = jsonDecode(row.payload);
        if (decoded is! Map) continue;
        final payload = Map<String, dynamic>.from(decoded);
        if (payload['lapin_id'] == lapin.id && payload['type'] == 'FERTILITE') {
          return;
        }
      }
    } catch (_) {}

    if (connectivity.isOnline) {
      try {
        final existing = await supabase
            .from('alertes')
            .select('id')
            .eq('user_id', lapin.userId)
            .eq('lapin_id', lapin.id)
            .eq('type', 'FERTILITE')
            .eq('lue', false)
            .order('created_at', ascending: false)
            .limit(1);
        if (existing.isNotEmpty) return;
      } catch (_) {}
    }

    var recs = <String>[];
    if (connectivity.isOnline) {
      try {
        recs = await adviceService.getRecommendations(
          lapinId: lapin.id,
          scoreNow: scoreNow,
          scoreBefore: scoreBefore,
        );
      } catch (_) {}
    }

    if (recs.isEmpty) {
      recs = _fallbackRecommendations();
    }

    final message = [
      'Baisse du score de fertilité: $scoreBefore/100 → $scoreNow/100.',
      ...recs.map((e) => '- $e'),
    ].join('\n');

    await syncManager.addMutation(
      tableName: 'alertes',
      operation: MutationType.insert,
      payload: jsonEncode({
        'id': IdempotencyKey.generate(),
        'user_id': lapin.userId,
        'lapin_id': lapin.id,
        'type': 'FERTILITE',
        'message': message,
        'priorite': 2,
        'date_echeance': now.toIso8601String(),
        'created_at': now.toIso8601String(),
      }),
    );
  }

  List<String> _fallbackRecommendations() {
    return const [
      "Vérifier l'état corporel et ajuster l'alimentation (foin à volonté + granulés, eau propre).",
      'Réduire le stress (chaleur, bruit) et améliorer la ventilation, surtout en période chaude.',
      'Contrôler la santé reproductive et respecter des temps de repos entre saillies.',
    ];
  }

  String _monthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
}
