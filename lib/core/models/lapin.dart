import 'package:equatable/equatable.dart';
import '../constants/enums.dart';
import 'race.dart';

class Lapin extends Equatable {
  final String id;
  final String userId;
  final String nom;
  final String? raceId;
  final SexeLapin sexe;
  final DateTime? dateNaissance;
  final int? poidsActuelG;
  final int? scoreFertilite;
  final StatutLapin statut;
  final String? numeroIdentification;
  final String? photoUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Race? race;

  const Lapin({
    required this.id,
    required this.userId,
    required this.nom,
    this.raceId,
    required this.sexe,
    this.dateNaissance,
    this.poidsActuelG,
    this.scoreFertilite,
    required this.statut,
    this.numeroIdentification,
    this.photoUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.race,
  });

  int? get ageJours {
    if (dateNaissance == null) return null;
    return DateTime.now().difference(dateNaissance!).inDays;
  }

  String? get ageFormate {
    final jours = ageJours;
    if (jours == null) return null;
    if (jours < 30) return '$jours jours';
    if (jours < 365) return '${(jours / 30).floor()} mois';
    return '${(jours / 365).floor()} an(s)';
  }

  double? get poidsKg {
    if (poidsActuelG == null) return null;
    return poidsActuelG! / 1000;
  }

  factory Lapin.fromJson(Map<String, dynamic> json) {
    return Lapin(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nom: json['nom'] as String,
      raceId: json['race_id'] as String?,
      sexe: SexeLapin.fromDbValue(json['sexe'] as String),
      dateNaissance: json['date_naissance'] != null
          ? DateTime.parse(json['date_naissance'] as String)
          : null,
      poidsActuelG: json['poids_actuel_g'] as int?,
      scoreFertilite: json['score_fertilite'] as int?,
      statut: StatutLapin.fromDbValue(json['statut'] as String),
      numeroIdentification: json['numero_identification'] as String?,
      photoUrl: json['photo_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
      race: json['races'] != null
          ? Race.fromJson(json['races'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nom': nom,
      'race_id': raceId,
      'sexe': sexe.dbValue,
      'date_naissance': dateNaissance?.toIso8601String().split('T')[0],
      'poids_actuel_g': poidsActuelG,
      'score_fertilite': scoreFertilite,
      'statut': statut.dbValue,
      'numero_identification': numeroIdentification,
      'photo_url': photoUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Lapin copyWith({
    String? id,
    String? userId,
    String? nom,
    String? raceId,
    SexeLapin? sexe,
    DateTime? dateNaissance,
    int? poidsActuelG,
    int? scoreFertilite,
    StatutLapin? statut,
    String? numeroIdentification,
    String? photoUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Race? race,
  }) {
    return Lapin(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      raceId: raceId ?? this.raceId,
      sexe: sexe ?? this.sexe,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      poidsActuelG: poidsActuelG ?? this.poidsActuelG,
      scoreFertilite: scoreFertilite ?? this.scoreFertilite,
      statut: statut ?? this.statut,
      numeroIdentification: numeroIdentification ?? this.numeroIdentification,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      race: race ?? this.race,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        nom,
        raceId,
        sexe,
        dateNaissance,
        poidsActuelG,
        scoreFertilite,
        statut,
        numeroIdentification,
        photoUrl,
        notes,
        createdAt,
        updatedAt,
        race,
      ];
}

class LapinSummary extends Equatable {
  final String id;
  final String nom;
  final StatutLapin statut;
  final bool hasAlerte;

  const LapinSummary({
    required this.id,
    required this.nom,
    required this.statut,
    this.hasAlerte = false,
  });

  factory LapinSummary.fromLapin(Lapin lapin, {bool hasAlerte = false}) {
    return LapinSummary(
      id: lapin.id,
      nom: lapin.nom,
      statut: lapin.statut,
      hasAlerte: hasAlerte,
    );
  }

  @override
  List<Object?> get props => [id, nom, statut, hasAlerte];
}
