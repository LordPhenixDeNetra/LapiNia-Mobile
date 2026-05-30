import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/lapereau.dart';
import '../../providers/lapereau_provider.dart';
import '../../widgets/common/connectivity_banner.dart';
import '../../widgets/common/loading_widget.dart';

class LapereauxScreen extends HookConsumerWidget {
  final String porteeId;

  const LapereauxScreen({super.key, required this.porteeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lapereauxAsync = ref.watch(lapereauxProvider(porteeId));

    Future<void> editLapereau(Lapereau lapereau) async {
      final poidsController = TextEditingController(
        text: lapereau.poidsNaissanceG?.toString() ?? '',
      );
      var sexe = lapereau.sexe;
      var statut = lapereau.statut;

      final result = await showModalBottomSheet<Lapereau>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.lapereauEditTitle, style: AppTypography.subtitle1),
                const SizedBox(height: 12),
                DropdownButtonFormField<SexeLapin?>(
                  initialValue: sexe,
                  decoration: InputDecoration(labelText: l10n.lapereauSexeLabel),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('—')),
                    DropdownMenuItem(value: SexeLapin.male, child: Text('M')),
                    DropdownMenuItem(value: SexeLapin.femelle, child: Text('F')),
                  ],
                  onChanged: (v) => sexe = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<StatutLapereau>(
                  initialValue: statut,
                  decoration: InputDecoration(labelText: l10n.lapereauStatutLabel),
                  items: StatutLapereau.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    statut = v;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: poidsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.lapereauPoidsNaissanceLabel),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final next = lapereau.copyWith(
                            sexe: sexe,
                            statut: statut,
                            poidsNaissanceG: int.tryParse(poidsController.text.trim()),
                          );
                          Navigator.pop(context, next);
                        },
                        child: Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );

      if (result == null) return;
      await ref.read(lapereauxProvider(porteeId).notifier).updateLapereau(result);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lapereauxTitle)),
      body: lapereauxAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplayWidget(
          message: e.toString(),
          onRetry: () => ref.read(lapereauxProvider(porteeId).notifier).refresh(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Column(
              children: [
                const ConnectivityBanner(),
                Expanded(
                  child: EmptyStateWidget(
                    icon: Icons.child_friendly,
                    title: l10n.lapereauxEmpty,
                    subtitle: l10n.lapereauxEmptySubtitle,
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(lapereauxProvider(porteeId).notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) return const ConnectivityBanner();
                final lapereau = items[i - 1];
                return ListTile(
                  title: Text('${l10n.lapereauLabel} #$i'),
                  subtitle: Text(
                    '${l10n.lapereauStatutLabel}: ${lapereau.statut.label}'
                    '${lapereau.poidsNaissanceG != null ? ' • ${lapereau.poidsNaissanceG}g' : ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => editLapereau(lapereau),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
