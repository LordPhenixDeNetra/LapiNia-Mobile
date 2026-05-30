import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/models/race.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class RaceListScreen extends HookConsumerWidget {
  const RaceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final searchQuery = useState('');
    final racesAsync = ref.watch(racesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.racesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: l10n.racesCompareCta,
            onPressed: racesAsync.asData?.value.isNotEmpty == true
                ? () => _openComparePicker(
                      context: context,
                      races: racesAsync.asData?.value ?? const [],
                    )
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: l10n.racesRecommendCta,
            onPressed: () => context.push('/races/recommend'),
          ),
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.racesSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchQuery.value = '',
                      )
                    : null,
              ),
              onChanged: (v) => searchQuery.value = v,
            ),
          ),
          Expanded(
            child: racesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorDisplayWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(racesProvider),
              ),
              data: (items) {
                final filtered = items.where((r) {
                  final q = searchQuery.value.trim().toLowerCase();
                  if (q.isEmpty) return true;
                  return r.nom.toLowerCase().contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.pets_outlined,
                    title: l10n.racesEmptyTitle,
                    subtitle: l10n.racesEmptySubtitle,
                    buttonText: l10n.retry,
                    onButtonPressed: () => ref.invalidate(racesProvider),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final race = filtered[index];
                    return Card(
                      child: ListTile(
                        title: Text(race.nom),
                        subtitle: Text(_subtitleFor(race, l10n)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/race/${race.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitleFor(Race race, AppLocalizations l10n) {
    final parts = <String>[];
    if (race.poidsAdulteMinKg != null || race.poidsAdulteMaxKg != null) {
      final min = race.poidsAdulteMinKg?.toStringAsFixed(1) ?? '—';
      final max = race.poidsAdulteMaxKg?.toStringAsFixed(1) ?? '—';
      parts.add(l10n.racesWeightRange(min, max));
    }
    if (race.gmqCibleG != null) {
      parts.add(l10n.racesGmqTarget(race.gmqCibleG!.toString()));
    }
    if (race.adaptationChaleurScore != null) {
      parts.add(l10n.racesHeatScore(race.adaptationChaleurScore!.toString()));
    }
    return parts.isEmpty ? l10n.racesNoSummary : parts.join(' • ');
  }
}

Future<void> _openComparePicker({
  required BuildContext context,
  required List<Race> races,
}) async {
  final l10n = AppLocalizations.of(context)!;

  final selectedIds = await showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return HookBuilder(
        builder: (context) {
          final selected = useState<Set<String>>(<String>{});
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

  if (selectedIds == null || selectedIds.length < 2) return;
  final idsParam = selectedIds.join(',');
  if (context.mounted) {
    context.push('/races/compare?ids=$idsParam');
  }
}
