import 'package:equatable/equatable.dart';

enum PlannedEventType {
  weight,
  vaccine;

  static PlannedEventType fromDbValue(String value) {
    switch (value) {
      case 'WEIGHT':
        return PlannedEventType.weight;
      case 'VACCINE':
        return PlannedEventType.vaccine;
    }
    return PlannedEventType.weight;
  }

  String get dbValue {
    switch (this) {
      case PlannedEventType.weight:
        return 'WEIGHT';
      case PlannedEventType.vaccine:
        return 'VACCINE';
    }
  }
}

class PlannedEventModel extends Equatable {
  final String id;
  final String userId;
  final PlannedEventType type;
  final String? targetId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const PlannedEventModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.targetId,
    required this.date,
    required this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, type, targetId, date, note, createdAt];
}
