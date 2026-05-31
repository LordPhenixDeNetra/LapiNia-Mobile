import 'package:equatable/equatable.dart';

enum MaleSuggestionObjective {
  antiConsanguinite,
  croissance,
  equilibre;

  String get apiValue {
    switch (this) {
      case MaleSuggestionObjective.antiConsanguinite:
        return 'anti-consanguinite';
      case MaleSuggestionObjective.croissance:
        return 'croissance';
      case MaleSuggestionObjective.equilibre:
        return 'equilibre';
    }
  }

  static MaleSuggestionObjective fromApiValue(String value) {
    switch (value) {
      case 'anti-consanguinite':
        return MaleSuggestionObjective.antiConsanguinite;
      case 'croissance':
        return MaleSuggestionObjective.croissance;
      default:
        return MaleSuggestionObjective.equilibre;
    }
  }
}

class MaleSuggestionItem extends Equatable {
  final String maleId;
  final String nom;
  final String? raceId;
  final String? raceNom;
  final int score;
  final String justification;

  const MaleSuggestionItem({
    required this.maleId,
    required this.nom,
    required this.raceId,
    required this.raceNom,
    required this.score,
    required this.justification,
  });

  factory MaleSuggestionItem.fromJson(Map<String, dynamic> json) {
    return MaleSuggestionItem(
      maleId: json['maleId'] as String,
      nom: json['nom'] as String? ?? '—',
      raceId: json['raceId'] as String?,
      raceNom: json['raceNom'] as String?,
      score: json['score'] is int ? json['score'] as int : 0,
      justification: json['justification'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [maleId, nom, raceId, raceNom, score, justification];
}

class MaleSuggestionResult extends Equatable {
  final MaleSuggestionObjective objective;
  final String femelleId;
  final String femelleNom;
  final List<MaleSuggestionItem> items;

  const MaleSuggestionResult({
    required this.objective,
    required this.femelleId,
    required this.femelleNom,
    required this.items,
  });

  factory MaleSuggestionResult.fromJson(Map<String, dynamic> json) {
    final objective = MaleSuggestionObjective.fromApiValue((json['objectif'] as String?) ?? '');
    final femelle = json['femelle'] is Map ? Map<String, dynamic>.from(json['femelle'] as Map) : null;
    final itemsRaw = json['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((e) => MaleSuggestionItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <MaleSuggestionItem>[];

    return MaleSuggestionResult(
      objective: objective,
      femelleId: femelle?['id'] as String? ?? '',
      femelleNom: femelle?['nom'] as String? ?? '—',
      items: items,
    );
  }

  @override
  List<Object?> get props => [objective, femelleId, femelleNom, items];
}

