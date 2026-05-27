import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../blocs/lapin/lapin_bloc.dart';
import '../../widgets/common/loading_widget.dart';

class LapinListScreen extends StatefulWidget {
  const LapinListScreen({super.key});

  @override
  State<LapinListScreen> createState() => _LapinListScreenState();
}

class _LapinListScreenState extends State<LapinListScreen> {
  String _searchQuery = '';
  String? _selectedStatut;
  String? _selectedSexe;

  @override
  void initState() {
    super.initState();
    context.read<LapinBloc>().add(LapinsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Lapins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
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
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_selectedStatut != null || _selectedSexe != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedStatut != null)
                    Chip(
                      label: Text(_selectedStatut!),
                      onDeleted: () {
                        setState(() {
                          _selectedStatut = null;
                        });
                      },
                    ),
                  if (_selectedSexe != null)
                    Chip(
                      label: Text(_selectedSexe!),
                      onDeleted: () {
                        setState(() {
                          _selectedSexe = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<LapinBloc, LapinState>(
              builder: (context, state) {
                if (state is LapinsLoading) {
                  return const LoadingWidget();
                }
                if (state is LapinsLoaded) {
                  var lapins = state.lapins;

                  if (_searchQuery.isNotEmpty) {
                    lapins = lapins
                        .where((l) =>
                            l.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            (l.numeroIdentification?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
                        .toList();
                  }

                  if (_selectedStatut != null) {
                    lapins = lapins
                        .where((l) => l.statut.label == _selectedStatut)
                        .toList();
                  }

                  if (_selectedSexe != null) {
                    lapins = lapins
                        .where((l) => l.sexe.label == _selectedSexe)
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
                    onRefresh: () async {
                      context.read<LapinBloc>().add(LapinsLoadRequested());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: lapins.length,
                      itemBuilder: (context, index) {
                        final lapin = lapins[index];
                        return _buildLapinCard(lapin);
                      },
                    ),
                  );
                }
                if (state is LapinError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.danger,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<LapinBloc>().add(LapinsLoadRequested());
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
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

  Widget _buildLapinCard(lapin) {
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
                      ? AppColors.maleColor.withOpacity(0.1)
                      : AppColors.femelleColor.withOpacity(0.1),
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

  void _showFilterBottomSheet() {
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
                      final isSelected = _selectedStatut == statut.label;
                      return FilterChip(
                        label: Text(statut.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedStatut = selected ? statut.label : null;
                          });
                          setState(() {});
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
                      final isSelected = _selectedSexe == sexe.label;
                      return FilterChip(
                        label: Text(sexe.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedSexe = selected ? sexe.label : null;
                          });
                          setState(() {});
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
                              _selectedStatut = null;
                              _selectedSexe = null;
                            });
                            setState(() {});
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
