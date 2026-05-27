import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../blocs/lapin/lapin_bloc.dart';
import '../../blocs/portee/portee_bloc.dart';
import '../../blocs/alerte/alerte_bloc.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<LapinBloc>().add(LapinsLoadRequested());
    context.read<PorteeBloc>().add(PorteesLoadRequested());
    context.read<AlerteBloc>().add(AlertesNonLuesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pets,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text('lapiNia'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.read<AlerteBloc>().add(AlertesNonLuesLoadRequested());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConseilCard(),
              const SizedBox(height: 16),
              _buildKpiGrid(),
              const SizedBox(height: 16),
              _buildAlertesSection(),
              const SizedBox(height: 16),
              _buildProchainesPorteesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConseilCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ia, Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Conseil IA du jour',
                style: AppTypography.subtitle1.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'La température prévue cette semaine est élevée. Assurez-vous que vos lapins ont accès à de l\'eau fraîche en quantité suffisante et à un espace ombragé.',
            style: AppTypography.body2.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.wb_sunny,
                color: Colors.amber,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '32°C prévu',
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    return BlocBuilder<LapinBloc, LapinState>(
      builder: (context, state) {
        int nbLapins = 0;
        int nbGestantes = 0;
        int nbLapereauxAttendus = 0;

        if (state is LapinsLoaded) {
          nbLapins = state.lapins.length;
          nbGestantes = state.lapins
              .where((l) => l.statut.dbValue == 'EN_GESTATION')
              .length;
        }

        return BlocBuilder<PorteeBloc, PorteeState>(
          builder: (context, porteeState) {
            if (porteeState is PorteesLoaded) {
              nbLapereauxAttendus = porteeState.portees
                  .where((p) => p.statut.dbValue == 'EN_GESTATION')
                  .fold(0, (sum, p) => sum + (p.mere.race?.taillePorteeMoyenne?.toInt() ?? 7));
            }

            return Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    icon: Icons.pets,
                    label: 'Lapins',
                    value: nbLapins.toString(),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    icon: Icons.pregnant_woman,
                    label: 'Gestantes',
                    value: nbGestantes.toString(),
                    color: AppColors.statutGestation,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    icon: Icons.child_friendly,
                    label: 'Attendus',
                    value: nbLapereauxAttendus.toString(),
                    color: AppColors.warning,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headline3.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.greyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alertes',
              style: AppTypography.headline3.copyWith(
                color: AppColors.textDark,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<AlerteBloc, AlerteState>(
          builder: (context, state) {
            if (state is AlertesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AlertesLoaded) {
              if (state.alertes.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aucune alerte',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: state.alertes.take(3).map((alerte) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getAlerteColor(alerte.priorite.value),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getAlerteColor(alerte.priorite.value),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alerte.type.label,
                                style: AppTypography.subtitle2,
                              ),
                              Text(
                                alerte.message,
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () {
                            context.read<AlerteBloc>().add(
                              AlerteMarkAsActionDoneRequested(id: alerte.id),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Color _getAlerteColor(int priorite) {
    switch (priorite) {
      case 1:
        return AppColors.danger;
      case 2:
        return AppColors.alert;
      default:
        return AppColors.success;
    }
  }

  Widget _buildProchainesPorteesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prochaines mises bas',
              style: AppTypography.headline3.copyWith(
                color: AppColors.textDark,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/portees'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<PorteeBloc, PorteeState>(
          builder: (context, state) {
            if (state is PorteesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PorteesLoaded) {
              final porteesGestantes = state.portees
                  .where((p) => p.statut.dbValue == 'EN_GESTATION')
                  .toList();

              if (porteesGestantes.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Aucune portée en gestation',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.greyMedium,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: porteesGestantes.take(3).map((portee) {
                  final joursEcoules = portee.joursGestationEcoules ?? 0;
                  final joursRestants = 31 - joursEcoules;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.statutGestation.withOpacity(0.1),
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
                                portee.mere?.nom ?? 'Mère',
                                style: AppTypography.subtitle2,
                              ),
                              Text(
                                'J$joursEcoules - $joursRestants jours restants',
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
                            color: _getProgressColor(joursEcoules),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${((joursEcoules / 31) * 100).toInt()}%',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Color _getProgressColor(int jours) {
    if (jours >= 28) return AppColors.danger;
    if (jours >= 21) return AppColors.alert;
    return AppColors.success;
  }
}
