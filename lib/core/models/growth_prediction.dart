import 'package:equatable/equatable.dart';

class GrowthPredictionPoint extends Equatable {
  final DateTime date;
  final int poidsG;
  final int? gmqJour;

  const GrowthPredictionPoint({
    required this.date,
    required this.poidsG,
    this.gmqJour,
  });

  factory GrowthPredictionPoint.fromJson(Map<String, dynamic> json) {
    return GrowthPredictionPoint(
      date: DateTime.parse(json['date'] as String),
      poidsG: (json['poids_g'] as num).round(),
      gmqJour: (json['gmq_jour'] as num?)?.round(),
    );
  }

  @override
  List<Object?> get props => [date, poidsG, gmqJour];
}

class GrowthPrediction extends Equatable {
  final int poidsActuelG;
  final int poidsCibleG;
  final int gmqNecessaireG;
  final int gmqNormeG;
  final bool conforme;
  final int joursJusquCible;
  final List<GrowthPredictionPoint> courbe;

  const GrowthPrediction({
    required this.poidsActuelG,
    required this.poidsCibleG,
    required this.gmqNecessaireG,
    required this.gmqNormeG,
    required this.conforme,
    required this.joursJusquCible,
    required this.courbe,
  });

  factory GrowthPrediction.fromJson(Map<String, dynamic> json) {
    return GrowthPrediction(
      poidsActuelG: (json['poids_actuel_g'] as num).round(),
      poidsCibleG: (json['poids_cible_g'] as num).round(),
      gmqNecessaireG: (json['gmq_necessaire_g'] as num).round(),
      gmqNormeG: (json['gmq_norme_g'] as num).round(),
      conforme: json['conforme'] == true,
      joursJusquCible: (json['jours_jusqu_cible'] as num?)?.round() ?? 0,
      courbe: (json['courbe'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => GrowthPredictionPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        poidsActuelG,
        poidsCibleG,
        gmqNecessaireG,
        gmqNormeG,
        conforme,
        joursJusquCible,
        courbe,
      ];
}

