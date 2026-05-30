import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/consanguinity.dart';
import '../../../core/models/portee.dart';
import '../../providers/core_providers.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/portee_provider.dart';

class SaillieFormScreen extends HookConsumerWidget {
  final String? mereId;

  const SaillieFormScreen({super.key, this.mereId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedMereId = useState<String?>(mereId);
    final selectedPereId = useState<String?>(null);
    final dateSaillie = useState<DateTime>(DateTime.now());
    final isSaving = useState(false);
    final notesController = useTextEditingController();
    final consanguinity = useState<ConsanguinityResult?>(null);
    final consanguinityError = useState<String?>(null);

    final lapins = ref.watch(lapinsProvider);
    final connectivity = ref.watch(connectivityCheckerProvider);

    Future<void> selectDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: dateSaillie.value,
        firstDate: DateTime(2010),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        dateSaillie.value = picked;
      }
    }

    Future<void> runConsanguinityCheck() async {
      consanguinityError.value = null;
      consanguinity.value = null;

      final m = selectedMereId.value;
      final p = selectedPereId.value;
      if (m == null || p == null) return;
      if (!connectivity.isOnline) {
        consanguinityError.value = l10n.consanguinityOffline;
        return;
      }

      try {
        final service = ref.read(consanguinityServiceProvider);
        consanguinity.value = await service.check(mereId: m, pereId: p);
      } catch (e) {
        consanguinityError.value = e.toString();
      }
    }

    useEffect(() {
      unawaited(runConsanguinityCheck());
      return null;
    }, [selectedMereId.value, selectedPereId.value]);

    Future<void> submit() async {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      if (selectedMereId.value == null || selectedPereId.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectFemaleAndMaleError)),
        );
        return;
      }

      isSaving.value = true;
      try {
        await runConsanguinityCheck();
        if (consanguinity.value?.level == ConsanguinityLevel.block) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.consanguinityBlocked)),
          );
          return;
        }

        final portee = Portee(
          id: const Uuid().v4(),
          userId: userId,
          mereId: selectedMereId.value!,
          pereId: selectedPereId.value!,
          dateSaillie: dateSaillie.value,
          statut: StatutPortee.enGestation,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref.read(porteesProvider.notifier).create(portee);
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

    final femelles = (lapins.asData?.value.items ?? const [])
        .where((l) => l.sexe == SexeLapin.femelle && l.statut == StatutLapin.repos)
        .toList();
    final males = (lapins.asData?.value.items ?? const [])
        .where((l) => l.sexe == SexeLapin.male)
        .toList();

    final consanguinityLabel = () {
      final r = consanguinity.value;
      if (r == null) return null;
      final pct = (r.f * 100).toStringAsFixed(1);
      switch (r.level) {
        case ConsanguinityLevel.ok:
          return '${l10n.consanguinityOk} ($pct%)';
        case ConsanguinityLevel.warn:
          return '${l10n.consanguinityWarn} ($pct%)';
        case ConsanguinityLevel.block:
          return '${l10n.consanguinityBlock} ($pct%)';
        case ConsanguinityLevel.unknown:
          return l10n.consanguinityUnknown;
      }
    }();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newSaillie),
      ),
      body: lapins.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.femaleLabel, style: AppTypography.headline3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedMereId.value,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.female)),
                items: femelles
                    .map(
                      (l) => DropdownMenuItem(
                        value: l.id,
                        child: Text(l.nom),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedMereId.value = v,
              ),
              const SizedBox(height: 16),
              Text(l10n.maleLabel, style: AppTypography.headline3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedPereId.value,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.male)),
                items: males
                    .map(
                      (l) => DropdownMenuItem(
                        value: l.id,
                        child: Text(l.nom),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedPereId.value = v,
              ),
              const SizedBox(height: 16),
              Text(l10n.saillieDateLabel, style: AppTypography.headline3),
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
                        '${dateSaillie.value.day}/${dateSaillie.value.month}/${dateSaillie.value.year}',
                        style: AppTypography.body1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.consanguinityTitle, style: AppTypography.headline3),
              const SizedBox(height: 8),
              if (consanguinityLabel != null)
                Text(consanguinityLabel, style: AppTypography.body1),
              if (consanguinityError.value != null) ...[
                const SizedBox(height: 4),
                Text(
                  consanguinityError.value!,
                  style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Text(l10n.notes, style: AppTypography.headline3),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSaving.value || consanguinity.value?.level == ConsanguinityLevel.block
                    ? null
                    : submit,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
