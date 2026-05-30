import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/models/race.dart';
import '../../../core/models/race_recommendation.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class RaceCompareScreen extends HookConsumerWidget {
  final List<String> raceIds;

  const RaceCompareScreen({super.key, required this.raceIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final goal = useState<RaceRecommendationGoal>(RaceRecommendationGoal.meat);
    final racesAsync = ref.watch(racesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.racesCompareTitle),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.racesGoalMeat),
                  selected: goal.value == RaceRecommendationGoal.meat,
                  onSelected: (_) => goal.value = RaceRecommendationGoal.meat,
                ),
                ChoiceChip(
                  label: Text(l10n.racesGoalBreeding),
                  selected: goal.value == RaceRecommendationGoal.breeding,
                  onSelected: (_) => goal.value = RaceRecommendationGoal.breeding,
                ),
                ChoiceChip(
                  label: Text(l10n.racesGoalHeatResilience),
                  selected: goal.value == RaceRecommendationGoal.heatResilience,
                  onSelected: (_) => goal.value = RaceRecommendationGoal.heatResilience,
                ),
              ],
            ),
          ),
          Expanded(
            child: racesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorDisplayWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(racesProvider),
              ),
              data: (allRaces) {
                final selected = allRaces.where((r) => raceIds.contains(r.id)).toList();

                if (selected.length < 2) {
                  return EmptyStateWidget(
                    icon: Icons.compare_arrows,
                    title: l10n.racesCompareNeedTwoTitle,
                    subtitle: l10n.racesCompareNeedTwoSubtitle,
                    buttonText: l10n.racesComparePickMoreCta,
                    onButtonPressed: () async {
                      final ids = await _openComparePicker(
                        context: context,
                        races: allRaces,
                        initial: raceIds,
                      );
                      if (ids == null || ids.length < 2) return;
                      if (!context.mounted) return;
                      context.go('/races/compare?ids=${ids.join(',')}');
                    },
                  );
                }

                final best = _BestValues.from(selected, goal.value);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(l10n.racesCompareMetricColumn)),
                      for (final r in selected) DataColumn(label: Text(r.nom)),
                    ],
                    rows: [
                      _row(
                        context,
                        l10n.raceAdultWeightLabel,
                        selected,
                        (r) => _weightRange(r),
                        highlightWhen: (r) => best.bestWeightRaceId == r.id,
                      ),
                      _row(
                        context,
                        l10n.raceGmqLabel,
                        selected,
                        (r) => r.gmqCibleG != null ? l10n.raceGmqValue(r.gmqCibleG!) : '—',
                        highlightWhen: (r) => best.bestGmqRaceId == r.id,
                      ),
                      _row(
                        context,
                        l10n.raceLitterSizeLabel,
                        selected,
                        (r) => r.taillePorteeMoyenne != null
                            ? l10n.raceLitterSizeValue(r.taillePorteeMoyenne!)
                            : '—',
                        highlightWhen: (r) => best.bestLitterRaceId == r.id,
                      ),
                      _row(
                        context,
                        l10n.raceFirstBirthAgeLabel,
                        selected,
                        (r) => r.age1ereMiseBasJours != null
                            ? l10n.raceFirstBirthAgeValue(r.age1ereMiseBasJours!)
                            : '—',
                        highlightWhen: (r) => best.bestFirstBirthRaceId == r.id,
                      ),
                      _row(
                        context,
                        l10n.raceHeatAdaptationLabel,
                        selected,
                        (r) => r.adaptationChaleurScore != null
                            ? l10n.raceHeatAdaptationValue(r.adaptationChaleurScore!)
                            : '—',
                        highlightWhen: (r) => best.bestHeatRaceId == r.id,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static DataRow _row(
    BuildContext context,
    String metric,
    List<Race> races,
    String Function(Race) valueOf, {
    required bool Function(Race) highlightWhen,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return DataRow(
      cells: [
        DataCell(Text(metric)),
        for (final r in races)
          DataCell(
            Text(
              valueOf(r),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: highlightWhen(r) ? colorScheme.primary : null,
                    fontWeight: highlightWhen(r) ? FontWeight.w600 : null,
                  ),
            ),
          ),
      ],
    );
  }

  static String _weightRange(Race race) {
    final min = race.poidsAdulteMinKg;
    final max = race.poidsAdulteMaxKg;
    if (min == null && max == null) return '—';
    final minS = min != null ? min.toStringAsFixed(1) : '—';
    final maxS = max != null ? max.toStringAsFixed(1) : '—';
    return '$minS–$maxS kg';
  }
}

class _BestValues {
  final String? bestWeightRaceId;
  final String? bestGmqRaceId;
  final String? bestLitterRaceId;
  final String? bestFirstBirthRaceId;
  final String? bestHeatRaceId;

  const _BestValues({
    required this.bestWeightRaceId,
    required this.bestGmqRaceId,
    required this.bestLitterRaceId,
    required this.bestFirstBirthRaceId,
    required this.bestHeatRaceId,
  });

  factory _BestValues.from(List<Race> races, RaceRecommendationGoal goal) {
    String? bestWeight;
    String? bestGmq;
    String? bestLitter;
    String? bestFirstBirth;
    String? bestHeat;

    double bestWeightValue = -1;
    int bestGmqValue = -1;
    double bestLitterValue = -1;
    int bestFirstBirthValue = 1 << 30;
    int bestHeatValue = -1;

    for (final r in races) {
      final w = r.poidsAdulteMaxKg ?? r.poidsAdulteMinKg;
      if (w != null && w > bestWeightValue) {
        bestWeightValue = w;
        bestWeight = r.id;
      }
      final g = r.gmqCibleG;
      if (g != null && g > bestGmqValue) {
        bestGmqValue = g;
        bestGmq = r.id;
      }
      final l = r.taillePorteeMoyenne;
      if (l != null && l > bestLitterValue) {
        bestLitterValue = l;
        bestLitter = r.id;
      }
      final a = r.age1ereMiseBasJours;
      if (a != null && a < bestFirstBirthValue) {
        bestFirstBirthValue = a;
        bestFirstBirth = r.id;
      }
      final h = r.adaptationChaleurScore;
      if (h != null && h > bestHeatValue) {
        bestHeatValue = h;
        bestHeat = r.id;
      }
    }

    switch (goal) {
      case RaceRecommendationGoal.meat:
        return _BestValues(
          bestWeightRaceId: bestWeight,
          bestGmqRaceId: bestGmq,
          bestLitterRaceId: null,
          bestFirstBirthRaceId: null,
          bestHeatRaceId: null,
        );
      case RaceRecommendationGoal.breeding:
        return _BestValues(
          bestWeightRaceId: null,
          bestGmqRaceId: null,
          bestLitterRaceId: bestLitter,
          bestFirstBirthRaceId: bestFirstBirth,
          bestHeatRaceId: null,
        );
      case RaceRecommendationGoal.heatResilience:
        return _BestValues(
          bestWeightRaceId: null,
          bestGmqRaceId: null,
          bestLitterRaceId: null,
          bestFirstBirthRaceId: null,
          bestHeatRaceId: bestHeat,
        );
    }
  }
}

Future<List<String>?> _openComparePicker({
  required BuildContext context,
  required List<Race> races,
  List<String> initial = const [],
}) async {
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return HookBuilder(
        builder: (context) {
          final selected = useState<Set<String>>(initial.toSet());
          final canSubmit = selected.value.length >= 2 && selected.value.length <= 3;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.racesComparePickTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final race in races)
                          CheckboxListTile(
                            value: selected.value.contains(race.id),
                            title: Text(race.nom),
                            onChanged: (v) {
                              final next = {...selected.value};
                              if (v == true) {
                                if (next.length >= 3) return;
                                next.add(race.id);
                              } else {
                                next.remove(race.id);
                              }
                              selected.value = next;
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: canSubmit ? () => Navigator.of(context).pop(selected.value.toList()) : null,
                    child: Text(l10n.racesCompareCta),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

