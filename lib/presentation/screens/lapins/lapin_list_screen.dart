import 'package:flutter/material.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/race.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/lapin_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/connectivity_banner.dart';

class LapinListScreen extends HookConsumerWidget {
  const LapinListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final searchQuery = useState('');
    final selectedStatut = useState<StatutLapin?>(null);
    final selectedSexe = useState<SexeLapin?>(null);
    final selectedRaceId = useState<String?>(null);

    final lapinsState = ref.watch(lapinsProvider);
    final racesState = ref.watch(racesProvider);
    final racesById = {
      for (final r in racesState.asData?.value ?? const <Race>[]) r.id: r.nom,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lapinsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(
              context: context,
              races: racesState.asData?.value ?? const [],
              selectedStatut: selectedStatut,
              selectedSexe: selectedSexe,
              selectedRaceId: selectedRaceId,
              onApply: () => ref.read(lapinsProvider.notifier).setFilters(
                    statut: selectedStatut.value,
                    sexe: selectedSexe.value,
                    raceId: selectedRaceId.value,
                  ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.lapinsSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchQuery.value = '',
                      )
                    : null,
              ),
              onChanged: (value) => searchQuery.value = value,
            ),
          ),
          if (selectedStatut.value != null ||
              selectedSexe.value != null ||
              selectedRaceId.value != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (selectedStatut.value != null)
                    Chip(
                      label: Text(selectedStatut.value!.label),
                      onDeleted: () {
                        selectedStatut.value = null;
                        ref.read(lapinsProvider.notifier).setFilters(
                              statut: null,
                              sexe: selectedSexe.value,
                              raceId: selectedRaceId.value,
                            );
                      },
                    ),
                  if (selectedSexe.value != null)
                    Chip(
                      label: Text(selectedSexe.value!.label),
                      onDeleted: () {
                        selectedSexe.value = null;
                        ref.read(lapinsProvider.notifier).setFilters(
                              statut: selectedStatut.value,
                              sexe: null,
                              raceId: selectedRaceId.value,
                            );
                      },
                    ),
                  if (selectedRaceId.value != null)
                    Chip(
                      label: Text(
                        racesById[selectedRaceId.value] ?? selectedRaceId.value!,
                      ),
                      onDeleted: () {
                        selectedRaceId.value = null;
                        ref.read(lapinsProvider.notifier).setFilters(
                              statut: selectedStatut.value,
                              sexe: selectedSexe.value,
                              raceId: null,
                            );
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: lapinsState.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorDisplayWidget(
                message: e.toString(),
                onRetry: () => ref.read(lapinsProvider.notifier).refresh(),
              ),
              data: (data) {
                var lapins = data.items;

                if (searchQuery.value.isNotEmpty) {
                  lapins = lapins
                      .where(
                        (l) =>
                            l.nom.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                            (l.numeroIdentification
                                    ?.toLowerCase()
                                    .contains(searchQuery.value.toLowerCase()) ??
                                false),
                      )
                      .toList();
                }

                if (lapins.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.pets,
                    title: l10n.lapinsEmptyTitle,
                    subtitle: l10n.lapinsEmptySubtitle,
                    buttonText: l10n.lapinsEmptyAction,
                    onButtonPressed: () => context.push('/lapin/new'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(lapinsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lapins.length + (data.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= lapins.length) {
                        ref.read(lapinsProvider.notifier).loadMore();
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final lapin = lapins[index];
                      return LapinCard(lapin: lapin);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/lapin/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterBottomSheet({
    required BuildContext context,
    required List<Race> races,
    required ValueNotifier<StatutLapin?> selectedStatut,
    required ValueNotifier<SexeLapin?> selectedSexe,
    required ValueNotifier<String?> selectedRaceId,
    required VoidCallback onApply,
  }) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.lapinsFilterTitle,
                    style: AppTypography.headline3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.lapinsFilterStatut,
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: StatutLapin.values.map((statut) {
                      final isSelected = selectedStatut.value == statut;
                      return FilterChip(
                        label: Text(statut.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedStatut.value = selected ? statut : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.lapinsFilterRace,
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedRaceId.value,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.commonAll),
                      ),
                      ...races.map(
                        (race) => DropdownMenuItem<String?>(
                          value: race.id,
                          child: Text(race.nom),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        selectedRaceId.value = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.lapinsFilterSexe,
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: SexeLapin.values.map((sexe) {
                      final isSelected = selectedSexe.value == sexe;
                      return FilterChip(
                        label: Text(sexe.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedSexe.value = selected ? sexe : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              selectedStatut.value = null;
                              selectedSexe.value = null;
                              selectedRaceId.value = null;
                            });
                          },
                          child: Text(l10n.lapinsFilterReset),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onApply();
                            Navigator.pop(context);
                          },
                          child: Text(l10n.lapinsFilterApply),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
