import 'package:equatable/equatable.dart';
import '../constants/enums.dart';
import 'lapin.dart';

class Finance extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final TypeFinance type;
  final CategorieFinance categorie;
  final int montantFcfa;
  final String? description;
  final String? lapinId;
  final ModePaiement modePaiement;
  final String? idempotencyKey;
  final DateTime createdAt;
  final Lapin? lapin;

  const Finance({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.categorie,
    required this.montantFcfa,
    this.description,
    this.lapinId,
    required this.modePaiement,
    this.idempotencyKey,
    required this.createdAt,
    this.lapin,
  });

  String get montantFormate {
    final prefix = type == TypeFinance.recette ? '+' : '-';
    return '$prefix$montantFcfa FCFA';
  }

  factory Finance.fromJson(Map<String, dynamic> json) {
    return Finance(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: TypeFinance.fromDbValue(json['type'] as String),
      categorie: CategorieFinance.fromDbValue(json['categorie'] as String),
      montantFcfa: json['montant_fcfa'] as int,
      description: json['description'] as String?,
      lapinId: json['lapin_id'] as String?,
      modePaiement: ModePaiement.fromDbValue(json['mode_paiement'] as String),
      idempotencyKey: json['idempotency_key'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lapin: json['lapins'] != null
          ? Lapin.fromJson(json['lapins'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'type': type.dbValue,
      'categorie': categorie.dbValue,
      'montant_fcfa': montantFcfa,
      'description': description,
      'lapin_id': lapinId,
      'mode_paiement': modePaiement.dbValue,
      'idempotency_key': idempotencyKey,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        type,
        categorie,
        montantFcfa,
        description,
        lapinId,
        modePaiement,
        idempotencyKey,
        createdAt,
        lapin,
      ];
}
