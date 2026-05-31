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
import '../../../core/models/male_suggestion.dart';
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

    final allLapins = lapins.asData?.value.items ?? const [];

    final femelles = allLapins
        .where((l) => l.sexe == SexeLapin.femelle && l.statut == StatutLapin.repos)
        .toList();
    final males = allLapins.where((l) => l.sexe == SexeLapin.male).toList();

    final selectedMere = selectedMereId.value == null
        ? null
        : allLapins.where((l) => l.id == selectedMereId.value).cast().toList();
    final selectedMereLapin = selectedMere == null || selectedMere.isEmpty ? null : selectedMere.first;

    final femellesItems = <DropdownMenuItem<String>>[];
    if (selectedMereLapin != null &&
        !femelles.any((l) => l.id == selectedMereLapin.id)) {
      femellesItems.add(
        DropdownMenuItem(
          value: selectedMereLapin.id,
          child: Text(selectedMereLapin.nom),
        ),
      );
    }
    final seenFemelleIds = <String>{};
    for (final l in femelles) {
      if (seenFemelleIds.add(l.id)) {
        femellesItems.add(
          DropdownMenuItem(
            value: l.id,
            child: Text(l.nom),
          ),
        );
      }
    }

    final safeSelectedMereId = femellesItems.any((e) => e.value == selectedMereId.value)
        ? selectedMereId.value
        : null;

    final malesItems = <DropdownMenuItem<String>>[];
    final seenMaleIds = <String>{};
    for (final l in males) {
      if (seenMaleIds.add(l.id)) {
        malesItems.add(
          DropdownMenuItem(
            value: l.id,
            child: Text(l.nom),
          ),
        );
      }
    }

    final safeSelectedPereId = malesItems.any((e) => e.value == selectedPereId.value)
        ? selectedPereId.value
        : null;

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

    Future<void> suggestMales() async {
      final femelleId = selectedMereId.value;
      if (femelleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.suggestMalesSelectFemaleFirst)),
        );
        return;
      }
      if (!connectivity.isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.suggestMalesRequiresOnline)),
        );
        return;
      }

      final service = ref.read(suggestMalesServiceProvider);
      MaleSuggestionObjective objective = MaleSuggestionObjective.equilibre;
      MaleSuggestionResult? result;
      String? error;
      var loading = true;

      Future<void> load(MaleSuggestionObjective o, void Function(void Function()) setState) async {
        setState(() {
          objective = o;
          loading = true;
          error = null;
        });
        try {
          final r = await service.suggest(femelleId: femelleId, objective: o);
          setState(() {
            result = r;
            loading = false;
          });
        } catch (e) {
          setState(() {
            error = e.toString();
            loading = false;
          });
        }
      }

      final pickedMaleId = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              if (loading && result == null && error == null) {
                unawaited(load(objective, setState));
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.suggestMalesTitle, style: AppTypography.subtitle1),
                      const SizedBox(height: 10),
                      SegmentedButton<MaleSuggestionObjective>(
                        segments: [
                          ButtonSegment(
                            value: MaleSuggestionObjective.antiConsanguinite,
                            label: Text(l10n.suggestMalesObjectiveAnti),
                          ),
                          ButtonSegment(
                            value: MaleSuggestionObjective.croissance,
                            label: Text(l10n.suggestMalesObjectiveGrowth),
                          ),
                          ButtonSegment(
                            value: MaleSuggestionObjective.equilibre,
                            label: Text(l10n.suggestMalesObjectiveBalanced),
                          ),
                        ],
                        selected: {objective},
                        onSelectionChanged: (selection) {
                          final o = selection.first;
                          unawaited(load(o, setState));
                        },
                      ),
                      const SizedBox(height: 12),
                      if (loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            error!,
                            style: AppTypography.body2.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        )
                      else if (result == null || result!.items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(l10n.suggestMalesNoResults, style: AppTypography.body2),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: result!.items.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = result!.items[index];
                              return Card(
                                child: ListTile(
                                  title: Text('${item.nom} (${item.score}/100)'),
                                  subtitle: Text(item.justification),
                                  onTap: () => Navigator.pop(context, item.maleId),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      if (pickedMaleId != null) {
        selectedPereId.value = pickedMaleId;
      }
    }

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
                initialValue: safeSelectedMereId,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.female)),
                items: femellesItems,
                onChanged: (v) => selectedMereId.value = v,
              ),
              const SizedBox(height: 16),
              Text(l10n.maleLabel, style: AppTypography.headline3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: safeSelectedPereId,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.male)),
                items: malesItems,
                onChanged: (v) => selectedPereId.value = v,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: suggestMales,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.suggestMalesButton),
                ),
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
