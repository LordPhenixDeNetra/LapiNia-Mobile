abstract class AIProvider {
  Future<String> complete(String prompt, {int maxTokens = 1000});
  Future<bool> isAvailable();
  int getEstimatedCostFcfa(int tokens);
}

abstract class Diagnostician {
  Future<DiagnosticResult> diagnostiquer(String lapinId, List<String> symptomes);
}

class DiagnosticResult {
  final List<DiagnosticProbable> diagnostics;
  final String urgence;
  final String? traitement;
  final bool alerteEpidemique;
  final int? animauxTouches;

  const DiagnosticResult({
    required this.diagnostics,
    required this.urgence,
    this.traitement,
    this.alerteEpidemique = false,
    this.animauxTouches,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      diagnostics: (json['diagnostics'] as List<dynamic>?)
              ?.map((e) => DiagnosticProbable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      urgence: json['urgence'] as String? ?? 'INCONNUE',
      traitement: json['traitement'] as String?,
      alerteEpidemique: json['alerte_epidemique'] as bool? ?? false,
      animauxTouches: json['animaux_touches'] as int?,
    );
  }
}

class DiagnosticProbable {
  final String maladie;
  final double probabilitePourcent;
  final String description;
  final String? traitement;
  final String? medicament;
  final String? dosage;
  final int? delaiAbattageJours;
  final List<String> contreIndications;

  const DiagnosticProbable({
    required this.maladie,
    required this.probabilitePourcent,
    required this.description,
    this.traitement,
    this.medicament,
    this.dosage,
    this.delaiAbattageJours,
    this.contreIndications = const [],
  });

  factory DiagnosticProbable.fromJson(Map<String, dynamic> json) {
    return DiagnosticProbable(
      maladie: json['maladie'] as String,
      probabilitePourcent: double.tryParse(json['probabilite'].toString()) ?? 0,
      description: json['description'] as String? ?? '',
      traitement: json['traitement'] as String?,
      medicament: json['medicament'] as String?,
      dosage: json['dosage'] as String?,
      delaiAbattageJours: json['delai_abattage'] as int?,
      contreIndications: (json['contre_indications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
