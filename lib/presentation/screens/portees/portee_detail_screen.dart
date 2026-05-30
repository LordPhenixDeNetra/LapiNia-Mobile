import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/models/portee.dart';
import '../../providers/lapereau_provider.dart';
import '../../providers/portee_provider.dart';
import '../../widgets/portees/gestation_timeline.dart';
import '../../widgets/portees/pre_mise_bas_checklist_card.dart';

class PorteeDetailScreen extends HookConsumerWidget {
  final String porteeId;

  const PorteeDetailScreen({super.key, required this.porteeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final porteeAsync = ref.watch(porteeDetailProvider(porteeId));
    final isSaving = useState(false);

    Future<StatutLapereau?> pickDefaultDestination() async {
      var selected = StatutLapereau.conserve;
      return showDialog<StatutLapereau>(
        context: context,
        builder: (context) {
          String labelFor(StatutLapereau value) {
            switch (value) {
              case StatutLapereau.conserve:
                return l10n.lapereauDestinationConserve;
              case StatutLapereau.vendu:
                return l10n.lapereauDestinationVendu;
              case StatutLapereau.consomme:
                return l10n.lapereauDestinationConsomme;
              case StatutLapereau.vivant:
              case StatutLapereau.mort:
                return value.label;
            }
          }

          return AlertDialog(
            title: Text(l10n.sevrageDestinationDialogTitle),
            content: StatefulBuilder(
              builder: (context, setState) {
                return DropdownButtonFormField<StatutLapereau>(
                  initialValue: selected,
                  items: const [
                    StatutLapereau.conserve,
                    StatutLapereau.vendu,
                    StatutLapereau.consomme,
                  ]
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(labelFor(v)),
                        ),
                      )
                      .toList(),
                  onChanged: (next) {
                    if (next == null) return;
                    setState(() => selected = next);
                  },
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, selected),
                child: Text(l10n.confirm),
              ),
            ],
          );
        },
      );
    }

    Future<void> recordSevrage(Portee portee) async {
      final destination = await pickDefaultDestination();
      if (destination == null) return;

      isSaving.value = true;
      try {
        await ref.read(porteesProvider.notifier).recordSevrage(
              porteeId: portee.id,
              mereId: portee.mereId,
              defaultDestination: destination,
            );
        ref.invalidate(porteeDetailProvider(porteeId));
        ref.invalidate(lapereauxProvider(porteeId));
      } finally {
        isSaving.value = false;
      }
    }

    return porteeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.porteeDetailTitle)),
        body: Center(child: Text(e.toString())),
      ),
      data: (portee) {
        final mere = portee.mere?.nom ?? l10n.motherFallback;
        final pere = portee.pere?.nom ?? l10n.fatherFallback;
        final dateText = formatDate(context, portee.dateSaillie);
        final gestationDays = portee.joursGestationEcoules;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.porteeDetailTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  final router = GoRouter.of(context);
                  if (router.canPop()) {
                    router.pop();
                    return;
                  }
                  context.go('/portees');
                },
              ),
            ],
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
                      Text(l10n.porteeInfoSection, style: AppTypography.subtitle1),
                      const SizedBox(height: 12),
                      _row(context, l10n.motherLabel, mere),
                      _row(context, l10n.fatherLabel, pere),
                      _row(context, l10n.statusLabel, portee.statut.label),
                      _row(context, l10n.saillieDateLabel, dateText),
                      if (portee.dateMiseBasPrevue != null)
                        _row(
                          context,
                          l10n.expectedBirthDateLabel,
                          formatDate(context, portee.dateMiseBasPrevue!),
                        ),
                      _row(context, l10n.nbVivantsLabel, portee.nbVivants.toString()),
                      _row(context, l10n.nbMortsLabel, portee.nbMorts.toString()),
                      if (portee.notes != null && portee.notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(l10n.notes, style: AppTypography.subtitle1),
                        const SizedBox(height: 6),
                        Text(portee.notes!, style: AppTypography.body2),
                      ],
                    ],
                  ),
                ),
              ),
              if (portee.statut == StatutPortee.enGestation && gestationDays != null) ...[
                const SizedBox(height: 12),
                GestationTimeline(elapsedDays: gestationDays),
                if (gestationDays >= 25) ...[
                  const SizedBox(height: 12),
                  PreMiseBasChecklistCard(porteeId: portee.id),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed:
                      isSaving.value ? null : () => context.push('/portee/${portee.id}/mise-bas'),
                  child: Text(l10n.recordMiseBasCta),
                ),
              ],
              if (portee.statut == StatutPortee.lactation ||
                  portee.statut == StatutPortee.sevrage ||
                  portee.statut == StatutPortee.terminee) ...[
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: isSaving.value
                      ? null
                      : () => context.push('/portee/${portee.id}/lapereaux'),
                  child: Text(l10n.lapereauxCta),
                ),
              ],
              if (portee.statut == StatutPortee.lactation) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: isSaving.value ? null : () => recordSevrage(portee),
                  child: Text(l10n.recordSevrageCta),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.body2.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.body2,
            ),
          ),
        ],
      ),
    );
  }
}
