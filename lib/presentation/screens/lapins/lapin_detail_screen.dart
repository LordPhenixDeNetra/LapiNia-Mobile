import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/lapin.dart';
import '../../providers/lapin_provider.dart';

class LapinDetailScreen extends ConsumerWidget {
  final String lapinId;

  const LapinDetailScreen({super.key, required this.lapinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lapinAsync = ref.watch(lapinDetailProvider(lapinId));

    Future<void> deleteLapin(Lapin lapin) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Supprimer'),
          content: Text('Supprimer ${lapin.nom} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );
      if (ok != true) return;

      await ref.read(lapinsProvider.notifier).remove(lapin.id);
      if (!context.mounted) return;
      context.pop();
    }

    Future<void> recordPesee() async {
      final poidsController = TextEditingController();
      final poids = await showDialog<int?>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ajouter une pesée'),
          content: TextField(
            controller: poidsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Poids (g)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, int.tryParse(poidsController.text));
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      );

      if (poids == null) return;
      await ref
          .read(lapinsProvider.notifier)
          .recordPesee(lapinId: lapinId, poidsG: poids);
      ref.invalidate(lapinDetailProvider(lapinId));
      await ref.read(lapinsProvider.notifier).refresh();
    }

    return lapinAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Lapin')),
        body: Center(child: Text(e.toString())),
      ),
      data: (lapin) {
        final poidsKg = lapin.poidsKg;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(lapin.nom),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/lapin/${lapin.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => deleteLapin(lapin),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: recordPesee,
            icon: const Icon(Icons.scale),
            label: const Text('Peser'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Infos', style: AppTypography.subtitle1),
                      const SizedBox(height: 12),
                      _row('Race', lapin.race?.nom ?? '—'),
                      _row('Sexe', lapin.sexe.label),
                      _row('Statut', lapin.statut.label),
                      _row(
                        'Poids',
                        poidsKg != null
                            ? '${poidsKg.toStringAsFixed(2)} kg'
                            : '—',
                      ),
                      _row('Âge', lapin.ageFormate ?? '—'),
                      if (lapin.numeroIdentification != null)
                        _row('ID', lapin.numeroIdentification!),
                    ],
                  ),
                ),
              ),
              if (lapin.notes != null && lapin.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notes', style: AppTypography.subtitle1),
                        const SizedBox(height: 8),
                        Text(lapin.notes!, style: AppTypography.body2),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.body2.copyWith(color: AppColors.greyMedium),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.body2.copyWith(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
