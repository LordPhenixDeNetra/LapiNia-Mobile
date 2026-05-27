import 'package:equatable/equatable.dart';

class Race extends Equatable {
  final String id;
  final String nom;
  final double? poidsAdulteMinKg;
  final double? poidsAdulteMaxKg;
  final int? gmqCibleG;
  final double? taillePorteeMoyenne;
  final int? age1ereMiseBasJours;
  final int? adaptationChaleurScore;
  final Map<String, dynamic>? profilNutritionnel;
  final List<String>? sensibilitesPathologiques;
  final DateTime createdAt;

  const Race({
    required this.id,
    required this.nom,
    this.poidsAdulteMinKg,
    this.poidsAdulteMaxKg,
    this.gmqCibleG,
    this.taillePorteeMoyenne,
    this.age1ereMiseBasJours,
    this.adaptationChaleurScore,
    this.profilNutritionnel,
    this.sensibilitesPathologiques,
    required this.createdAt,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['id'] as String,
      nom: json['nom'] as String,
      poidsAdulteMinKg: json['poids_adulte_min_kg'] != null
          ? double.tryParse(json['poids_adulte_min_kg'].toString())
          : null,
      poidsAdulteMaxKg: json['poids_adulte_max_kg'] != null
          ? double.tryParse(json['poids_adulte_max_kg'].toString())
          : null,
      gmqCibleG: json['gmq_cible_g'] as int?,
      taillePorteeMoyenne: json['taille_portee_moyenne'] != null
          ? double.tryParse(json['taille_portee_moyenne'].toString())
          : null,
      age1ereMiseBasJours: json['age_1ere_mise_bas_jours'] as int?,
      adaptationChaleurScore: json['adaptation_chaleur_score'] as int?,
      profilNutritionnel: json['profil_nutritionnel'] as Map<String, dynamic>?,
      sensibilitesPathologiques: (json['sensibilites_pathologiques'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'poids_adulte_min_kg': poidsAdulteMinKg,
      'poids_adulte_max_kg': poidsAdulteMaxKg,
      'gmq_cible_g': gmqCibleG,
      'taille_portee_moyenne': taillePorteeMoyenne,
      'age_1ere_mise_bas_jours': age1ereMiseBasJours,
      'adaptation_chaleur_score': adaptationChaleurScore,
      'profil_nutritionnel': profilNutritionnel,
      'sensibilites_pathologiques': sensibilitesPathologiques,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        nom,
        poidsAdulteMinKg,
        poidsAdulteMaxKg,
        gmqCibleG,
        taillePorteeMoyenne,
        age1ereMiseBasJours,
        adaptationChaleurScore,
        profilNutritionnel,
        sensibilitesPathologiques,
        createdAt,
      ];
}
