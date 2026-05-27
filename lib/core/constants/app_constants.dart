class AppConstants {
  static const String appName = 'lapiNia';
  static const String appVersion = '1.0.0';

  static const int maxLapinsGratuit = 10;
  static const int maxQuestionsIAMoisGratuit = 15;

  static const int paginationLimit = 20;
  static const int maxPaginationLimit = 100;

  static const int delaiSecondesOTP = 60;
  static const int delaiReessaiOTP = 60;

  static const int gmQNormeMinPourcentage = 80;
  static const int gmQLapereauMinGainJournalier = 10;

  static const double coefficientConsanguinAcceptable = 6.25;
  static const double coefficientConsanguinBlocage = 12.5;

  static const int joursGestationMin = 28;
  static const int joursGestationMax = 32;
  static const int joursGestationMoyenne = 31;

  static const int joursSevrageMin = 28;
  static const int joursSevrageMax = 35;

  static const int joursTransitionAlimentaire = 7;

  static const double temperatureOptimaleMaterniteMin = 28.0;
  static const double temperatureOptimaleMaterniteMax = 30.0;
  static const double temperatureStressThermique = 30.0;

  static const double facteurRationRepos = 1.0;
  static const double facteurRationGestation = 1.2;
  static const double facteurRationLactation = 1.4;
  static const double facteurRationEngraissement = 1.15;

  static const int nbPesLactationJours = 4;
  static const List<int> joursPesLactation = [1, 7, 14, 21];

  static const int nbJalonsGestation = 5;
  static const List<int> joursJalonsGestation = [7, 14, 25, 28, 31];

  static const int nbLepinsMinAlerteEpidemique = 3;
  static const int delaiHeureAlerteEpidemique = 48;

  static const double seuilStockVert = 50.0;
  static const double seuilStockOrange = 20.0;
}
