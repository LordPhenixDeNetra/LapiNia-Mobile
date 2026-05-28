import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class LapinDetailScreen extends ConsumerWidget {
  final String lapinId;

  const LapinDetailScreen({super.key, required this.lapinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lapinAsync = ref.watch(lapinDetailProvider(lapinId));

    Future<void> deleteLapin(Lapin lapin) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteConfirmTitle),
          content: Text(l10n.deleteConfirmBody(lapin.nom)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete),
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
          title: Text(l10n.lapinAddWeightTitle),
          content: TextField(
            controller: poidsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.lapinWeightGramLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, int.tryParse(poidsController.text));
              },
              child: Text(l10n.save),
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
        body: LoadingWidget(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.lapinTitle)),
        body: ErrorDisplayWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(lapinDetailProvider(lapinId)),
        ),
      ),
      data: (lapin) {
        final poidsKg = lapin.poidsKg;
        return Scaffold(
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
            label: Text(l10n.quickEventWeight),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ConnectivityBanner(),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.lapinInfoSection, style: AppTypography.subtitle1),
                      const SizedBox(height: 12),
                      _row(context, l10n.lapinFieldRace, lapin.race?.nom ?? '—'),
                      _row(context, l10n.lapinFieldSexe, lapin.sexe.label),
                      _row(context, l10n.lapinFieldStatut, lapin.statut.label),
                      _row(
                        context,
                        l10n.lapinFieldPoids,
                        poidsKg != null
                            ? '${poidsKg.toStringAsFixed(2)} kg'
                            : '—',
                      ),
                      _row(context, l10n.lapinFieldAge, lapin.ageFormate ?? '—'),
                      if (lapin.numeroIdentification != null)
                        _row(context, l10n.lapinFieldId, lapin.numeroIdentification!),
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
                        Text(l10n.lapinNotesSection, style: AppTypography.subtitle1),
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

  Widget _row(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.body2.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.body2.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
