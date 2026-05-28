import 'package:equatable/equatable.dart';

class RentabilityScore extends Equatable {
  final int score;
  final List<String> actions;

  const RentabilityScore({
    required this.score,
    required this.actions,
  });

  factory RentabilityScore.fromJson(Map<String, dynamic> json) {
    final rawActions = json['actions'];
    final actions = rawActions is List
        ? rawActions.whereType<String>().toList()
        : const <String>[];
    return RentabilityScore(
      score: json['score'] is int ? json['score'] as int : 0,
      actions: actions,
    );
  }

  @override
  List<Object?> get props => [score, actions];
}

