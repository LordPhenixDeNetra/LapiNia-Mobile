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
  String get errorGeneric => 'Une erreur est survenue.';

  @override
  String get errorUnknown => 'Erreur inconnue';

  @override
  String get retry => 'Réessayer';

  @override
  String get goToLogin => 'Aller à la connexion';

  @override
  String get startupErrorTitle => 'Erreur au démarrage';

  @override
  String get dashboardTitle => 'Accueil';

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
  String get lapinsSearchHint => 'Rechercher un lapin...';

  @override
  String get porteesTitle => 'Mes Portées';

  @override
  String get porteesEmpty => 'Aucune portée';

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
