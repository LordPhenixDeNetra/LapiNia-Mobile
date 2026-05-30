// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'lapiNia';

  @override
  String get welcomeTagline =>
      'Votre assistant intelligent\nd\'élevage cunicole';

  @override
  String get welcomeStart => 'Commencer';

  @override
  String get welcomeAlreadyAccount => 'J\'ai déjà un compte';

  @override
  String get welcomeOfflineNotice =>
      'Mode hors ligne disponible pour consulter vos données déjà synchronisées.';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitleSignIn => 'Connectez-vous avec votre email';

  @override
  String get loginSubtitleSignUp => 'Créez votre compte';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'vous@exemple.com';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordHint => '••••••••';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get loginToggleToSignIn => 'J\'ai déjà un compte';

  @override
  String get loginToggleToSignUp => 'Créer un compte';

  @override
  String signUpCheckEmail(String email) {
    return 'Compte créé. Vérifiez votre email: $email';
  }

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingRabbitsCountTitle => 'Combien de lapins avez-vous ?';

  @override
  String get onboardingRabbitsCountLt10 => 'Moins de 10';

  @override
  String get onboardingRabbitsCount10to50 => '10 à 50';

  @override
  String get onboardingRabbitsCount50to200 => '50 à 200';

  @override
  String get onboardingRabbitsCountGt200 => 'Plus de 200';

  @override
  String get onboardingGoalsTitle => 'Quel est votre objectif principal ?';

  @override
  String get onboardingGoalSellKits => 'Vente lapereaux';

  @override
  String get onboardingGoalMeat => 'Viande familiale';

  @override
  String get onboardingGoalBreeders => 'Reproducteurs';

  @override
  String get onboardingGoalHobby => 'Loisir';

  @override
  String get onboardingRegionTitle => 'Votre région ?';

  @override
  String get onboardingCountryLabel => 'Pays';

  @override
  String get onboardingCityLabel => 'Ville';

  @override
  String get onboardingCityHint => 'Ex: Dakar';

  @override
  String get onboardingRacesTitle => 'Quelles races avez-vous ?';

  @override
  String get onboardingRacesSkip =>
      'Vous pourrez renseigner cette information plus tard.';

  @override
  String get onboardingExperienceTitle => 'Votre niveau d\'expérience ?';

  @override
  String get onboardingExperienceBeginner => 'Débutant';

  @override
  String get onboardingExperienceIntermediate => 'Intermédiaire';

  @override
  String get onboardingExperienceExpert => 'Expert';

  @override
  String get onboardingAdviceTitle => 'Votre premier conseil';

  @override
  String get onboardingAdviceSubtitle => 'Conseil du jour';

  @override
  String get onboardingAdviceContinue => 'Continuer';

  @override
  String get onboardingAdviceFallbackSell =>
      'Commencez par suivre vos femelles gestantes et préparez une routine simple : eau fraîche, alimentation régulière et calendrier des mises bas.';

  @override
  String get onboardingAdviceFallbackMeat =>
      'Pour une production viande régulière, suivez le poids (pesées) et sécurisez l’alimentation : ration stable, eau propre, et observation quotidienne.';

  @override
  String get onboardingAdviceFallbackBreeders =>
      'Pour améliorer votre cheptel, tenez à jour la généalogie et évitez la consanguinité : notez parents, dates et performances de chaque portée.';

  @override
  String get onboardingAdviceFallbackGeneric =>
      'Démarrez simple : ajoutez vos lapins, enregistrez les saillies, puis utilisez les alertes pour ne rien oublier.';

  @override
  String get errorGeneric => 'Une erreur est survenue.';

  @override
  String get errorUnknown => 'Erreur inconnue';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteConfirmTitle => 'Supprimer';

  @override
  String deleteConfirmBody(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get goToLogin => 'Aller à la connexion';

  @override
  String get startupErrorTitle => 'Erreur au démarrage';

  @override
  String get dashboardTitle => 'Accueil';

  @override
  String get navHome => 'Accueil';

  @override
  String get navLapins => 'Lapins';

  @override
  String get navPortees => 'Portées';

  @override
  String get navIa => 'IA';

  @override
  String get navPlus => 'Plus';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusAlerts => 'Alertes';

  @override
  String get plusFeed => 'Aliments';

  @override
  String get plusSettings => 'Réglages';

  @override
  String get alertesTitle => 'Alertes';

  @override
  String get alertesFilterUnread => 'Non lues';

  @override
  String get alertesFilterAll => 'Toutes';

  @override
  String get alertesEmptyTitle => 'Aucune alerte';

  @override
  String get alertesEmptySubtitle => 'Tout est en ordre pour le moment.';

  @override
  String get alertesMarkRead => 'Marquer comme lue';

  @override
  String get alertesActionDone => 'Action faite';

  @override
  String get dashboardAlerts => 'Alertes';

  @override
  String get dashboardSeeAll => 'Voir tout';

  @override
  String get dashboardNoAlerts => 'Aucune alerte';

  @override
  String get dashboardNextBirths => 'Prochaines mises bas';

  @override
  String get dashboardSeeAllPortees => 'Voir tout';

  @override
  String get dashboardNoGestation => 'Aucune portée en gestation';

  @override
  String get dashboardUnknownMother => 'Mère';

  @override
  String dashboardGestationProgress(int elapsed, int remaining) {
    return 'J$elapsed — $remaining jours restants';
  }

  @override
  String get dashboardQuickActions => 'Actions rapides';

  @override
  String get quickAddLapin => 'Ajouter un lapin';

  @override
  String get quickNewSaillie => 'Nouvelle saillie';

  @override
  String get quickRecordEvent => 'Enregistrer';

  @override
  String get quickSync => 'Synchroniser';

  @override
  String quickSyncPending(int count) {
    return 'Synchroniser ($count)';
  }

  @override
  String get quickEventWeight => 'Pesée';

  @override
  String get quickEventHealth => 'Santé';

  @override
  String get quickEventStock => 'Stock';

  @override
  String get dashboardAiTipTitle => 'Conseil du jour';

  @override
  String get dashboardAiTipBody =>
      'La température prévue cette semaine est élevée. Assurez-vous que vos lapins ont accès à de l\'eau fraîche en quantité suffisante et à un espace ombragé.';

  @override
  String get dashboardAiTipWeather => '32°C prévu';

  @override
  String get loading => 'Chargement…';

  @override
  String get rentabilityTitle => 'Score de rentabilité';

  @override
  String rentabilityScoreValue(int score) {
    return '$score/100';
  }

  @override
  String get timelineTitle => 'Timeline (7 jours)';

  @override
  String get timelineAdd => 'Ajouter';

  @override
  String get timelineEmptyTitle => 'Rien à venir';

  @override
  String get timelineEmptySubtitle =>
      'Ajoutez une pesée ou un vaccin à planifier.';

  @override
  String timelineBirthTitle(String mother) {
    return 'Mise bas prévue — $mother';
  }

  @override
  String get timelineBirthSubtitle => 'Surveillez la préparation du nid.';

  @override
  String get timelineWeightTitle => 'Pesée à faire';

  @override
  String get timelineWeightSubtitle => 'Pesée planifiée';

  @override
  String get timelineVaccineTitle => 'Vaccin à faire';

  @override
  String get timelineVaccineSubtitle => 'Vaccin planifié';

  @override
  String get timelineAddTitle => 'Ajouter un événement';

  @override
  String get timelineAddWeight => 'Pesée';

  @override
  String get timelineAddVaccine => 'Vaccin';

  @override
  String get timelineAddLapin => 'Lapin';

  @override
  String get timelineAddDate => 'Date';

  @override
  String get timelineAddNote => 'Note (optionnel)';

  @override
  String get timelineAddSave => 'Enregistrer';

  @override
  String get timelineAddSaved => 'Événement ajouté';

  @override
  String get quickWeightTitle => 'Pesée rapide';

  @override
  String get quickWeightLapin => 'Lapin';

  @override
  String get quickWeightValueLabel => 'Poids';

  @override
  String get quickWeightUnit => 'g';

  @override
  String get quickWeightInvalid => 'Veuillez entrer un poids valide';

  @override
  String get quickWeightSave => 'Enregistrer';

  @override
  String get quickWeightSaved => 'Pesée enregistrée';

  @override
  String get quickWeightOffline => 'Pesée rapide indisponible hors ligne';

  @override
  String get quickWeightNoLapins =>
      'Ajoutez un lapin pour enregistrer une pesée';

  @override
  String get kpiLapins => 'Lapins';

  @override
  String get kpiGestantes => 'Gestantes';

  @override
  String get kpiAttendus => 'Attendus';

  @override
  String get kpiNextBirth => 'Prochaine naissance';

  @override
  String get kpiNextBirthNone => '—';

  @override
  String kpiNextBirthValue(String date, int days) {
    return '$date (J-$days)';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsConnection => 'Connexion';

  @override
  String get settingsSync => 'Synchronisation';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsOnline => 'En ligne';

  @override
  String get settingsOffline => 'Hors ligne';

  @override
  String get settingsOnlineHelp => 'Les données peuvent être synchronisées.';

  @override
  String get settingsOfflineHelp => 'Les actions seront mises en attente.';

  @override
  String get settingsStatusUnknown => 'Statut inconnu';

  @override
  String settingsQueueTitle(int count) {
    return '$count action(s) en attente';
  }

  @override
  String get refresh => 'Rafraîchir';

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get syncStarted => 'Synchronisation lancée';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonAll => 'Toutes';

  @override
  String get commonSelectDate => 'Sélectionner une date';

  @override
  String get commonCreate => 'Créer';

  @override
  String get commonUpdate => 'Mettre à jour';

  @override
  String get photoCamera => 'Caméra';

  @override
  String get photoGallery => 'Galerie';

  @override
  String get photoChangeRequiresOnline =>
      'Connexion requise pour changer la photo';

  @override
  String get photoUploadRequiresOnline =>
      'Connexion requise pour uploader la photo';

  @override
  String get photoTooLarge => 'Image trop lourde (max 200 Ko).';

  @override
  String get lapinsTitle => 'Mes Lapins';

  @override
  String get lapinTitle => 'Lapin';

  @override
  String get lapinAddWeightTitle => 'Ajouter une pesée';

  @override
  String get lapinWeightGramLabel => 'Poids (g)';

  @override
  String get lapinsFilterTitle => 'Filtrer';

  @override
  String get lapinsFilterStatut => 'Statut';

  @override
  String get lapinsFilterRace => 'Race';

  @override
  String get lapinsFilterSexe => 'Sexe';

  @override
  String get lapinsFilterReset => 'Réinitialiser';

  @override
  String get lapinsFilterApply => 'Appliquer';

  @override
  String get lapinFormIdentityStep => 'Identité';

  @override
  String get lapinFormParamsStep => 'Paramètres';

  @override
  String get lapinFormGenealogyStep => 'Généalogie';

  @override
  String get lapinFieldNom => 'Nom';

  @override
  String get lapinFieldDateNaissance => 'Date de naissance';

  @override
  String get lapinFieldPoidsActuel => 'Poids actuel (grammes)';

  @override
  String get lapinFieldNumeroIdentification => 'Numéro d\'identification';

  @override
  String get lapinFormFatherOptional => 'Père (optionnel)';

  @override
  String get lapinFormMotherOptional => 'Mère (optionnel)';

  @override
  String get lapinFormNoneMasculine => 'Aucun';

  @override
  String get lapinFormNoneFeminine => 'Aucune';

  @override
  String get lapinValidationNameRequired => 'Veuillez entrer un nom';

  @override
  String get lapinTabGrowth => 'Croissance';

  @override
  String get lapinTabHealth => 'Santé';

  @override
  String get lapinTabRepro => 'Repro';

  @override
  String get lapinTabInfo => 'Infos';

  @override
  String get growthNoWeights => 'Aucune pesée pour le moment.';

  @override
  String get growthLowGmqBadge => 'GMQ faible';

  @override
  String get growthPredictButton => 'Prédire';

  @override
  String get growthPredictTitle => 'Prédiction de croissance';

  @override
  String get growthPredictNeededGmq => 'GMQ nécessaire';

  @override
  String get growthPredictRaceGmq => 'GMQ norme race';

  @override
  String get growthPredictWeek10 => 'À 10 semaines';

  @override
  String get growthPredictWeek12 => 'À 12 semaines';

  @override
  String get growthPredictWeek14 => 'À 14 semaines';

  @override
  String get growthPredictSaleDate => 'Date vente optimale';

  @override
  String get growthPredictNoSaleDate => '—';

  @override
  String comingSoonLabel(String title) {
    return '$title : à venir';
  }

  @override
  String get lapinInfoSection => 'Infos';

  @override
  String get lapinNotesSection => 'Notes';

  @override
  String get lapinFieldRace => 'Race';

  @override
  String get lapinFieldSexe => 'Sexe';

  @override
  String get lapinFieldStatut => 'Statut';

  @override
  String get lapinFieldPoids => 'Poids';

  @override
  String get lapinFieldAge => 'Âge';

  @override
  String get lapinFieldId => 'ID';

  @override
  String get lapinOfflineNotFound => 'Lapin introuvable hors ligne';

  @override
  String get lapinsSearchHint => 'Rechercher un lapin...';

  @override
  String get lapinsEmptyTitle => 'Aucun lapin';

  @override
  String get lapinsEmptySubtitle =>
      'Ajoutez votre premier lapin pour commencer.';

  @override
  String get lapinsEmptyAction => 'Ajouter un lapin';

  @override
  String get porteesTitle => 'Mes Portées';

  @override
  String get porteesEmpty => 'Aucune portée';

  @override
  String get porteesEmptySubtitle =>
      'Créez votre première saillie pour suivre une portée.';

  @override
  String get porteesEmptyAction => 'Nouvelle saillie';

  @override
  String get newSaillie => 'Nouvelle saillie';

  @override
  String get save => 'Enregistrer';

  @override
  String get validationEmailRequired => 'Veuillez entrer votre email';

  @override
  String get validationEmailInvalid => 'Email invalide';

  @override
  String get validationPasswordRequired => 'Veuillez entrer votre mot de passe';

  @override
  String get validationPasswordTooShort => 'Mot de passe trop court';

  @override
  String get plusRaces => 'Races';

  @override
  String get racesTitle => 'Races';

  @override
  String get racesSearchHint => 'Rechercher une race...';

  @override
  String get racesEmptyTitle => 'Aucune race';

  @override
  String get racesEmptySubtitle =>
      'Vérifiez que la table \"races\" contient des données.';

  @override
  String get racesNoSummary => 'Voir les détails';

  @override
  String racesWeightRange(String min, String max) {
    return 'Poids adulte: $min–$max kg';
  }

  @override
  String racesGmqTarget(String gmq) {
    return 'GMQ cible: $gmq g/j';
  }

  @override
  String racesHeatScore(String score) {
    return 'Chaleur: $score/5';
  }

  @override
  String get racesCompareCta => 'Comparer';

  @override
  String get racesCompareTitle => 'Comparateur de races';

  @override
  String get racesCompareMetricColumn => 'Critère';

  @override
  String get racesComparePickTitle => 'Sélectionnez 2–3 races';

  @override
  String get racesCompareNeedTwoTitle => 'Sélectionnez au moins 2 races';

  @override
  String get racesCompareNeedTwoSubtitle =>
      'Choisissez 2 ou 3 races pour afficher le tableau comparatif.';

  @override
  String get racesComparePickMoreCta => 'Choisir des races';

  @override
  String get racesRecommendCta => 'Recommander';

  @override
  String get racesRecommendTitle => 'Recommandation de race';

  @override
  String get racesRecommendFormTitle => 'Votre contexte';

  @override
  String get racesCountryLabel => 'Pays';

  @override
  String get racesCityLabel => 'Ville';

  @override
  String get racesGoalLabel => 'Objectif';

  @override
  String get racesResourcesLabel => 'Ressources disponibles';

  @override
  String get racesAiNotConfigured => 'IA non configurée sur le serveur.';

  @override
  String get racesRecommendEmptyTitle => 'Recommandation';

  @override
  String get racesRecommendEmptySubtitle =>
      'Remplissez le formulaire puis lancez la recommandation.';

  @override
  String get racesRecommendNoResultTitle => 'Aucune recommandation';

  @override
  String get racesRecommendNoResultSubtitle =>
      'Réessayez avec un autre objectif ou d\'autres ressources.';

  @override
  String get racesRecommendResultTitle => 'Top recommandations';

  @override
  String get racesRecommendReasonsLabel => 'Pourquoi';

  @override
  String get racesRecommendWarningsLabel => 'Points d\'attention';

  @override
  String get racesGoalMeat => 'Viande';

  @override
  String get racesGoalBreeding => 'Reproduction';

  @override
  String get racesGoalHeatResilience => 'Climat chaud';

  @override
  String get raceDetailTitle => 'Fiche race';

  @override
  String get raceNotFoundTitle => 'Race introuvable';

  @override
  String get raceNotFoundSubtitle => 'Impossible de charger cette race.';

  @override
  String get raceSectionPerformance => 'Performance';

  @override
  String get raceSectionReproduction => 'Reproduction';

  @override
  String get raceSectionClimate => 'Climat';

  @override
  String get raceSectionHealth => 'Santé';

  @override
  String get raceAdultWeightLabel => 'Poids adulte';

  @override
  String get raceGmqLabel => 'GMQ cible';

  @override
  String raceGmqValue(int gmq) {
    return '$gmq g/j';
  }

  @override
  String get raceLitterSizeLabel => 'Taille portée moyenne';

  @override
  String raceLitterSizeValue(double value) {
    return '$value';
  }

  @override
  String get raceFirstBirthAgeLabel => 'Âge 1ère mise bas';

  @override
  String raceFirstBirthAgeValue(int days) {
    return '$days jours';
  }

  @override
  String get raceHeatAdaptationLabel => 'Adaptation chaleur';

  @override
  String raceHeatAdaptationValue(int score) {
    return '$score/5';
  }

  @override
  String get raceNoSensitivities => 'Aucune sensibilité renseignée.';
}
