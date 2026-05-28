import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/lapin.dart';
import '../../providers/core_providers.dart';
import '../../providers/lapin_provider.dart';

class LapinFormScreen extends HookConsumerWidget {
  final String? lapinId;

  const LapinFormScreen({super.key, this.lapinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = lapinId != null;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nomController = useTextEditingController();
    final poidsController = useTextEditingController();
    final notesController = useTextEditingController();
    final numeroController = useTextEditingController();

    final sexe = useState(SexeLapin.male);
    final statut = useState(StatutLapin.repos);
    final dateNaissance = useState<DateTime?>(null);
    final selectedRaceId = useState<String?>(null);
    final hasHydrated = useRef(false);
    final isSaving = useState(false);

    final races = ref.watch(racesProvider);
    final lapinDetail = isEditing ? ref.watch(lapinDetailProvider(lapinId!)) : null;

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

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: utilisateur non connecté')),
        );
        return;
      }

      isSaving.value = true;
      try {
        final now = DateTime.now();
        final lapin = Lapin(
          id: lapinId ?? const Uuid().v4(),
          userId: userId,
          nom: nomController.text,
          raceId: selectedRaceId.value,
          sexe: sexe.value,
          dateNaissance: dateNaissance.value,
          poidsActuelG: int.tryParse(poidsController.text),
          statut: statut.value,
          numeroIdentification:
              numeroController.text.isNotEmpty ? numeroController.text : null,
          notes: notesController.text.isNotEmpty ? notesController.text : null,
          createdAt: now,
          updatedAt: now,
        );

        if (isEditing) {
          await ref.read(lapinsProvider.notifier).updateLapin(lapin);
        } else {
          await ref.read(lapinsProvider.notifier).create(lapin);
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

    final loading = races.isLoading || (lapinDetail?.isLoading ?? false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le lapin' : 'Nouveau lapin'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identité',
                      style: AppTypography.headline3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom *',
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRaceId.value,
                      decoration: const InputDecoration(
                        labelText: 'Race',
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
                      'Sexe',
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildSexeOption(sexe, SexeLapin.male)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSexeOption(sexe, SexeLapin.femelle)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Paramètres',
                      style: AppTypography.headline3,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de naissance',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          dateNaissance.value != null
                              ? '${dateNaissance.value!.day}/${dateNaissance.value!.month}/${dateNaissance.value!.year}'
                              : 'Sélectionner une date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: poidsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Poids actuel (grammes)',
                        prefixIcon: Icon(Icons.scale),
                        suffixText: 'g',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<StatutLapin>(
                      initialValue: statut.value,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
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
                      decoration: const InputDecoration(
                        labelText: 'Numéro d\'identification',
                        prefixIcon: Icon(Icons.tag),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: isSaving.value ? null : submit,
                      child: Text(isEditing ? 'Mettre à jour' : 'Créer'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSexeOption(
    ValueNotifier<SexeLapin> selected,
    SexeLapin option,
  ) {
    final isSelected = selected.value == option;
    final selectedColor =
        option == SexeLapin.male ? AppColors.maleColor : AppColors.femelleColor;

    return InkWell(
      onTap: () => selected.value = option,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.greyLight,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option == SexeLapin.male ? Icons.male : Icons.female,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: AppTypography.body2.copyWith(
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
