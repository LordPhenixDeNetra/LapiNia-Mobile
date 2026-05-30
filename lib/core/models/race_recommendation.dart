import 'package:equatable/equatable.dart';

enum RaceRecommendationGoal {
  meat,
  breeding,
  heatResilience;

  String get apiValue {
    switch (this) {
      case RaceRecommendationGoal.meat:
        return 'MEAT';
      case RaceRecommendationGoal.breeding:
        return 'BREEDING';
      case RaceRecommendationGoal.heatResilience:
        return 'HEAT_RESILIENCE';
    }
  }

  static RaceRecommendationGoal fromApiValue(String value) {
    switch (value) {
      case 'BREEDING':
        return RaceRecommendationGoal.breeding;
      case 'HEAT_RESILIENCE':
        return RaceRecommendationGoal.heatResilience;
      case 'MEAT':
      default:
        return RaceRecommendationGoal.meat;
    }
  }
}

class RaceRecommendationRequest extends Equatable {
  final String country;
  final String? city;
  final RaceRecommendationGoal goal;
  final List<String> resources;

  const RaceRecommendationRequest({
    required this.country,
    required this.goal,
    this.city,
    this.resources = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
      'goal': goal.apiValue,
      'resources': resources,
    };
  }

  @override
  List<Object?> get props => [country, city, goal, resources];
}

class RaceRecommendationItem extends Equatable {
  final String raceId;
  final String raceName;
  final List<String> reasons;
  final List<String> warnings;

  const RaceRecommendationItem({
    required this.raceId,
    required this.raceName,
    this.reasons = const [],
    this.warnings = const [],
  });

  factory RaceRecommendationItem.fromJson(Map<String, dynamic> json) {
    return RaceRecommendationItem(
      raceId: (json['raceId'] ?? json['race_id'] ?? '').toString(),
      raceName: (json['raceName'] ?? json['race_name'] ?? '').toString(),
      reasons: (json['reasons'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      warnings: (json['warnings'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  List<Object?> get props => [raceId, raceName, reasons, warnings];
}

class RaceRecommendationResult extends Equatable {
  final List<RaceRecommendationItem> items;

  const RaceRecommendationResult({required this.items});

  factory RaceRecommendationResult.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final list = raw is List ? raw : const [];
    return RaceRecommendationResult(
      items: list
          .whereType<Map>()
          .map((e) => RaceRecommendationItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [items];
}

