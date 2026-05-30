import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/models/race.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class RaceDetailScreen extends ConsumerWidget {
  final String raceId;

  const RaceDetailScreen({super.key, required this.raceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final racesAsync = ref.watch(racesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.raceDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: l10n.racesCompareCta,
            onPressed: () => context.push('/races/compare?ids=$raceId'),
          ),
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: racesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorDisplayWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(racesProvider),
              ),
              data: (items) {
                final race = _findRace(items, raceId);
                if (race == null) {
                  return EmptyStateWidget(
                    icon: Icons.pets_outlined,
                    title: l10n.raceNotFoundTitle,
                    subtitle: l10n.raceNotFoundSubtitle,
                    buttonText: l10n.retry,
                    onButtonPressed: () => ref.invalidate(racesProvider),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Text(
                      race.nom,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: l10n.raceSectionPerformance,
                      children: [
                        _RowValue(
                          label: l10n.raceAdultWeightLabel,
                          value: _weightRange(race, l10n),
                        ),
                        _RowValue(
                          label: l10n.raceGmqLabel,
                          value: race.gmqCibleG != null ? l10n.raceGmqValue(race.gmqCibleG!) : '—',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      title: l10n.raceSectionReproduction,
                      children: [
                        _RowValue(
                          label: l10n.raceLitterSizeLabel,
                          value: race.taillePorteeMoyenne != null
                              ? l10n.raceLitterSizeValue(race.taillePorteeMoyenne!)
                              : '—',
                        ),
                        _RowValue(
                          label: l10n.raceFirstBirthAgeLabel,
                          value: race.age1ereMiseBasJours != null
                              ? l10n.raceFirstBirthAgeValue(race.age1ereMiseBasJours!)
                              : '—',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      title: l10n.raceSectionClimate,
                      children: [
                        _RowValue(
                          label: l10n.raceHeatAdaptationLabel,
                          value: race.adaptationChaleurScore != null
                              ? l10n.raceHeatAdaptationValue(race.adaptationChaleurScore!)
                              : '—',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Section(
                      title: l10n.raceSectionHealth,
                      children: [
                        if (race.sensibilitesPathologiques == null ||
                            race.sensibilitesPathologiques!.isEmpty)
                          Text(
                            l10n.raceNoSensitivities,
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final s in race.sensibilitesPathologiques!) Chip(label: Text(s)),
                            ],
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Race? _findRace(List<Race> races, String id) {
    for (final r in races) {
      if (r.id == id) return r;
    }
    return null;
  }

  static String _weightRange(Race race, AppLocalizations l10n) {
    final min = race.poidsAdulteMinKg;
    final max = race.poidsAdulteMaxKg;
    if (min == null && max == null) return '—';
    final minS = min != null ? min.toStringAsFixed(1) : '—';
    final maxS = max != null ? max.toStringAsFixed(1) : '—';
    return l10n.racesWeightRange(minS, maxS);
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _RowValue extends StatelessWidget {
  final String label;
  final String value;

  const _RowValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

