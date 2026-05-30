import 'package:equatable/equatable.dart';
import 'lapin.dart';

class Pesee extends Equatable {
  final String id;
  final String lapinId;
  final String userId;
  final DateTime date;
  final int poidsG;
  final double? gmqDepuisDerniere;
  final String? notes;
  final DateTime createdAt;
  final Lapin? lapin;

  const Pesee({
    required this.id,
    required this.lapinId,
    required this.userId,
    required this.date,
    required this.poidsG,
    this.gmqDepuisDerniere,
    this.notes,
    required this.createdAt,
    this.lapin,
  });

  double get poidsKg => poidsG / 1000;

  factory Pesee.fromJson(Map<String, dynamic> json) {
    return Pesee(
      id: json['id'] as String,
      lapinId: json['lapin_id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      poidsG: json['poids_g'] as int,
      gmqDepuisDerniere: json['gmq_depuis_derniere'] != null
          ? double.tryParse(json['gmq_depuis_derniere'].toString())
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lapin: json['lapins'] != null
          ? Lapin.fromJson(json['lapins'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lapin_id': lapinId,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'poids_g': poidsG,
      'gmq_depuis_derniere': gmqDepuisDerniere,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Pesee copyWith({
    String? id,
    String? lapinId,
    String? userId,
    DateTime? date,
    int? poidsG,
    double? gmqDepuisDerniere,
    String? notes,
    DateTime? createdAt,
    Lapin? lapin,
  }) {
    return Pesee(
      id: id ?? this.id,
      lapinId: lapinId ?? this.lapinId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      poidsG: poidsG ?? this.poidsG,
      gmqDepuisDerniere: gmqDepuisDerniere ?? this.gmqDepuisDerniere,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lapin: lapin ?? this.lapin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lapinId,
        userId,
        date,
        poidsG,
        gmqDepuisDerniere,
        notes,
        createdAt,
        lapin,
      ];
}
