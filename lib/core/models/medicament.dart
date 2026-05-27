import 'package:equatable/equatable.dart';

class Medicament extends Equatable {
  final String id;
  final String nom;
  final String? classe;
  final double? posologieMlParKg;
  final String? voieAdministration;
  final Map<String, dynamic>? contreIndications;
  final int? delaiAbattageJours;
  final String? description;

  const Medicament({
    required this.id,
    required this.nom,
    this.classe,
    this.posologieMlParKg,
    this.voieAdministration,
    this.contreIndications,
    this.delaiAbattageJours,
    this.description,
  });

  factory Medicament.fromJson(Map<String, dynamic> json) {
    return Medicament(
      id: json['id'] as String,
      nom: json['nom'] as String,
      classe: json['classe'] as String?,
      posologieMlParKg: json['posologie_ml_par_kg'] != null
          ? double.tryParse(json['posologie_ml_par_kg'].toString())
          : null,
      voieAdministration: json['voie_administration'] as String?,
      contreIndications: json['contre_indications'] as Map<String, dynamic>?,
      delaiAbattageJours: json['delai_abattage_jours'] as int?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'classe': classe,
      'posologie_ml_par_kg': posologieMlParKg,
      'voie_administration': voieAdministration,
      'contre_indications': contreIndications,
      'delai_abattage_jours': delaiAbattageJours,
      'description': description,
    };
  }

  double calculerDosage(int poidsG) {
    if (posologieMlParKg == null) return 0;
    return (poidsG / 1000) * posologieMlParKg!;
  }

  @override
  List<Object?> get props => [
        id,
        nom,
        classe,
        posologieMlParKg,
        voieAdministration,
        contreIndications,
        delaiAbattageJours,
        description,
      ];
}
