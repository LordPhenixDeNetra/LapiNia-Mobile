import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../blocs/lapin/lapin_bloc.dart';
import '../../widgets/common/loading_widget.dart';

class LapinDetailScreen extends StatefulWidget {
  final String lapinId;

  const LapinDetailScreen({super.key, required this.lapinId});

  @override
  State<LapinDetailScreen> createState() => _LapinDetailScreenState();
}

class _LapinDetailScreenState extends State<LapinDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<LapinBloc>().add(LapinLoadRequested(id: widget.lapinId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LapinBloc, LapinState>(
      builder: (context, state) {
        if (state is LapinLoading) {
          return const Scaffold(
            body: LoadingWidget(),
          );
        }
        if (state is LapinLoaded) {
          final lapin = state.lapin;
          final isMale = lapin.sexe == SexeLapin.male;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isMale ? AppColors.maleColor : AppColors.femelleColor,
                              (isMale ? AppColors.maleColor : AppColors.femelleColor)
                                  .withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Icon(
                                  isMale ? Icons.male : Icons.female,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                lapin.nom,
                                style: AppTypography.headline2.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                lapin.race?.nom ?? 'Race inconnue',
                                style: AppTypography.body2.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => context.push('/lapin/${lapin.id}/edit'),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteDialog(context);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: AppColors.danger),
                                SizedBox(width: 8),
                                Text('Supprimer'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.greyMedium,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(text: 'Croissance'),
                          Tab(text: 'Santé'),
                          Tab(text: 'Portées'),
                          Tab(text: 'Infos'),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildCroissanceTab(lapin),
                  _buildSanteTab(lapin),
                  _buildPorteesTab(lapin),
                  _buildInfosTab(lapin),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showPeserDialog(context, lapin),
              child: const Icon(Icons.scale),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text('Erreur de chargement'),
          ),
        );
      },
    );
  }

  Widget _buildCroissanceTab(lapin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Poids actuel',
            value: lapin.poidsKg != null
                ? '${lapin.poidsKg!.toStringAsFixed(2)} kg'
                : 'Non pesé',
            icon: Icons.scale,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Âge',
            value: lapin.ageFormate ?? 'Inconnu',
            icon: Icons.calendar_today,
            color: AppColors.statutGestation,
          ),
          const SizedBox(height: 24),
          Text(
            'Courbe de croissance',
            style: AppTypography.headline3,
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildGrowthChart(lapin),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(lapin) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  'S${value.toInt()}',
                  style: AppTypography.caption,
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}g',
                  style: AppTypography.caption,
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minY: 0,
        maxY: lapin.race?.poidsAdulteMaxKg != null
            ? (lapin.race!.poidsAdulteMaxKg! * 1000)
            : 5000,
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 80),
              FlSpot(4, 400),
              FlSpot(8, 1200),
              FlSpot(12, 2500),
              if (lapin.poidsActuelG != null)
                FlSpot(14, lapin.poidsActuelG!.toDouble()),
            ],
            isCurved: true,
            color: AppColors.graphiqueCroissance,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: [
              FlSpot(0, 80),
              FlSpot(4, 500),
              FlSpot(8, 1500),
              FlSpot(12, 3000),
              FlSpot(16, 4500),
            ],
            isCurved: true,
            color: AppColors.graphiqueCible.withOpacity(0.5),
            barWidth: 2,
            dashArray: [5, 5],
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildSanteTab(lapin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Statut',
            value: lapin.statut.label,
            icon: Icons.health_and_safety,
            color: _getStatutColor(lapin.statut),
          ),
          const SizedBox(height: 24),
          Text(
            'Historique santé',
            style: AppTypography.headline3,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 48,
                    color: AppColors.greyLight,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun événement de santé',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.greyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPorteesTab(lapin) {
    if (lapin.sexe == SexeLapin.male) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.male,
              size: 64,
              color: AppColors.maleColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Les mâles ne peuvent pas avoir de portées',
              style: AppTypography.body1.copyWith(
                color: AppColors.greyMedium,
              ),
            ),
          ],
        ),
      );
    }

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
            'Aucune portée',
            style: AppTypography.body1.copyWith(
              color: AppColors.greyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/saillie/new?mereId=${lapin.id}'),
            icon: const Icon(Icons.add),
            label: const Text('Enregistrer une saillie'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfosTab(lapin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Numéro', lapin.numeroIdentification ?? 'Non assigné'),
          _buildInfoRow('Race', lapin.race?.nom ?? 'Inconnue'),
          _buildInfoRow('Sexe', lapin.sexe.label),
          _buildInfoRow(
            'Date de naissance',
            lapin.dateNaissance != null
                ? '${lapin.dateNaissance!.day}/${lapin.dateNaissance!.month}/${lapin.dateNaissance!.year}'
                : 'Inconnue',
          ),
          _buildInfoRow('Âge', lapin.ageFormate ?? 'Inconnu'),
          _buildInfoRow('Poids actuel', lapin.poidsKg != null ? '${lapin.poidsKg} kg' : 'Non pesé'),
          _buildInfoRow('Statut', lapin.statut.label),
          if (lapin.notes != null && lapin.notes!.isNotEmpty)
            _buildInfoRow('Notes', lapin.notes!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.body2.copyWith(
                color: AppColors.greyMedium,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.greyMedium,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.subtitle1,
                ),
              ],
            ),
          ),
        ],
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
      default:
        return AppColors.greyMedium;
    }
  }

  void _showPeserDialog(BuildContext context, lapin) {
    final controller = TextEditingController(
      text: lapin.poidsActuelG?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nouvelle pesée - ${lapin.nom}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Poids (grammes)',
              suffixText: 'g',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final poidsG = int.tryParse(controller.text);
                if (poidsG != null) {
                  context.read<LapinBloc>().add(
                    LapinPeserRequested(lapinId: lapin.id, poidsG: poidsG),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer ce lapin ?'),
          content: const Text(
            'Cette action est irréversible. Toutes les données associées seront supprimées.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () {
                context.read<LapinBloc>().add(
                  LapinDeleteRequested(id: widget.lapinId),
                );
                Navigator.pop(context);
                context.go('/lapins');
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
