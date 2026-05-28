import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'lapiNia'**
  String get appName;

  /// No description provided for @welcomeTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre assistant intelligent\nd\'élevage cunicole'**
  String get welcomeTagline;

  /// No description provided for @welcomeStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get welcomeStart;

  /// No description provided for @welcomeAlreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un compte'**
  String get welcomeAlreadyAccount;

  /// No description provided for @welcomeOfflineNotice.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne disponible pour consulter vos données déjà synchronisées.'**
  String get welcomeOfflineNotice;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginSubtitleSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous avec votre email'**
  String get loginSubtitleSignIn;

  /// No description provided for @loginSubtitleSignUp.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte'**
  String get loginSubtitleSignUp;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'vous@exemple.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In fr, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUp;

  /// No description provided for @loginToggleToSignIn.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un compte'**
  String get loginToggleToSignIn;

  /// No description provided for @loginToggleToSignUp.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get loginToggleToSignUp;

  /// No description provided for @signUpCheckEmail.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé. Vérifiez votre email: {email}'**
  String signUpCheckEmail(String email);

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get errorGeneric;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inconnue'**
  String get errorUnknown;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {name} ?'**
  String deleteConfirmBody(String name);

  /// No description provided for @goToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Aller à la connexion'**
  String get goToLogin;

  /// No description provided for @startupErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Erreur au démarrage'**
  String get startupErrorTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get dashboardTitle;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navLapins.
  ///
  /// In fr, this message translates to:
  /// **'Lapins'**
  String get navLapins;

  /// No description provided for @navPortees.
  ///
  /// In fr, this message translates to:
  /// **'Portées'**
  String get navPortees;

  /// No description provided for @navIa.
  ///
  /// In fr, this message translates to:
  /// **'IA'**
  String get navIa;

  /// No description provided for @navPlus.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navPlus;

  /// No description provided for @plusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get plusTitle;

  /// No description provided for @plusAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get plusAlerts;

  /// No description provided for @plusFeed.
  ///
  /// In fr, this message translates to:
  /// **'Aliments'**
  String get plusFeed;

  /// No description provided for @plusSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get plusSettings;

  /// No description provided for @alertesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alertesTitle;

  /// No description provided for @alertesFilterUnread.
  ///
  /// In fr, this message translates to:
  /// **'Non lues'**
  String get alertesFilterUnread;

  /// No description provided for @alertesFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get alertesFilterAll;

  /// No description provided for @alertesEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte'**
  String get alertesEmptyTitle;

  /// No description provided for @alertesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tout est en ordre pour le moment.'**
  String get alertesEmptySubtitle;

  /// No description provided for @alertesMarkRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme lue'**
  String get alertesMarkRead;

  /// No description provided for @alertesActionDone.
  ///
  /// In fr, this message translates to:
  /// **'Action faite'**
  String get alertesActionDone;

  /// No description provided for @dashboardAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get dashboardAlerts;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardNoAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte'**
  String get dashboardNoAlerts;

  /// No description provided for @dashboardNextBirths.
  ///
  /// In fr, this message translates to:
  /// **'Prochaines mises bas'**
  String get dashboardNextBirths;

  /// No description provided for @dashboardSeeAllPortees.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get dashboardSeeAllPortees;

  /// No description provided for @dashboardNoGestation.
  ///
  /// In fr, this message translates to:
  /// **'Aucune portée en gestation'**
  String get dashboardNoGestation;

  /// No description provided for @dashboardUnknownMother.
  ///
  /// In fr, this message translates to:
  /// **'Mère'**
  String get dashboardUnknownMother;

  /// No description provided for @dashboardGestationProgress.
  ///
  /// In fr, this message translates to:
  /// **'J{elapsed} — {remaining} jours restants'**
  String dashboardGestationProgress(int elapsed, int remaining);

  /// No description provided for @dashboardQuickActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get dashboardQuickActions;

  /// No description provided for @quickAddLapin.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un lapin'**
  String get quickAddLapin;

  /// No description provided for @quickNewSaillie.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle saillie'**
  String get quickNewSaillie;

  /// No description provided for @quickRecordEvent.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get quickRecordEvent;

  /// No description provided for @quickSync.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser'**
  String get quickSync;

  /// No description provided for @quickSyncPending.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser ({count})'**
  String quickSyncPending(int count);

  /// No description provided for @quickEventWeight.
  ///
  /// In fr, this message translates to:
  /// **'Pesée'**
  String get quickEventWeight;

  /// No description provided for @quickEventHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get quickEventHealth;

  /// No description provided for @quickEventStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get quickEventStock;

  /// No description provided for @dashboardAiTipTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conseil du jour'**
  String get dashboardAiTipTitle;

  /// No description provided for @dashboardAiTipBody.
  ///
  /// In fr, this message translates to:
  /// **'La température prévue cette semaine est élevée. Assurez-vous que vos lapins ont accès à de l\'eau fraîche en quantité suffisante et à un espace ombragé.'**
  String get dashboardAiTipBody;

  /// No description provided for @dashboardAiTipWeather.
  ///
  /// In fr, this message translates to:
  /// **'32°C prévu'**
  String get dashboardAiTipWeather;

  /// No description provided for @kpiLapins.
  ///
  /// In fr, this message translates to:
  /// **'Lapins'**
  String get kpiLapins;

  /// No description provided for @kpiGestantes.
  ///
  /// In fr, this message translates to:
  /// **'Gestantes'**
  String get kpiGestantes;

  /// No description provided for @kpiAttendus.
  ///
  /// In fr, this message translates to:
  /// **'Attendus'**
  String get kpiAttendus;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsConnection.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get settingsConnection;

  /// No description provided for @settingsSync.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get settingsSync;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @settingsOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get settingsOnline;

  /// No description provided for @settingsOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get settingsOffline;

  /// No description provided for @settingsOnlineHelp.
  ///
  /// In fr, this message translates to:
  /// **'Les données peuvent être synchronisées.'**
  String get settingsOnlineHelp;

  /// No description provided for @settingsOfflineHelp.
  ///
  /// In fr, this message translates to:
  /// **'Les actions seront mises en attente.'**
  String get settingsOfflineHelp;

  /// No description provided for @settingsStatusUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Statut inconnu'**
  String get settingsStatusUnknown;

  /// No description provided for @settingsQueueTitle.
  ///
  /// In fr, this message translates to:
  /// **'{count} action(s) en attente'**
  String settingsQueueTitle(int count);

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir'**
  String get refresh;

  /// No description provided for @syncNow.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser'**
  String get syncNow;

  /// No description provided for @syncStarted.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation lancée'**
  String get syncStarted;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @lapinsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes Lapins'**
  String get lapinsTitle;

  /// No description provided for @lapinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lapin'**
  String get lapinTitle;

  /// No description provided for @lapinAddWeightTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une pesée'**
  String get lapinAddWeightTitle;

  /// No description provided for @lapinWeightGramLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poids (g)'**
  String get lapinWeightGramLabel;

  /// No description provided for @lapinInfoSection.
  ///
  /// In fr, this message translates to:
  /// **'Infos'**
  String get lapinInfoSection;

  /// No description provided for @lapinNotesSection.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get lapinNotesSection;

  /// No description provided for @lapinFieldRace.
  ///
  /// In fr, this message translates to:
  /// **'Race'**
  String get lapinFieldRace;

  /// No description provided for @lapinFieldSexe.
  ///
  /// In fr, this message translates to:
  /// **'Sexe'**
  String get lapinFieldSexe;

  /// No description provided for @lapinFieldStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get lapinFieldStatut;

  /// No description provided for @lapinFieldPoids.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get lapinFieldPoids;

  /// No description provided for @lapinFieldAge.
  ///
  /// In fr, this message translates to:
  /// **'Âge'**
  String get lapinFieldAge;

  /// No description provided for @lapinFieldId.
  ///
  /// In fr, this message translates to:
  /// **'ID'**
  String get lapinFieldId;

  /// No description provided for @lapinsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un lapin...'**
  String get lapinsSearchHint;

  /// No description provided for @lapinsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lapin'**
  String get lapinsEmptyTitle;

  /// No description provided for @lapinsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre premier lapin pour commencer.'**
  String get lapinsEmptySubtitle;

  /// No description provided for @lapinsEmptyAction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un lapin'**
  String get lapinsEmptyAction;

  /// No description provided for @porteesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes Portées'**
  String get porteesTitle;

  /// No description provided for @porteesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune portée'**
  String get porteesEmpty;

  /// No description provided for @porteesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre première saillie pour suivre une portée.'**
  String get porteesEmptySubtitle;

  /// No description provided for @porteesEmptyAction.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle saillie'**
  String get porteesEmptyAction;

  /// No description provided for @newSaillie.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle saillie'**
  String get newSaillie;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @validationEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop court'**
  String get validationPasswordTooShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
