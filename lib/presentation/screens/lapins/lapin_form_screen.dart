import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/lapin.dart';
import '../../../core/utils/sync_manager.dart';
import '../../../domain/services/lapin_photo_service.dart';
import '../../providers/core_providers.dart';
import '../../providers/lapin_provider.dart';

class LapinFormScreen extends HookConsumerWidget {
  final String? lapinId;

  const LapinFormScreen({super.key, this.lapinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = lapinId != null;
    final uuid = useMemoized(() => const Uuid());
    final generatedId = useMemoized(() => uuid.v4());
    final currentLapinId = lapinId ?? generatedId;
    final identityFormKey = useMemoized(GlobalKey<FormState>.new);
    final paramsFormKey = useMemoized(GlobalKey<FormState>.new);
    final nomController = useTextEditingController();
    final poidsController = useTextEditingController();
    final notesController = useTextEditingController();
    final numeroController = useTextEditingController();

    final sexe = useState(SexeLapin.male);
    final statut = useState(StatutLapin.repos);
    final dateNaissance = useState<DateTime?>(null);
    final selectedRaceId = useState<String?>(null);
    final currentStep = useState(0);
    final hasHydrated = useRef(false);
    final isSaving = useState(false);
    final existingPhotoUrl = useState<String?>(null);
    final newPhotoPath = useState<String?>(null);
    final selectedPereId = useState<String?>(null);
    final selectedMereId = useState<String?>(null);

    final races = ref.watch(racesProvider);
    final lapinDetail = isEditing ? ref.watch(lapinDetailProvider(lapinId!)) : null;
    final lapinsSelection = ref.watch(lapinsSelectionProvider);

    useEffect(() {
      if (!isEditing) return null;
      if (hasHydrated.value) return null;
      final lapin = lapinDetail?.asData?.value;
      if (lapin == null) return null;

      hasHydrated.value = true;
      nomController.text = lapin.nom;
      poidsController.text = lapin.poidsActuelG?.toString() ?? '';
      notesController.text = lapin.notes ?? '';
      numeroController.text = lapin.numeroIdentification ?? '';
      sexe.value = lapin.sexe;
      statut.value = lapin.statut;
      dateNaissance.value = lapin.dateNaissance;
      selectedRaceId.value = lapin.raceId;
      existingPhotoUrl.value = lapin.photoUrl;
      return null;
    }, [lapinDetail]);

    Future<void> selectDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: dateNaissance.value ?? DateTime.now(),
        firstDate: DateTime(2010),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        dateNaissance.value = picked;
      }
    }

    Future<ImageSource?> selectPhotoSource() async {
      return showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(l10n.photoCamera),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(l10n.photoGallery),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> pickPhoto() async {
      final source = await selectPhotoSource();
      if (source == null) return;

      final service = ref.read(lapinPhotoServiceProvider);
      try {
        final path = await service.pickCropAndValidate(source: source);
        if (path == null) return;
        newPhotoPath.value = path;
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is LapinPhotoException && e.error == LapinPhotoError.tooLarge
                  ? l10n.photoTooLarge
                  : e.toString(),
            ),
          ),
        );
      }
    }

    Future<void> submit() async {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: utilisateur non connecté')),
        );
        return;
      }

      if (!(identityFormKey.currentState?.validate() ?? false)) {
        currentStep.value = 0;
        return;
      }
      if (!(paramsFormKey.currentState?.validate() ?? false)) {
        currentStep.value = 1;
        return;
      }

      isSaving.value = true;
      try {
        final now = DateTime.now();
        final createdAt = isEditing
            ? (lapinDetail?.asData?.value.createdAt ?? now)
            : now;
        final lapin = Lapin(
          id: currentLapinId,
          userId: userId,
          nom: nomController.text,
          raceId: selectedRaceId.value,
          sexe: sexe.value,
          dateNaissance: dateNaissance.value,
          poidsActuelG: int.tryParse(poidsController.text),
          statut: statut.value,
          numeroIdentification:
              numeroController.text.isNotEmpty ? numeroController.text : null,
          photoUrl: existingPhotoUrl.value,
          notes: notesController.text.isNotEmpty ? notesController.text : null,
          createdAt: createdAt,
          updatedAt: now,
        );

        if (isEditing) {
          await ref.read(lapinsProvider.notifier).updateLapin(lapin);
        } else {
          await ref.read(lapinsProvider.notifier).create(lapin);
        }

        final connectivity = ref.read(connectivityCheckerProvider);
        if (newPhotoPath.value != null) {
          if (!connectivity.isOnline) {
            throw Exception(l10n.photoUploadRequiresOnline);
          }
          final service = ref.read(lapinPhotoServiceProvider);
          final url = await service.uploadLapinPhoto(
            lapinId: currentLapinId,
            filePath: newPhotoPath.value!,
          );
          existingPhotoUrl.value = url;
          await ref.read(lapinsProvider.notifier).updateLapin(
                lapin.copyWith(photoUrl: url, updatedAt: DateTime.now()),
              );
          ref.invalidate(lapinDetailProvider(currentLapinId));
        }

        if (!isEditing) {
          final syncManager = ref.read(syncManagerProvider);
          if (selectedPereId.value != null) {
            await syncManager.addMutation(
              tableName: 'genealogie',
              operation: MutationType.insert,
              payload: jsonEncode({
                'id': uuid.v4(),
                'lapin_id': currentLapinId,
                'parent_id': selectedPereId.value,
                'role': 'PERE',
                'generation': 1,
              }),
            );
          }
          if (selectedMereId.value != null) {
            await syncManager.addMutation(
              tableName: 'genealogie',
              operation: MutationType.insert,
              payload: jsonEncode({
                'id': uuid.v4(),
                'lapin_id': currentLapinId,
                'parent_id': selectedMereId.value,
                'role': 'MERE',
                'generation': 1,
              }),
            );
          }
        }

        if (!context.mounted) return;
        context.pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is LapinPhotoException && e.error == LapinPhotoError.tooLarge
                  ? l10n.photoTooLarge
                  : e.toString(),
            ),
          ),
        );
      } finally {
        isSaving.value = false;
      }
    }

    final loading = races.isLoading || (lapinDetail?.isLoading ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le lapin' : 'Nouveau lapin'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: currentStep.value,
              onStepTapped: (i) => currentStep.value = i,
              onStepContinue: () async {
                if (currentStep.value == 0) {
                  if (!(identityFormKey.currentState?.validate() ?? false)) return;
                  currentStep.value = 1;
                  return;
                }
                if (currentStep.value == 1) {
                  if (!(paramsFormKey.currentState?.validate() ?? false)) return;
                  currentStep.value = 2;
                  return;
                }
                await submit();
              },
              onStepCancel: () {
                if (currentStep.value == 0) {
                  context.pop();
                  return;
                }
                currentStep.value -= 1;
              },
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: isSaving.value ? null : details.onStepContinue,
                      child: Text(currentStep.value == 2
                          ? (isEditing ? l10n.commonUpdate : l10n.commonCreate)
                          : l10n.commonNext),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: isSaving.value ? null : details.onStepCancel,
                      child: Text(
                        currentStep.value == 0 ? l10n.cancel : l10n.commonBack,
                      ),
                    ),
                  ],
                );
              },
              steps: [
                Step(
                  title: Text(l10n.lapinFormIdentityStep),
                  isActive: currentStep.value >= 0,
                  content: Form(
                    key: identityFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: InkWell(
                            onTap: isSaving.value ? null : pickPhoto,
                            borderRadius: BorderRadius.circular(56),
                            child: _photoPreview(
                              newPhotoPath: newPhotoPath.value,
                              existingPhotoUrl: existingPhotoUrl.value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nomController,
                          decoration: InputDecoration(
                            labelText: '${l10n.lapinFieldNom} *',
                            prefixIcon: Icon(Icons.pets),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.lapinValidationNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedRaceId.value,
                          decoration: InputDecoration(
                            labelText: l10n.lapinFieldRace,
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: (races.asData?.value ?? const [])
                              .map(
                                (race) => DropdownMenuItem(
                                  value: race.id,
                                  child: Text(race.nom),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => selectedRaceId.value = value,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.lapinFieldSexe,
                          style: AppTypography.label,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSexeOption(
                                context: context,
                                selected: sexe,
                                option: SexeLapin.male,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSexeOption(
                                context: context,
                                selected: sexe,
                                option: SexeLapin.femelle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: Text(l10n.lapinFormParamsStep),
                  isActive: currentStep.value >= 1,
                  content: Form(
                    key: paramsFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: selectDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.lapinFieldDateNaissance,
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              dateNaissance.value != null
                                  ? '${dateNaissance.value!.day}/${dateNaissance.value!.month}/${dateNaissance.value!.year}'
                                  : l10n.commonSelectDate,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: poidsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.lapinFieldPoidsActuel,
                            prefixIcon: Icon(Icons.scale),
                            suffixText: 'g',
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<StatutLapin>(
                          initialValue: statut.value,
                          decoration: InputDecoration(
                            labelText: l10n.lapinFieldStatut,
                            prefixIcon: Icon(Icons.info_outline),
                          ),
                          items: StatutLapin.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) statut.value = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: numeroController,
                          decoration: InputDecoration(
                            labelText: l10n.lapinFieldNumeroIdentification,
                            prefixIcon: Icon(Icons.tag),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: l10n.lapinNotesSection,
                            prefixIcon: Icon(Icons.notes),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: Text(l10n.lapinFormGenealogyStep),
                  isActive: currentStep.value >= 2,
                  content: lapinsSelection.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Text(e.toString()),
                    data: (allLapins) {
                      final pereOptions = allLapins
                          .where((l) =>
                              l.sexe == SexeLapin.male && l.id != currentLapinId)
                          .toList();
                      final mereOptions = allLapins
                          .where((l) =>
                              l.sexe == SexeLapin.femelle && l.id != currentLapinId)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String?>(
                            initialValue: selectedPereId.value,
                            decoration: InputDecoration(
                              labelText: l10n.lapinFormFatherOptional,
                              prefixIcon: Icon(Icons.male),
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(l10n.lapinFormNoneMasculine),
                              ),
                              ...pereOptions.map(
                                (l) => DropdownMenuItem<String?>(
                                  value: l.id,
                                  child: Text(l.nom),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              selectedPereId.value = v;
                              if (v != null && v == selectedMereId.value) {
                                selectedMereId.value = null;
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String?>(
                            initialValue: selectedMereId.value,
                            decoration: InputDecoration(
                              labelText: l10n.lapinFormMotherOptional,
                              prefixIcon: Icon(Icons.female),
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(l10n.lapinFormNoneFeminine),
                              ),
                              ...mereOptions.map(
                                (l) => DropdownMenuItem<String?>(
                                  value: l.id,
                                  child: Text(l.nom),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              selectedMereId.value = v;
                              if (v != null && v == selectedPereId.value) {
                                selectedPereId.value = null;
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSexeOption({
    required BuildContext context,
    required ValueNotifier<SexeLapin> selected,
    required SexeLapin option,
  }) {
    final isSelected = selected.value == option;
    final selectedColor =
        option == SexeLapin.male ? AppColors.maleColor : AppColors.femelleColor;

    return InkWell(
      onTap: () => selected.value = option,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.15)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : Theme.of(context).dividerColor,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option == SexeLapin.male ? Icons.male : Icons.female,
              color: isSelected ? selectedColor : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: AppTypography.body2.copyWith(
                color: isSelected
                    ? selectedColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPreview({
    required String? newPhotoPath,
    required String? existingPhotoUrl,
  }) {
    if (newPhotoPath != null) {
      return CircleAvatar(
        radius: 56,
        backgroundImage: FileImage(File(newPhotoPath)),
      );
    }
    final url = existingPhotoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(56),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 112,
          height: 112,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 112,
            height: 112,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
          ),
          errorWidget: (context, url, error) => const CircleAvatar(
            radius: 56,
            child: Icon(Icons.pets),
          ),
        ),
      );
    }
    return const CircleAvatar(
      radius: 56,
      child: Icon(Icons.add_a_photo),
    );
  }
}
