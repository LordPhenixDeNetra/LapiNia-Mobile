import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../blocs/portee/portee_bloc.dart';
import '../../widgets/common/loading_widget.dart';

class PorteeDetailScreen extends StatefulWidget {
  final String porteeId;

  const PorteeDetailScreen({super.key, required this.porteeId});

  @override
  State<PorteeDetailScreen> createState() => _PorteeDetailScreenState();
}

class _PorteeDetailScreenState extends State<PorteeDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PorteeBloc>().add(PorteeLoadRequested(id: widget.porteeId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PorteeBloc, PorteeState>(
      builder: (context, state) {
        if (state is PorteeLoading) {
          return const Scaffold(body: LoadingWidget());
        }
        if (state is PorteeLoaded) {
          final portee = state.portee;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text('Portée de ${portee.mere?.nom ?? "Mère"}'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimelineCard(portee),
                  const SizedBox(height: 16),
                  _buildInfoCard(portee),
                  const SizedBox(height: 16),
                  if (portee.statut == StatutPortee.enGestation)
                    _buildActionsCard(portee),
                  if (portee.statut == StatutPortee.lactation)
                    _buildLactationCard(portee),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Erreur de chargement')),
        );
      },
    );
  }

  Widget _buildTimelineCard(portee) {
    final joursEcoules = portee.joursGestationEcoules ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline de gestation',
            style: AppTypography.headline3,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildTimelineStep('J7', 'Implantation', joursEcoules >= 7),
              _buildTimelineLine(joursEcoules >= 14),
              _buildTimelineStep('J14', 'Contrôle', joursEcoules >= 14),
              _buildTimelineLine(joursEcoules >= 25),
              _buildTimelineStep('J25', 'Nid prêt', joursEcoules >= 25),
              _buildTimelineLine(joursEcoules >= 28),
              _buildTimelineStep('J28-31', 'Mise bas', joursEcoules >= 28),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  'J$joursEcoules',
                  style: AppTypography.headline1.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'sur 31 jours de gestation',
                  style: AppTypography.body2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: joursEcoules / 31,
            backgroundColor: AppColors.greyLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, String description, bool isComplete) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isComplete ? AppColors.primary : AppColors.greyLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isComplete ? Icons.check : Icons.circle_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isComplete ? AppColors.primary : AppColors.greyMedium,
            fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          description,
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            color: AppColors.greyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isComplete) {
    return Expanded(
      child: Container(
        height: 2,
        color: isComplete ? AppColors.primary : AppColors.greyLight,
      ),
    );
  }

  Widget _buildInfoCard(portee) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: AppTypography.headline3,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Mère',
            portee.mere?.nom ?? 'Inconnue',
            Icons.female,
          ),
          _buildInfoRow(
            'Père',
            portee.pere?.nom ?? 'Inconnu',
            Icons.male,
          ),
          _buildInfoRow(
            'Date de saillie',
            '${portee.dateSaillie.day}/${portee.dateSaillie.month}/${portee.dateSaillie.year}',
            Icons.calendar_today,
          ),
          if (portee.dateMiseBasPrevue != null)
            _buildInfoRow(
              'Mise bas prévue',
              '${portee.dateMiseBasPrevue!.day}/${portee.dateMiseBasPrevue!.month}/${portee.dateMiseBasPrevue!.year}',
              Icons.event,
            ),
          if (portee.dateMiseBasReelle != null)
            _buildInfoRow(
              'Mise bas réelle',
              '${portee.dateMiseBasReelle!.day}/${portee.dateMiseBasReelle!.month}/${portee.dateMiseBasReelle!.year}',
              Icons.event_available,
            ),
          _buildInfoRow(
            'Statut',
            portee.statut.label,
            Icons.info,
          ),
          if (portee.nbVivants > 0 || portee.nbMorts > 0)
            _buildInfoRow(
              'Résultats',
              '${portee.nbVivants} vivants, ${portee.nbMorts} morts',
              Icons.analytics,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.greyMedium),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.body2.copyWith(color: AppColors.greyMedium),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.body2,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(portee) {
    final joursEcoules = portee.joursGestationEcoules ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: AppTypography.headline3,
          ),
          const SizedBox(height: 16),
          if (joursEcoules >= 28)
            ElevatedButton.icon(
              onPressed: () => _showMiseBasDialog(portee),
              icon: const Icon(Icons.child_friendly),
              label: const Text('Enregistrer la mise bas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
            ),
          if (joursEcoules >= 25 && joursEcoules < 28) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.alert.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: AppColors.alert),
                      const SizedBox(width: 8),
                      Text(
                        'Préparez le nid !',
                        style: AppTypography.subtitle1.copyWith(
                          color: AppColors.alert,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Cage maternité prête\n'
                    '• Nid garni de foin\n'
                    '• Température 28-30°C\n'
                    '• Eau et nourriture abondantes',
                    style: AppTypography.body2,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLactationCard(portee) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lactation',
            style: AppTypography.headline3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Vivants',
                portee.nbVivants.toString(),
                AppColors.success,
              ),
              _buildStatCard(
                'Morts',
                portee.nbMorts.toString(),
                AppColors.danger,
              ),
              _buildStatCard(
                'Total',
                portee.nbTotal.toString(),
                AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Pesées recommandées',
            style: AppTypography.subtitle1,
          ),
          const SizedBox(height: 8),
          Text(
            'J1, J7, J14, J21',
            style: AppTypography.body2,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.scale),
            label: const Text('Enregistrer une pesée'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showSevrageDialog(portee),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Enregistrer le sevrage'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headline2.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  void _showMiseBasDialog(portee) {
    final nbVivantsController = TextEditingController();
    final nbMortsController = TextEditingController();
    final poidsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enregistrer la mise bas'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nbVivantsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de vivants',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nbMortsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de morts-nés',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: poidsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Poids total de la portée (grammes)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PorteeBloc>().add(
                  MiseBasRecordRequested(
                    porteeId: portee.id,
                    mereId: portee.mereId,
                    dateMiseBas: DateTime.now(),
                    nbVivants: int.tryParse(nbVivantsController.text) ?? 0,
                    nbMorts: int.tryParse(nbMortsController.text) ?? 0,
                    poidsTotalG: int.tryParse(poidsController.text) ?? 0,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _showSevrageDialog(portee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enregistrer le sevrage'),
          content: const Text(
            'Êtes-vous sûr de vouloir enregistrer le sevrage de cette portée ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PorteeBloc>().add(
                  SevrageRecordRequested(
                    porteeId: portee.id,
                    mereId: portee.mereId,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
