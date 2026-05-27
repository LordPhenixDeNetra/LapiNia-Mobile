import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/portee.dart';
import '../../blocs/portee/portee_bloc.dart';
import '../../widgets/common/loading_widget.dart';

class PorteeListScreen extends StatefulWidget {
  const PorteeListScreen({super.key});

  @override
  State<PorteeListScreen> createState() => _PorteeListScreenState();
}

class _PorteeListScreenState extends State<PorteeListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<PorteeBloc>().add(PorteesLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Portées'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'En gestation'),
            Tab(text: 'Lactation'),
            Tab(text: 'Terminées'),
          ],
        ),
      ),
      body: BlocBuilder<PorteeBloc, PorteeState>(
        builder: (context, state) {
          if (state is PorteesLoading) {
            return const LoadingWidget();
          }
          if (state is PorteesLoaded) {
            final enGest = state.portees
                .where((p) => p.statut == StatutPortee.enGestation)
                .toList();
            final enLact = state.portees
                .where((p) => p.statut == StatutPortee.lactation)
                .toList();
            final terminees = state.portees
                .where((p) =>
                    p.statut == StatutPortee.sevrage ||
                    p.statut == StatutPortee.terminee)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildPorteeList(enGest, 'en gestation'),
                _buildPorteeList(enLact, 'en lactation'),
                _buildPorteeList(terminees, 'terminées'),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/saillie/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPorteeList(List portees, String emptyMessage) {
    if (portees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_friendly,
              size: 64,
              color: AppColors.greyLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune portée $emptyMessage',
              style: AppTypography.body1.copyWith(
                color: AppColors.greyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PorteeBloc>().add(PorteesLoadRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: portees.length,
        itemBuilder: (context, index) {
          final portee = portees[index];
          return _buildPorteeCard(portee);
        },
      ),
    );
  }

  Widget _buildPorteeCard(Portee portee) {
    final joursEcoules = portee.joursGestationEcoules ?? 0;
    final joursRestants = 31 - joursEcoules;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/portee/${portee.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.statutGestation.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.child_friendly,
                      color: AppColors.statutGestation,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portée de ${portee.mere?.nom ?? "Mère"}',
                          style: AppTypography.subtitle1,
                        ),
                        Text(
                          ' Père: ${portee.pere?.nom ?? "Inconnu"}',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatutColor(portee.statut),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      portee.statut.label,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (portee.statut == StatutPortee.enGestation) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jours: $joursEcoules / 31',
                      style: AppTypography.body2,
                    ),
                    Text(
                      '$joursRestants jours restants',
                      style: AppTypography.caption.copyWith(
                        color: _getProgressColor(joursEcoules),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: joursEcoules / 31,
                  backgroundColor: AppColors.greyLight,
                  valueColor: AlwaysStoppedAnimation(
                    _getProgressColor(joursEcoules),
                  ),
                ),
              ],
              if (portee.statut == StatutPortee.lactation) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Vivants',
                      portee.nbVivants.toString(),
                      AppColors.success,
                    ),
                    _buildStatItem(
                      'Morts',
                      portee.nbMorts.toString(),
                      AppColors.danger,
                    ),
                    _buildStatItem(
                      'Poids',
                      '${portee.poidsTotalPorteeG ?? 0}g',
                      AppColors.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headline3.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Color _getStatutColor(StatutPortee statut) {
    switch (statut) {
      case StatutPortee.enGestation:
        return AppColors.statutGestation;
      case StatutPortee.miseBas:
        return AppColors.warning;
      case StatutPortee.lactation:
        return AppColors.statutLactation;
      case StatutPortee.sevrage:
        return AppColors.primary;
      case StatutPortee.terminee:
        return AppColors.greyMedium;
    }
  }

  Color _getProgressColor(int jours) {
    if (jours >= 28) return AppColors.danger;
    if (jours >= 21) return AppColors.alert;
    return AppColors.success;
  }
}
