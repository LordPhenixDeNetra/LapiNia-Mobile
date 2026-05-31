import 'package:equatable/equatable.dart';

class FertilityScoreBreakdown extends Equatable {
  final int acceptation;
  final int taillePortees;
  final int survieLapereaux;
  final int regularite;

  const FertilityScoreBreakdown({
    required this.acceptation,
    required this.taillePortees,
    required this.survieLapereaux,
    required this.regularite,
  });

  int get total => acceptation + taillePortees + survieLapereaux + regularite;

  Map<String, dynamic> toJson() {
    return {
      'acceptation': acceptation,
      'taillePortees': taillePortees,
      'survieLapereaux': survieLapereaux,
      'regularite': regularite,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [acceptation, taillePortees, survieLapereaux, regularite];
}

class FertilityScoreResult extends Equatable {
  final FertilityScoreBreakdown breakdown;
  final int porteesCount;
  final int porteesWithMiseBasCount;
  final double? avgLitterSize;
  final double? survivalRate;
  final double? avgIntervalDays;

  const FertilityScoreResult({
    required this.breakdown,
    required this.porteesCount,
    required this.porteesWithMiseBasCount,
    required this.avgLitterSize,
    required this.survivalRate,
    required this.avgIntervalDays,
  });

  int get total => breakdown.total;

  Map<String, dynamic> toHistoryDataJson() {
    return {
      'breakdown': breakdown.toJson(),
      'porteesCount': porteesCount,
      'porteesWithMiseBasCount': porteesWithMiseBasCount,
      'avgLitterSize': avgLitterSize,
      'survivalRate': survivalRate,
      'avgIntervalDays': avgIntervalDays,
    };
  }

  @override
  List<Object?> get props => [
        breakdown,
        porteesCount,
        porteesWithMiseBasCount,
        avgLitterSize,
        survivalRate,
        avgIntervalDays,
      ];
}

