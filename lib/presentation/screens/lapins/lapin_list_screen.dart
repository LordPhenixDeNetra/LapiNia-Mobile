import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/common/loading_widget.dart';

class LapinListScreen extends HookConsumerWidget {
  const LapinListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState('');
    final selectedStatut = useState<String?>(null);
    final selectedSexe = useState<String?>(null);

    final lapinsState = ref.watch(lapinsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Lapins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(
              context: context,
              selectedStatut: selectedStatut,
              selectedSexe: selectedSexe,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un lapin...',
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
          if (selectedStatut.value != null || selectedSexe.value != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (selectedStatut.value != null)
                    Chip(
                      label: Text(selectedStatut.value!),
                      onDeleted: () => selectedStatut.value = null,
                    ),
                  if (selectedSexe.value != null)
                    Chip(
                      label: Text(selectedSexe.value!),
                      onDeleted: () => selectedSexe.value = null,
                    ),
                ],
              ),
            ),
          Expanded(
            child: lapinsState.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(e.toString()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(lapinsProvider.notifier).refresh(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                var lapins = items;

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

                if (selectedStatut.value != null) {
                  lapins = lapins
                      .where((l) => l.statut.label == selectedStatut.value)
                      .toList();
                }

                if (selectedSexe.value != null) {
                  lapins = lapins
                      .where((l) => l.sexe.label == selectedSexe.value)
                      .toList();
                }

                if (lapins.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 64,
                          color: AppColors.greyLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun lapin trouvé',
                          style: AppTypography.headline3.copyWith(
                            color: AppColors.greyMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/lapin/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un lapin'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(lapinsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lapins.length,
                    itemBuilder: (context, index) {
                      final lapin = lapins[index];
                      return _buildLapinCard(context, lapin);
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

  Widget _buildLapinCard(BuildContext context, Lapin lapin) {
    final isMale = lapin.sexe == SexeLapin.male;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/lapin/${lapin.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isMale
                      ? AppColors.maleColor.withValues(alpha: 0.1)
                      : AppColors.femelleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  isMale ? Icons.male : Icons.female,
                  color: isMale ? AppColors.maleColor : AppColors.femelleColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lapin.nom,
                            style: AppTypography.subtitle1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatutColor(lapin.statut),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            lapin.statut.label,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lapin.race?.nom ?? 'Race inconnue',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.greyMedium,
                      ),
                    ),
                    if (lapin.poidsActuelG != null)
                      Text(
                        '${(lapin.poidsActuelG! / 1000).toStringAsFixed(2)} kg',
                        style: AppTypography.body2,
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.greyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatutColor(StatutLapin statut) {
    switch (statut) {
      case StatutLapin.repos:
        return AppColors.statutRepos;
      case StatutLapin.enGestation:
        return AppColors.statutGestation;
      case StatutLapin.lactation:
        return AppColors.statutLactation;
      case StatutLapin.malade:
        return AppColors.statutMalade;
      case StatutLapin.disponibleSaillie:
        return AppColors.statutDisponible;
      case StatutLapin.engraissement:
        return AppColors.statutEngraissement;
      default:
        return AppColors.greyMedium;
    }
  }

  void _showFilterBottomSheet({
    required BuildContext context,
    required ValueNotifier<String?> selectedStatut,
    required ValueNotifier<String?> selectedSexe,
  }) {
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
                    'Filtrer',
                    style: AppTypography.headline3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Statut',
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: StatutLapin.values.map((statut) {
                      final isSelected = selectedStatut.value == statut.label;
                      return FilterChip(
                        label: Text(statut.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedStatut.value = selected ? statut.label : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sexe',
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: SexeLapin.values.map((sexe) {
                      final isSelected = selectedSexe.value == sexe.label;
                      return FilterChip(
                        label: Text(sexe.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedSexe.value = selected ? sexe.label : null;
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
                            });
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Appliquer'),
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
