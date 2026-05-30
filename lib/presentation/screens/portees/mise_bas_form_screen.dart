import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/models/lapereau.dart';
import '../../providers/core_providers.dart';
import '../../providers/lapereau_provider.dart';
import '../../providers/portee_provider.dart';
import '../../widgets/common/loading_widget.dart';

class MiseBasFormScreen extends HookConsumerWidget {
  final String porteeId;

  const MiseBasFormScreen({super.key, required this.porteeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isSaving = useState(false);
    final dateMiseBas = useState<DateTime>(DateTime.now());
    final nbVivantsController = useTextEditingController(text: '0');
    final nbMortsController = useTextEditingController(text: '0');
    final poidsTotalController = useTextEditingController(text: '0');

    final porteeAsync = ref.watch(porteeDetailProvider(porteeId));

    Future<void> selectDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: dateMiseBas.value,
        firstDate: DateTime(2010),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        dateMiseBas.value = picked;
      }
    }

    Future<void> submit() async {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final nbVivants = int.tryParse(nbVivantsController.text.trim()) ?? 0;
      final nbMorts = int.tryParse(nbMortsController.text.trim()) ?? 0;
      final poidsTotal = int.tryParse(poidsTotalController.text.trim()) ?? 0;

      if (nbVivants < 0 || nbMorts < 0 || poidsTotal < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invalidNumber)),
        );
        return;
      }

      isSaving.value = true;
      try {
        final portee = porteeAsync.asData?.value;
        if (portee == null) return;

        await ref.read(porteesProvider.notifier).recordMiseBas(
              porteeId: portee.id,
              mereId: portee.mereId,
              dateMiseBas: dateMiseBas.value,
              nbVivants: nbVivants,
              nbMorts: nbMorts,
              poidsTotalG: poidsTotal,
            );

        final uuid = const Uuid();
        final now = DateTime.now();
        final lapereaux = <Lapereau>[
          for (int i = 0; i < nbVivants; i++)
            Lapereau(
              id: uuid.v4(),
              porteeId: portee.id,
              userId: userId,
              sexe: null,
              poidsNaissanceG: null,
              dateSevrage: null,
              statut: StatutLapereau.vivant,
              lapinId: null,
              createdAt: now,
            ),
          for (int i = 0; i < nbMorts; i++)
            Lapereau(
              id: uuid.v4(),
              porteeId: portee.id,
              userId: userId,
              sexe: null,
              poidsNaissanceG: null,
              dateSevrage: null,
              statut: StatutLapereau.mort,
              lapinId: null,
              createdAt: now,
            ),
        ];

        if (lapereaux.isNotEmpty) {
          await ref.read(lapereauxProvider(portee.id).notifier).createBatch(lapereaux);
        }

        if (!context.mounted) return;
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        isSaving.value = false;
      }
    }

    return porteeAsync.when(
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.miseBasTitle)),
        body: ErrorDisplayWidget(message: e.toString(), onRetry: () => ref.invalidate(porteeDetailProvider(porteeId))),
      ),
      data: (portee) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.miseBasTitle)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.motherLabel}: ${portee.mere?.nom ?? ''}'),
                const SizedBox(height: 16),
                Text(l10n.miseBasDateLabel),
                const SizedBox(height: 8),
                InkWell(
                  onTap: selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 12),
                        Text(
                          '${dateMiseBas.value.day}/${dateMiseBas.value.month}/${dateMiseBas.value.year}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nbVivantsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.nbVivantsLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nbMortsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.nbMortsLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: poidsTotalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.poidsTotalPorteeLabel),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: isSaving.value ? null : submit,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

