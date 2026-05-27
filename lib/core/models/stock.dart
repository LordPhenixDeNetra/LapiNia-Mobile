import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class Stock extends Equatable {
  final String id;
  final String userId;
  final String aliment;
  final double quantiteKg;
  final double seuilAlerteKg;
  final int? prixKgFcfa;
  final String? fournisseurNom;
  final String? fournisseurContact;
  final DateTime? derniereCommande;
  final DateTime updatedAt;

  const Stock({
    required this.id,
    required this.userId,
    required this.aliment,
    required this.quantiteKg,
    required this.seuilAlerteKg,
    this.prixKgFcfa,
    this.fournisseurNom,
    this.fournisseurContact,
    this.derniereCommande,
    required this.updatedAt,
  });

  bool get estCritique => quantiteKg <= seuilAlerteKg;

  double get pourcentageStock {
    if (seuilAlerteKg == 0) return 100;
    final stockMax = seuilAlerteKg * 5;
    return (quantiteKg / stockMax * 100).clamp(0, 100);
  }

  String get niveauStock {
    final pct = pourcentageStock;
    if (pct >= AppConstants.seuilStockVert) return 'Bon';
    if (pct >= AppConstants.seuilStockOrange) return 'Attention';
    return 'Critique';
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      aliment: json['aliment'] as String,
      quantiteKg: double.tryParse(json['quantite_kg'].toString()) ?? 0,
      seuilAlerteKg: double.tryParse(json['seuil_alerte_kg'].toString()) ?? 2,
      prixKgFcfa: json['prix_kg_fcfa'] as int?,
      fournisseurNom: json['fournisseur_nom'] as String?,
      fournisseurContact: json['fournisseur_contact'] as String?,
      derniereCommande: json['derniere_commande'] != null
          ? DateTime.parse(json['derniere_commande'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'aliment': aliment,
      'quantite_kg': quantiteKg,
      'seuil_alerte_kg': seuilAlerteKg,
      'prix_kg_fcfa': prixKgFcfa,
      'fournisseur_nom': fournisseurNom,
      'fournisseur_contact': fournisseurContact,
      'derniere_commande': derniereCommande?.toIso8601String().split('T')[0],
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Stock copyWith({
    String? id,
    String? userId,
    String? aliment,
    double? quantiteKg,
    double? seuilAlerteKg,
    int? prixKgFcfa,
    String? fournisseurNom,
    String? fournisseurContact,
    DateTime? derniereCommande,
    DateTime? updatedAt,
  }) {
    return Stock(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      aliment: aliment ?? this.aliment,
      quantiteKg: quantiteKg ?? this.quantiteKg,
      seuilAlerteKg: seuilAlerteKg ?? this.seuilAlerteKg,
      prixKgFcfa: prixKgFcfa ?? this.prixKgFcfa,
      fournisseurNom: fournisseurNom ?? this.fournisseurNom,
      fournisseurContact: fournisseurContact ?? this.fournisseurContact,
      derniereCommande: derniereCommande ?? this.derniereCommande,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        aliment,
        quantiteKg,
        seuilAlerteKg,
        prixKgFcfa,
        fournisseurNom,
        fournisseurContact,
        derniereCommande,
        updatedAt,
      ];
}
