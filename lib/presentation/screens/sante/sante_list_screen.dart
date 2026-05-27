import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../blocs/sante/sante_bloc.dart';
import '../../widgets/common/loading_widget.dart';

class SanteListScreen extends StatefulWidget {
  const SanteListScreen({super.key});

  @override
  State<SanteListScreen> createState() => _SanteListScreenState();
}

class _SanteListScreenState extends State<SanteListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SanteBloc>().add(SanteLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Santé'),
      ),
      body: BlocBuilder<SanteBloc, SanteState>(
        builder: (context, state) {
          if (state is SanteLoading) {
            return const LoadingWidget();
          }
          if (state is SanteLoaded) {
            if (state.evenements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 64,
                      color: AppColors.greyLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun événement de santé',
                      style: AppTypography.headline3.copyWith(
                        color: AppColors.greyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.evenements.length,
              itemBuilder: (context, index) {
                final evenement = state.evenements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTypeColor(evenement.type.dbValue),
                      child: Icon(
                        _getTypeIcon(evenement.type.dbValue),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(evenement.lapin?.nom ?? 'Lapin inconnu'),
                    subtitle: Text(
                      '${evenement.type.label} - ${evenement.date.day}/${evenement.date.month}',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: evenement.statut.dbValue == 'EN_COURS'
                            ? AppColors.warning
                            : AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        evenement.statut.label,
                        style: AppTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'MALADIE':
        return AppColors.danger;
      case 'VACCIN':
        return AppColors.primary;
      case 'TRAITEMENT':
        return AppColors.warning;
      default:
        return AppColors.greyMedium;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'MALADIE':
        return Icons.sick;
      case 'VACCIN':
        return Icons.vaccines;
      case 'TRAITEMENT':
        return Icons.medication;
      default:
        return Icons.medical_services;
    }
  }

  void _showAddDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en développement')),
    );
  }
}
