import 'package:equatable/equatable.dart';
import '../constants/enums.dart';
import 'lapin.dart';
import 'medicament.dart';

class EvenementSante extends Equatable {
  final String id;
  final String lapinId;
  final String userId;
  final DateTime date;
  final TypeEvenementSante type;
  final String? description;
  final String? medicamentId;
  final double? dosageMl;
  final int? dureeJours;
  final DateTime? delaiAbattageFin;
  final StatutTraitement statut;
  final DateTime createdAt;
  final Lapin? lapin;
  final Medicament? medicament;

  const EvenementSante({
    required this.id,
    required this.lapinId,
    required this.userId,
    required this.date,
    required this.type,
    this.description,
    this.medicamentId,
    this.dosageMl,
    this.dureeJours,
    this.delaiAbattageFin,
    required this.statut,
    required this.createdAt,
    this.lapin,
    this.medicament,
  });

  bool get estActif => statut == StatutTraitement.enCours;

  int? get joursRestantsDelaiAbattage {
    if (delaiAbattageFin == null) return null;
    final restant = delaiAbattageFin!.difference(DateTime.now()).inDays;
    return restant > 0 ? restant : null;
  }

  factory EvenementSante.fromJson(Map<String, dynamic> json) {
    return EvenementSante(
      id: json['id'] as String,
      lapinId: json['lapin_id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: TypeEvenementSante.fromDbValue(json['type'] as String),
      description: json['description'] as String?,
      medicamentId: json['medicament_id'] as String?,
      dosageMl: json['dosage_ml'] != null
          ? double.tryParse(json['dosage_ml'].toString())
          : null,
      dureeJours: json['duree_jours'] as int?,
      delaiAbattageFin: json['delai_abattage_fin'] != null
          ? DateTime.parse(json['delai_abattage_fin'] as String)
          : null,
      statut: StatutTraitement.fromDbValue(json['statut'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      lapin: json['lapins'] != null
          ? Lapin.fromJson(json['lapins'] as Map<String, dynamic>)
          : null,
      medicament: json['medicaments'] != null
          ? Medicament.fromJson(json['medicaments'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lapin_id': lapinId,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'type': type.dbValue,
      'description': description,
      'medicament_id': medicamentId,
      'dosage_ml': dosageMl,
      'duree_jours': dureeJours,
      'delai_abattage_fin': delaiAbattageFin?.toIso8601String(),
      'statut': statut.dbValue,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        lapinId,
        userId,
        date,
        type,
        description,
        medicamentId,
        dosageMl,
        dureeJours,
        delaiAbattageFin,
        statut,
        createdAt,
        lapin,
        medicament,
      ];
}
