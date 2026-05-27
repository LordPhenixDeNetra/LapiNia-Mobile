import 'package:equatable/equatable.dart';

class Genealogie extends Equatable {
  final String id;
  final String lapinId;
  final String parentId;
  final String role;
  final int generation;

  const Genealogie({
    required this.id,
    required this.lapinId,
    required this.parentId,
    required this.role,
    required this.generation,
  });

  factory Genealogie.fromJson(Map<String, dynamic> json) {
    return Genealogie(
      id: json['id'] as String,
      lapinId: json['lapin_id'] as String,
      parentId: json['parent_id'] as String,
      role: json['role'] as String,
      generation: json['generation'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lapin_id': lapinId,
      'parent_id': parentId,
      'role': role,
      'generation': generation,
    };
  }

  @override
  List<Object?> get props => [id, lapinId, parentId, role, generation];
}

class NoeudGenealogique extends Equatable {
  final String id;
  final String nom;
  final String? race;
  final String? pereId;
  final String? mereId;
  final int? gmQ;
  final int? nbPortees;
  final double? scoreSante;
  final List<NoeudGenealogique> ancetres;

  const NoeudGenealogique({
    required this.id,
    required this.nom,
    this.race,
    this.pereId,
    this.mereId,
    this.gmQ,
    this.nbPortees,
    this.scoreSante,
    this.ancetres = const [],
  });

  @override
  List<Object?> get props => [
        id,
        nom,
        race,
        pereId,
        mereId,
        gmQ,
        nbPortees,
        scoreSante,
        ancetres,
      ];
}

class ResultatConsanguinite extends Equatable {
  final double coefficientF;
  final String niveauRisque;
  final String recommandation;
  final List<String> ancetresCommuns;

  const ResultatConsanguinite({
    required this.coefficientF,
    required this.niveauRisque,
    required this.recommandation,
    this.ancetresCommuns = const [],
  });

  bool get estAcceptable => coefficientF < 6.25;
  bool get estRisqueModere => coefficientF >= 6.25 && coefficientF < 12.5;
  bool get estRisqueEleve => coefficientF >= 12.5;

  factory ResultatConsanguinite.fromJson(Map<String, dynamic> json) {
    return ResultatConsanguinite(
      coefficientF: double.tryParse(json['coefficient_f'].toString()) ?? 0,
      niveauRisque: json['risque'] as String? ?? 'Inconnu',
      recommandation: json['recommandation'] as String? ?? '',
      ancetresCommuns: (json['ancetres_communs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        coefficientF,
        niveauRisque,
        recommandation,
        ancetresCommuns,
      ];
}
