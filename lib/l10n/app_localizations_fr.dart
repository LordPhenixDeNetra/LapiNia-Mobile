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
  String get kpiLapins => 'Lapins';

  @override
  String get kpiGestantes => 'Gestantes';

  @override
  String get kpiAttendus => 'Attendus';

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
  String get lapinsTitle => 'Mes Lapins';

  @override
  String get lapinTitle => 'Lapin';

  @override
  String get lapinAddWeightTitle => 'Ajouter une pesée';

  @override
  String get lapinWeightGramLabel => 'Poids (g)';

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
}
