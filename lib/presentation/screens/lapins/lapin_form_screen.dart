import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/lapin.dart';
import '../../blocs/lapin/lapin_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LapinFormScreen extends StatefulWidget {
  final String? lapinId;

  const LapinFormScreen({super.key, this.lapinId});

  @override
  State<LapinFormScreen> createState() => _LapinFormScreenState();
}

class _LapinFormScreenState extends State<LapinFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _poidsController = TextEditingController();
  final _notesController = TextEditingController();
  final _numeroController = TextEditingController();

  SexeLapin _sexe = SexeLapin.male;
  StatutLapin _statut = StatutLapin.repos;
  DateTime? _dateNaissance;
  String? _selectedRaceId;
  List<dynamic> _races = [];
  bool _isLoading = true;

  bool get isEditing => widget.lapinId != null;

  @override
  void initState() {
    super.initState();
    _loadRaces();
    if (isEditing) {
      _loadLapin();
    }
  }

  Future<void> _loadRaces() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('races').select().order('nom');
      setState(() {
        _races = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLapin() async {
    context.read<LapinBloc>().add(LapinLoadRequested(id: widget.lapinId!));
  }

  @override
  void dispose() {
    _nomController.dispose();
    _poidsController.dispose();
    _notesController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: utilisateur non connecté')),
        );
        return;
      }

      final lapin = Lapin(
        id: widget.lapinId ?? const Uuid().v4(),
        userId: userId,
        nom: _nomController.text,
        raceId: _selectedRaceId,
        sexe: _sexe,
        dateNaissance: _dateNaissance,
        poidsActuelG: int.tryParse(_poidsController.text),
        statut: _statut,
        numeroIdentification: _numeroController.text.isNotEmpty
            ? _numeroController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        context.read<LapinBloc>().add(LapinUpdateRequested(lapin: lapin));
      } else {
        context.read<LapinBloc>().add(LapinCreateRequested(lapin: lapin));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LapinBloc, LapinState>(
      listener: (context, state) {
        if (state is LapinCreated || state is LapinUpdated) {
          context.pop();
        } else if (state is LapinError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is LapinLoaded && isEditing) {
          final lapin = state.lapin;
          setState(() {
            _nomController.text = lapin.nom;
            _poidsController.text = lapin.poidsActuelG?.toString() ?? '';
            _notesController.text = lapin.notes ?? '';
            _numeroController.text = lapin.numeroIdentification ?? '';
            _sexe = lapin.sexe;
            _statut = lapin.statut;
            _dateNaissance = lapin.dateNaissance;
            _selectedRaceId = lapin.raceId;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isEditing ? 'Modifier le lapin' : 'Nouveau lapin'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Identité',
                        style: AppTypography.headline3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomController,
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
                        initialValue: _selectedRaceId,
                        decoration: const InputDecoration(
                          labelText: 'Race',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _races.map<DropdownMenuItem<String>>((race) {
                          return DropdownMenuItem(
                            value: race['id'] as String,
                            child: Text(race['nom'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRaceId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sexe',
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSexeOption(SexeLapin.male),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSexeOption(SexeLapin.femelle),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Paramètres',
                        style: AppTypography.headline3,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date de naissance',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _dateNaissance != null
                                ? '${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}'
                                : 'Sélectionner une date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _poidsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Poids actuel (grammes)',
                          prefixIcon: Icon(Icons.scale),
                          suffixText: 'g',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<StatutLapin>(
                        initialValue: _statut,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        items: StatutLapin.values
                            .where((s) =>
                                s != StatutLapin.vendu &&
                                s != StatutLapin.mort)
                            .map<DropdownMenuItem<StatutLapin>>((statut) {
                          return DropdownMenuItem(
                            value: statut,
                            child: Text(statut.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _statut = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _numeroController,
                        decoration: const InputDecoration(
                          labelText: 'Numéro d\'identification',
                          prefixIcon: Icon(Icons.tag),
                          helperText: 'Ex: SN-2026-NZW-0042',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Notes',
                        style: AppTypography.headline3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optionnel)',
                          prefixIcon: Icon(Icons.note),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(isEditing ? 'Modifier' : 'Créer'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSexeOption(SexeLapin sexe) {
    final isSelected = _sexe == sexe;
    final isMale = sexe == SexeLapin.male;

    return InkWell(
      onTap: () {
        setState(() {
          _sexe = sexe;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isMale ? AppColors.maleColor : AppColors.femelleColor)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isMale ? AppColors.maleColor : AppColors.femelleColor)
                : AppColors.greyLight,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isMale ? Icons.male : Icons.female,
              color: isSelected ? Colors.white : AppColors.greyMedium,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              sexe.label,
              style: AppTypography.body2.copyWith(
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateNaissance = picked;
      });
    }
  }
}
