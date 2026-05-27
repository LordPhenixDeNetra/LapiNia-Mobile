import 'package:equatable/equatable.dart';

class Aliment extends Equatable {
  final String id;
  final String nom;
  final double? proteinesPourcent;
  final double? fibresPourcent;
  final int? energieKcalKg;
  final String? disponibilite;
  final String? description;

  const Aliment({
    required this.id,
    required this.nom,
    this.proteinesPourcent,
    this.fibresPourcent,
    this.energieKcalKg,
    this.disponibilite,
    this.description,
  });

  factory Aliment.fromJson(Map<String, dynamic> json) {
    return Aliment(
      id: json['id'] as String,
      nom: json['nom'] as String,
      proteinesPourcent: json['proteines'] != null
          ? double.tryParse(json['proteines'].toString())
          : null,
      fibresPourcent: json['fibres'] != null
          ? double.tryParse(json['fibres'].toString())
          : null,
      energieKcalKg: json['energie'] as int?,
      disponibilite: json['disponibilite'] as String?,
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nom,
        proteinesPourcent,
        fibresPourcent,
        energieKcalKg,
        disponibilite,
        description,
      ];
}

class Ration extends Equatable {
  final String lapinId;
  final String nomLapin;
  final String stade;
  final List<ComposantRation> composants;
  final double coutTotalFcfa;
  final List<String> alertesStock;

  const Ration({
    required this.lapinId,
    required this.nomLapin,
    required this.stade,
    required this.composants,
    required this.coutTotalFcfa,
    this.alertesStock = const [],
  });

  double get poidsTotalG =>
      composants.fold(0.0, (sum, c) => sum + c.quantiteG);

  factory Ration.fromJson(Map<String, dynamic> json) {
    return Ration(
      lapinId: json['lapin_id'] as String,
      nomLapin: json['nom_lapin'] as String,
      stade: json['stade'] as String,
      composants: (json['composants'] as List<dynamic>)
          .map((e) => ComposantRation.fromJson(e as Map<String, dynamic>))
          .toList(),
      coutTotalFcfa: double.tryParse(json['cout_total_fcfa'].toString()) ?? 0,
      alertesStock: (json['alertes_stock'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        lapinId,
        nomLapin,
        stade,
        composants,
        coutTotalFcfa,
        alertesStock,
      ];
}

class ComposantRation extends Equatable {
  final String aliment;
  final double quantiteG;
  final double? coutFcfa;
  final String? note;

  const ComposantRation({
    required this.aliment,
    required this.quantiteG,
    this.coutFcfa,
    this.note,
  });

  factory ComposantRation.fromJson(Map<String, dynamic> json) {
    return ComposantRation(
      aliment: json['aliment'] as String,
      quantiteG: double.tryParse(json['quantite_g'].toString()) ?? 0,
      coutFcfa: json['cout_fcfa'] != null
          ? double.tryParse(json['cout_fcfa'].toString())
          : null,
      note: json['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [aliment, quantiteG, coutFcfa, note];
}
