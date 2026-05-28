class OnboardingProfile {
  final String rabbitsCountRange;
  final List<String> goals;
  final String country;
  final String city;
  final List<String> raceIds;
  final String experienceLevel;

  const OnboardingProfile({
    required this.rabbitsCountRange,
    required this.goals,
    required this.country,
    required this.city,
    required this.raceIds,
    required this.experienceLevel,
  });

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) {
    return OnboardingProfile(
      rabbitsCountRange: json['rabbitsCountRange'] as String,
      goals: (json['goals'] as List).map((e) => e as String).toList(),
      country: json['country'] as String,
      city: json['city'] as String? ?? '',
      raceIds: (json['raceIds'] as List?)?.map((e) => e as String).toList() ?? const [],
      experienceLevel: json['experienceLevel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rabbitsCountRange': rabbitsCountRange,
      'goals': goals,
      'country': country,
      'city': city,
      'raceIds': raceIds,
      'experienceLevel': experienceLevel,
    };
  }
}

