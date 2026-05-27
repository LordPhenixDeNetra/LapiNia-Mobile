import 'package:equatable/equatable.dart';
import '../constants/enums.dart';
import 'lapin.dart';

class Alerte extends Equatable {
  final String id;
  final String userId;
  final String? lapinId;
  final TypeAlerte type;
  final String message;
  final PrioriteAlerte priorite;
  final DateTime? dateEcheance;
  final bool lue;
  final bool actionEffectuee;
  final DateTime createdAt;
  final Lapin? lapin;

  const Alerte({
    required this.id,
    required this.userId,
    this.lapinId,
    required this.type,
    required this.message,
    required this.priorite,
    this.dateEcheance,
    this.lue = false,
    this.actionEffectuee = false,
    required this.createdAt,
    this.lapin,
  });

  bool get estEcheanceAtteinte {
    if (dateEcheance == null) return false;
    return DateTime.now().isAfter(dateEcheance!);
  }

  factory Alerte.fromJson(Map<String, dynamic> json) {
    return Alerte(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lapinId: json['lapin_id'] as String?,
      type: TypeAlerte.fromDbValue(json['type'] as String),
      message: json['message'] as String,
      priorite: PrioriteAlerte.fromValue(json['priorite'] as int),
      dateEcheance: json['date_echeance'] != null
          ? DateTime.parse(json['date_echeance'] as String)
          : null,
      lue: json['lue'] as bool? ?? false,
      actionEffectuee: json['action_effectuee'] as bool? ?? false,
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
      'lapin_id': lapinId,
      'type': type.dbValue,
      'message': message,
      'priorite': priorite.value,
      'date_echeance': dateEcheance?.toIso8601String(),
      'lue': lue,
      'action_effectuee': actionEffectuee,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Alerte copyWith({
    String? id,
    String? userId,
    String? lapinId,
    TypeAlerte? type,
    String? message,
    PrioriteAlerte? priorite,
    DateTime? dateEcheance,
    bool? lue,
    bool? actionEffectuee,
    DateTime? createdAt,
    Lapin? lapin,
  }) {
    return Alerte(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lapinId: lapinId ?? this.lapinId,
      type: type ?? this.type,
      message: message ?? this.message,
      priorite: priorite ?? this.priorite,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      lue: lue ?? this.lue,
      actionEffectuee: actionEffectuee ?? this.actionEffectuee,
      createdAt: createdAt ?? this.createdAt,
      lapin: lapin ?? this.lapin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        lapinId,
        type,
        message,
        priorite,
        dateEcheance,
        lue,
        actionEffectuee,
        createdAt,
        lapin,
      ];
}
