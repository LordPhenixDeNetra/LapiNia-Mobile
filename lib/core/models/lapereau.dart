import 'package:equatable/equatable.dart';
import '../constants/enums.dart';
import 'lapin.dart';

class Lapereau extends Equatable {
  final String id;
  final String porteeId;
  final String userId;
  final SexeLapin? sexe;
  final int? poidsNaissanceG;
  final DateTime? dateSevrage;
  final StatutLapereau statut;
  final String? lapinId;
  final DateTime createdAt;
  final Lapin? lapin;

  const Lapereau({
    required this.id,
    required this.porteeId,
    required this.userId,
    this.sexe,
    this.poidsNaissanceG,
    this.dateSevrage,
    required this.statut,
    this.lapinId,
    required this.createdAt,
    this.lapin,
  });

  factory Lapereau.fromJson(Map<String, dynamic> json) {
    return Lapereau(
      id: json['id'] as String,
      porteeId: json['portee_id'] as String,
      userId: json['user_id'] as String,
      sexe: json['sexe'] != null ? SexeLapin.fromDbValue(json['sexe'] as String) : null,
      poidsNaissanceG: json['poids_naissance_g'] as int?,
      dateSevrage: json['date_sevrage'] != null
          ? DateTime.parse(json['date_sevrage'] as String)
          : null,
      statut: StatutLapereau.fromDbValue(json['statut'] as String),
      lapinId: json['lapin_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lapin: json['lapins'] != null
          ? Lapin.fromJson(json['lapins'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'portee_id': porteeId,
      'user_id': userId,
      'sexe': sexe?.dbValue,
      'poids_naissance_g': poidsNaissanceG,
      'date_sevrage': dateSevrage?.toIso8601String().split('T')[0],
      'statut': statut.dbValue,
      'lapin_id': lapinId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Lapereau copyWith({
    String? id,
    String? porteeId,
    String? userId,
    SexeLapin? sexe,
    int? poidsNaissanceG,
    DateTime? dateSevrage,
    StatutLapereau? statut,
    String? lapinId,
    DateTime? createdAt,
    Lapin? lapin,
  }) {
    return Lapereau(
      id: id ?? this.id,
      porteeId: porteeId ?? this.porteeId,
      userId: userId ?? this.userId,
      sexe: sexe ?? this.sexe,
      poidsNaissanceG: poidsNaissanceG ?? this.poidsNaissanceG,
      dateSevrage: dateSevrage ?? this.dateSevrage,
      statut: statut ?? this.statut,
      lapinId: lapinId ?? this.lapinId,
      createdAt: createdAt ?? this.createdAt,
      lapin: lapin ?? this.lapin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        porteeId,
        userId,
        sexe,
        poidsNaissanceG,
        dateSevrage,
        statut,
        lapinId,
        createdAt,
        lapin,
      ];
}
