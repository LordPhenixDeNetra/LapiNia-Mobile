import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/enums.dart';
import '../../../core/models/lapin.dart';
import '../../blocs/portee/portee_bloc.dart';
import '../../blocs/lapin/lapin_bloc.dart';

class SaillieFormScreen extends StatefulWidget {
  final String? mereId;

  const SaillieFormScreen({super.key, this.mereId});

  @override
  State<SaillieFormScreen> createState() => _SaillieFormScreenState();
}

class _SaillieFormScreenState extends State<SaillieFormScreen> {
  String? _selectedMereId;
  String? _selectedPereId;
  DateTime _dateSaillie = DateTime.now();
  List<Lapin> _femelles = [];
  List<Lapin> _males = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMereId = widget.mereId;
    _loadLapins();
  }

  Future<void> _loadLapins() async {
    context.read<LapinBloc>().add(LapinsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PorteeBloc, PorteeState>(
      listener: (context, state) {
        if (state is SaillieRecorded) {
          context.pop();
        } else if (state is PorteeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<LapinBloc, LapinState>(
        builder: (context, state) {
          if (state is LapinsLoading || _isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Nouvelle saillie')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (state is LapinsLoaded) {
            _femelles = state.lapins
                .where((l) =>
                    l.sexe == SexeLapin.femelle &&
                    l.statut == StatutLapin.repos)
                .toList();
            _males = state.lapins
                .where((l) => l.sexe == SexeLapin.male)
                .toList();

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text('Nouvelle saillie'),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sélectionner la femelle',
                      style: AppTypography.headline3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Une femelle au repos et en bonne santé',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.greyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_femelles.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Aucune femelle disponible au repos',
                            style: AppTypography.body1.copyWith(
                              color: AppColors.greyMedium,
                            ),
                          ),
                        ),
                      )
                    else
                      ...(_femelles.map((femelle) => _buildLapinOption(
                            femelle,
                            _selectedMereId == femelle.id,
                            (selected) {
                              setState(() {
                                _selectedMereId = selected ? femelle.id : null;
                              });
                            },
                          ))),
                    const SizedBox(height: 32),
                    Text(
                      'Sélectionner le mâle',
                      style: AppTypography.headline3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choisissez un mâle reproducteur',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.greyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_males.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Aucun mâle disponible',
                            style: AppTypography.body1.copyWith(
                              color: AppColors.greyMedium,
                            ),
                          ),
                        ),
                      )
                    else
                      ...(_males.map((male) => _buildLapinOption(
                            male,
                            _selectedPereId == male.id,
                            (selected) {
                              setState(() {
                                _selectedPereId = selected ? male.id : null;
                              });
                            },
                          ))),
                    const SizedBox(height: 32),
                    Text(
                      'Date de saillie',
                      style: AppTypography.headline3,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              '${_dateSaillie.day}/${_dateSaillie.month}/${_dateSaillie.year}',
                              style: AppTypography.body1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mise bas prévue: ${_dateSaillie.add(const Duration(days: 31)).day}/${_dateSaillie.add(const Duration(days: 31)).month}/${_dateSaillie.add(const Duration(days: 31)).year}',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<PorteeBloc, PorteeState>(
                      builder: (context, porteeState) {
                        final isLoading = porteeState is PorteeSaving;
                        return ElevatedButton(
                          onPressed: (_selectedMereId != null &&
                                  _selectedPereId != null &&
                                  !isLoading)
                              ? _submit
                              : null,
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Enregistrer la saillie'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Nouvelle saillie')),
            body: const Center(child: Text('Erreur de chargement')),
          );
        },
      ),
    );
  }

  Widget _buildLapinOption(
    Lapin lapin,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    final isMale = lapin.sexe == SexeLapin.male;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onSelected(!isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.greyLight,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : (isMale
                          ? AppColors.maleColor.withOpacity(0.1)
                          : AppColors.femelleColor.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  isMale ? Icons.male : Icons.female,
                  color: isSelected
                      ? Colors.white
                      : (isMale ? AppColors.maleColor : AppColors.femelleColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lapin.nom,
                      style: AppTypography.subtitle1.copyWith(
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    Text(
                      lapin.race?.nom ?? 'Race inconnue',
                      style: AppTypography.caption.copyWith(
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.greyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateSaillie,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateSaillie = picked;
      });
    }
  }

  void _submit() {
    if (_selectedMereId == null || _selectedPereId == null) return;

    context.read<PorteeBloc>().add(
      SaillieCreateRequested(
        porteeId: const Uuid().v4(),
        mereId: _selectedMereId!,
        pereId: _selectedPereId!,
        dateSaillie: _dateSaillie,
      ),
    );
  }
}
