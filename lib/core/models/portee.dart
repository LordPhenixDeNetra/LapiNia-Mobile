import 'package:equatable/equatable.dart';
import '../constants/enums.dart';
import 'lapin.dart';

class Portee extends Equatable {
  final String id;
  final String userId;
  final String mereId;
  final String pereId;
  final DateTime dateSaillie;
  final DateTime? dateMiseBasPrevue;
  final DateTime? dateMiseBasReelle;
  final int nbVivants;
  final int nbMorts;
  final int? poidsTotalPorteeG;
  final StatutPortee statut;
  final String? notes;
  final DateTime createdAt;
  final Lapin? mere;
  final Lapin? pere;

  const Portee({
    required this.id,
    required this.userId,
    required this.mereId,
    required this.pereId,
    required this.dateSaillie,
    this.dateMiseBasPrevue,
    this.dateMiseBasReelle,
    this.nbVivants = 0,
    this.nbMorts = 0,
    this.poidsTotalPorteeG,
    required this.statut,
    this.notes,
    required this.createdAt,
    this.mere,
    this.pere,
  });

  int get nbTotal => nbVivants + nbMorts;

  int? get dureeGestationJours {
    if (dateMiseBasReelle == null) return null;
    return dateMiseBasReelle!.difference(dateSaillie).inDays;
  }

  int? get joursGestationEcoules {
    if (dateMiseBasReelle != null) return null;
    return DateTime.now().difference(dateSaillie).inDays;
  }

  double? get pourcentageGestation {
    final jours = joursGestationEcoules;
    if (jours == null) return null;
    return (jours / 31) * 100;
  }

  DateTime? get dateSevragePrevue {
    if (dateMiseBasReelle == null) return null;
    return dateMiseBasReelle!.add(const Duration(days: 28));
  }

  factory Portee.fromJson(Map<String, dynamic> json) {
    return Portee(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mereId: json['mere_id'] as String,
      pereId: json['pere_id'] as String,
      dateSaillie: DateTime.parse(json['date_saillie'] as String),
      dateMiseBasPrevue: json['date_mise_bas_prevue'] != null
          ? DateTime.parse(json['date_mise_bas_prevue'] as String)
          : null,
      dateMiseBasReelle: json['date_mise_bas_reelle'] != null
          ? DateTime.parse(json['date_mise_bas_reelle'] as String)
          : null,
      nbVivants: json['nb_vivants'] as int? ?? 0,
      nbMorts: json['nb_morts'] as int? ?? 0,
      poidsTotalPorteeG: json['poids_total_portee_g'] as int?,
      statut: StatutPortee.fromDbValue(json['statut'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      mere: json['lapins_mere'] != null
          ? Lapin.fromJson(json['lapins_mere'] as Map<String, dynamic>)
          : null,
      pere: json['lapins_pere'] != null
          ? Lapin.fromJson(json['lapins_pere'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mere_id': mereId,
      'pere_id': pereId,
      'date_saillie': dateSaillie.toIso8601String().split('T')[0],
      'date_mise_bas_prevue': dateMiseBasPrevue?.toIso8601String().split('T')[0],
      'date_mise_bas_reelle': dateMiseBasReelle?.toIso8601String().split('T')[0],
      'nb_vivants': nbVivants,
      'nb_morts': nbMorts,
      'poids_total_portee_g': poidsTotalPorteeG,
      'statut': statut.dbValue,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Portee copyWith({
    String? id,
    String? userId,
    String? mereId,
    String? pereId,
    DateTime? dateSaillie,
    DateTime? dateMiseBasPrevue,
    DateTime? dateMiseBasReelle,
    int? nbVivants,
    int? nbMorts,
    int? poidsTotalPorteeG,
    StatutPortee? statut,
    String? notes,
    DateTime? createdAt,
    Lapin? mere,
    Lapin? pere,
  }) {
    return Portee(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mereId: mereId ?? this.mereId,
      pereId: pereId ?? this.pereId,
      dateSaillie: dateSaillie ?? this.dateSaillie,
      dateMiseBasPrevue: dateMiseBasPrevue ?? this.dateMiseBasPrevue,
      dateMiseBasReelle: dateMiseBasReelle ?? this.dateMiseBasReelle,
      nbVivants: nbVivants ?? this.nbVivants,
      nbMorts: nbMorts ?? this.nbMorts,
      poidsTotalPorteeG: poidsTotalPorteeG ?? this.poidsTotalPorteeG,
      statut: statut ?? this.statut,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      mere: mere ?? this.mere,
      pere: pere ?? this.pere,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        mereId,
        pereId,
        dateSaillie,
        dateMiseBasPrevue,
        dateMiseBasReelle,
        nbVivants,
        nbMorts,
        poidsTotalPorteeG,
        statut,
        notes,
        createdAt,
        mere,
        pere,
      ];
}
