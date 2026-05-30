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

  /// No description provided for @onboardingNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingStart;

  /// No description provided for @onboardingRabbitsCountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Combien de lapins avez-vous ?'**
  String get onboardingRabbitsCountTitle;

  /// No description provided for @onboardingRabbitsCountLt10.
  ///
  /// In fr, this message translates to:
  /// **'Moins de 10'**
  String get onboardingRabbitsCountLt10;

  /// No description provided for @onboardingRabbitsCount10to50.
  ///
  /// In fr, this message translates to:
  /// **'10 à 50'**
  String get onboardingRabbitsCount10to50;

  /// No description provided for @onboardingRabbitsCount50to200.
  ///
  /// In fr, this message translates to:
  /// **'50 à 200'**
  String get onboardingRabbitsCount50to200;

  /// No description provided for @onboardingRabbitsCountGt200.
  ///
  /// In fr, this message translates to:
  /// **'Plus de 200'**
  String get onboardingRabbitsCountGt200;

  /// No description provided for @onboardingGoalsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quel est votre objectif principal ?'**
  String get onboardingGoalsTitle;

  /// No description provided for @onboardingGoalSellKits.
  ///
  /// In fr, this message translates to:
  /// **'Vente lapereaux'**
  String get onboardingGoalSellKits;

  /// No description provided for @onboardingGoalMeat.
  ///
  /// In fr, this message translates to:
  /// **'Viande familiale'**
  String get onboardingGoalMeat;

  /// No description provided for @onboardingGoalBreeders.
  ///
  /// In fr, this message translates to:
  /// **'Reproducteurs'**
  String get onboardingGoalBreeders;

  /// No description provided for @onboardingGoalHobby.
  ///
  /// In fr, this message translates to:
  /// **'Loisir'**
  String get onboardingGoalHobby;

  /// No description provided for @onboardingRegionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre région ?'**
  String get onboardingRegionTitle;

  /// No description provided for @onboardingCountryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get onboardingCountryLabel;

  /// No description provided for @onboardingCityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get onboardingCityLabel;

  /// No description provided for @onboardingCityHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Dakar'**
  String get onboardingCityHint;

  /// No description provided for @onboardingRacesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quelles races avez-vous ?'**
  String get onboardingRacesTitle;

  /// No description provided for @onboardingRacesSkip.
  ///
  /// In fr, this message translates to:
  /// **'Vous pourrez renseigner cette information plus tard.'**
  String get onboardingRacesSkip;

  /// No description provided for @onboardingExperienceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre niveau d\'expérience ?'**
  String get onboardingExperienceTitle;

  /// No description provided for @onboardingExperienceBeginner.
  ///
  /// In fr, this message translates to:
  /// **'Débutant'**
  String get onboardingExperienceBeginner;

  /// No description provided for @onboardingExperienceIntermediate.
  ///
  /// In fr, this message translates to:
  /// **'Intermédiaire'**
  String get onboardingExperienceIntermediate;

  /// No description provided for @onboardingExperienceExpert.
  ///
  /// In fr, this message translates to:
  /// **'Expert'**
  String get onboardingExperienceExpert;

  /// No description provided for @onboardingAdviceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre premier conseil'**
  String get onboardingAdviceTitle;

  /// No description provided for @onboardingAdviceSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Conseil du jour'**
  String get onboardingAdviceSubtitle;

  /// No description provided for @onboardingAdviceContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get onboardingAdviceContinue;

  /// No description provided for @onboardingAdviceFallbackSell.
  ///
  /// In fr, this message translates to:
  /// **'Commencez par suivre vos femelles gestantes et préparez une routine simple : eau fraîche, alimentation régulière et calendrier des mises bas.'**
  String get onboardingAdviceFallbackSell;

  /// No description provided for @onboardingAdviceFallbackMeat.
  ///
  /// In fr, this message translates to:
  /// **'Pour une production viande régulière, suivez le poids (pesées) et sécurisez l’alimentation : ration stable, eau propre, et observation quotidienne.'**
  String get onboardingAdviceFallbackMeat;

  /// No description provided for @onboardingAdviceFallbackBreeders.
  ///
  /// In fr, this message translates to:
  /// **'Pour améliorer votre cheptel, tenez à jour la généalogie et évitez la consanguinité : notez parents, dates et performances de chaque portée.'**
  String get onboardingAdviceFallbackBreeders;

  /// No description provided for @onboardingAdviceFallbackGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Démarrez simple : ajoutez vos lapins, enregistrez les saillies, puis utilisez les alertes pour ne rien oublier.'**
  String get onboardingAdviceFallbackGeneric;

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

  /// No description provided for @plusQrScan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner QR'**
  String get plusQrScan;

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

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loading;

  /// No description provided for @rentabilityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Score de rentabilité'**
  String get rentabilityTitle;

  /// No description provided for @rentabilityScoreValue.
  ///
  /// In fr, this message translates to:
  /// **'{score}/100'**
  String rentabilityScoreValue(int score);

  /// No description provided for @timelineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Timeline (7 jours)'**
  String get timelineTitle;

  /// No description provided for @timelineAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get timelineAdd;

  /// No description provided for @timelineEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien à venir'**
  String get timelineEmptyTitle;

  /// No description provided for @timelineEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une pesée ou un vaccin à planifier.'**
  String get timelineEmptySubtitle;

  /// No description provided for @timelineBirthTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise bas prévue — {mother}'**
  String timelineBirthTitle(String mother);

  /// No description provided for @timelineBirthSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Surveillez la préparation du nid.'**
  String get timelineBirthSubtitle;

  /// No description provided for @timelineWeightTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pesée à faire'**
  String get timelineWeightTitle;

  /// No description provided for @timelineWeightSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pesée planifiée'**
  String get timelineWeightSubtitle;

  /// No description provided for @timelineVaccineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vaccin à faire'**
  String get timelineVaccineTitle;

  /// No description provided for @timelineVaccineSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vaccin planifié'**
  String get timelineVaccineSubtitle;

  /// No description provided for @timelineAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un événement'**
  String get timelineAddTitle;

  /// No description provided for @timelineAddWeight.
  ///
  /// In fr, this message translates to:
  /// **'Pesée'**
  String get timelineAddWeight;

  /// No description provided for @timelineAddVaccine.
  ///
  /// In fr, this message translates to:
  /// **'Vaccin'**
  String get timelineAddVaccine;

  /// No description provided for @timelineAddLapin.
  ///
  /// In fr, this message translates to:
  /// **'Lapin'**
  String get timelineAddLapin;

  /// No description provided for @timelineAddDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get timelineAddDate;

  /// No description provided for @timelineAddNote.
  ///
  /// In fr, this message translates to:
  /// **'Note (optionnel)'**
  String get timelineAddNote;

  /// No description provided for @timelineAddSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get timelineAddSave;

  /// No description provided for @timelineAddSaved.
  ///
  /// In fr, this message translates to:
  /// **'Événement ajouté'**
  String get timelineAddSaved;

  /// No description provided for @quickWeightTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pesée rapide'**
  String get quickWeightTitle;

  /// No description provided for @quickWeightLapin.
  ///
  /// In fr, this message translates to:
  /// **'Lapin'**
  String get quickWeightLapin;

  /// No description provided for @quickWeightValueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get quickWeightValueLabel;

  /// No description provided for @quickWeightUnit.
  ///
  /// In fr, this message translates to:
  /// **'g'**
  String get quickWeightUnit;

  /// No description provided for @quickWeightInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un poids valide'**
  String get quickWeightInvalid;

  /// No description provided for @quickWeightSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get quickWeightSave;

  /// No description provided for @quickWeightSaved.
  ///
  /// In fr, this message translates to:
  /// **'Pesée enregistrée'**
  String get quickWeightSaved;

  /// No description provided for @quickWeightOffline.
  ///
  /// In fr, this message translates to:
  /// **'Pesée rapide indisponible hors ligne'**
  String get quickWeightOffline;

  /// No description provided for @quickWeightNoLapins.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un lapin pour enregistrer une pesée'**
  String get quickWeightNoLapins;

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

  /// No description provided for @kpiNextBirth.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine naissance'**
  String get kpiNextBirth;

  /// No description provided for @kpiNextBirthNone.
  ///
  /// In fr, this message translates to:
  /// **'—'**
  String get kpiNextBirthNone;

  /// No description provided for @kpiNextBirthValue.
  ///
  /// In fr, this message translates to:
  /// **'{date} (J-{days})'**
  String kpiNextBirthValue(String date, int days);

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

  /// No description provided for @commonNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get commonAll;

  /// No description provided for @commonSelectDate.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date'**
  String get commonSelectDate;

  /// No description provided for @commonCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get commonCreate;

  /// No description provided for @commonUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get commonUpdate;

  /// No description provided for @photoCamera.
  ///
  /// In fr, this message translates to:
  /// **'Caméra'**
  String get photoCamera;

  /// No description provided for @photoGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get photoGallery;

  /// No description provided for @photoChangeRequiresOnline.
  ///
  /// In fr, this message translates to:
  /// **'Connexion requise pour changer la photo'**
  String get photoChangeRequiresOnline;

  /// No description provided for @photoUploadRequiresOnline.
  ///
  /// In fr, this message translates to:
  /// **'Connexion requise pour uploader la photo'**
  String get photoUploadRequiresOnline;

  /// No description provided for @photoTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Image trop lourde (max 200 Ko).'**
  String get photoTooLarge;

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

  /// No description provided for @lapinsFilterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get lapinsFilterTitle;

  /// No description provided for @lapinsFilterStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get lapinsFilterStatut;

  /// No description provided for @lapinsFilterRace.
  ///
  /// In fr, this message translates to:
  /// **'Race'**
  String get lapinsFilterRace;

  /// No description provided for @lapinsFilterSexe.
  ///
  /// In fr, this message translates to:
  /// **'Sexe'**
  String get lapinsFilterSexe;

  /// No description provided for @lapinsFilterReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get lapinsFilterReset;

  /// No description provided for @lapinsFilterApply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get lapinsFilterApply;

  /// No description provided for @lapinFormIdentityStep.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get lapinFormIdentityStep;

  /// No description provided for @lapinFormParamsStep.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get lapinFormParamsStep;

  /// No description provided for @lapinFormGenealogyStep.
  ///
  /// In fr, this message translates to:
  /// **'Généalogie'**
  String get lapinFormGenealogyStep;

  /// No description provided for @lapinFieldNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lapinFieldNom;

  /// No description provided for @lapinFieldDateNaissance.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get lapinFieldDateNaissance;

  /// No description provided for @lapinFieldPoidsActuel.
  ///
  /// In fr, this message translates to:
  /// **'Poids actuel (grammes)'**
  String get lapinFieldPoidsActuel;

  /// No description provided for @lapinFieldNumeroIdentification.
  ///
  /// In fr, this message translates to:
  /// **'Numéro d\'identification'**
  String get lapinFieldNumeroIdentification;

  /// No description provided for @lapinFormFatherOptional.
  ///
  /// In fr, this message translates to:
  /// **'Père (optionnel)'**
  String get lapinFormFatherOptional;

  /// No description provided for @lapinFormMotherOptional.
  ///
  /// In fr, this message translates to:
  /// **'Mère (optionnel)'**
  String get lapinFormMotherOptional;

  /// No description provided for @lapinFormNoneMasculine.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get lapinFormNoneMasculine;

  /// No description provided for @lapinFormNoneFeminine.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get lapinFormNoneFeminine;

  /// No description provided for @lapinValidationNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un nom'**
  String get lapinValidationNameRequired;

  /// No description provided for @lapinTabGrowth.
  ///
  /// In fr, this message translates to:
  /// **'Croissance'**
  String get lapinTabGrowth;

  /// No description provided for @lapinTabHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get lapinTabHealth;

  /// No description provided for @lapinTabRepro.
  ///
  /// In fr, this message translates to:
  /// **'Repro'**
  String get lapinTabRepro;

  /// No description provided for @lapinTabInfo.
  ///
  /// In fr, this message translates to:
  /// **'Infos'**
  String get lapinTabInfo;

  /// No description provided for @growthNoWeights.
  ///
  /// In fr, this message translates to:
  /// **'Aucune pesée pour le moment.'**
  String get growthNoWeights;

  /// No description provided for @growthLowGmqBadge.
  ///
  /// In fr, this message translates to:
  /// **'GMQ faible'**
  String get growthLowGmqBadge;

  /// No description provided for @growthPredictButton.
  ///
  /// In fr, this message translates to:
  /// **'Prédire'**
  String get growthPredictButton;

  /// No description provided for @growthPredictTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prédiction de croissance'**
  String get growthPredictTitle;

  /// No description provided for @growthPredictNeededGmq.
  ///
  /// In fr, this message translates to:
  /// **'GMQ nécessaire'**
  String get growthPredictNeededGmq;

  /// No description provided for @growthPredictRaceGmq.
  ///
  /// In fr, this message translates to:
  /// **'GMQ norme race'**
  String get growthPredictRaceGmq;

  /// No description provided for @growthPredictWeek10.
  ///
  /// In fr, this message translates to:
  /// **'À 10 semaines'**
  String get growthPredictWeek10;

  /// No description provided for @growthPredictWeek12.
  ///
  /// In fr, this message translates to:
  /// **'À 12 semaines'**
  String get growthPredictWeek12;

  /// No description provided for @growthPredictWeek14.
  ///
  /// In fr, this message translates to:
  /// **'À 14 semaines'**
  String get growthPredictWeek14;

  /// No description provided for @growthPredictSaleDate.
  ///
  /// In fr, this message translates to:
  /// **'Date vente optimale'**
  String get growthPredictSaleDate;

  /// No description provided for @growthPredictNoSaleDate.
  ///
  /// In fr, this message translates to:
  /// **'—'**
  String get growthPredictNoSaleDate;

  /// No description provided for @comingSoonLabel.
  ///
  /// In fr, this message translates to:
  /// **'{title} : à venir'**
  String comingSoonLabel(String title);

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

  /// No description provided for @lapinOfflineNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Lapin introuvable hors ligne'**
  String get lapinOfflineNotFound;

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

  /// No description provided for @plusRaces.
  ///
  /// In fr, this message translates to:
  /// **'Races'**
  String get plusRaces;

  /// No description provided for @qrLapinTitle.
  ///
  /// In fr, this message translates to:
  /// **'QR code du lapin'**
  String get qrLapinTitle;

  /// No description provided for @qrShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get qrShare;

  /// No description provided for @qrPrint.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer'**
  String get qrPrint;

  /// No description provided for @qrScanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un QR code'**
  String get qrScanTitle;

  /// No description provided for @qrScanInvalid.
  ///
  /// In fr, this message translates to:
  /// **'QR code non reconnu'**
  String get qrScanInvalid;

  /// No description provided for @racesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Races'**
  String get racesTitle;

  /// No description provided for @racesSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une race...'**
  String get racesSearchHint;

  /// No description provided for @racesEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune race'**
  String get racesEmptyTitle;

  /// No description provided for @racesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez que la table \"races\" contient des données.'**
  String get racesEmptySubtitle;

  /// No description provided for @racesNoSummary.
  ///
  /// In fr, this message translates to:
  /// **'Voir les détails'**
  String get racesNoSummary;

  /// No description provided for @racesWeightRange.
  ///
  /// In fr, this message translates to:
  /// **'Poids adulte: {min}–{max} kg'**
  String racesWeightRange(String min, String max);

  /// No description provided for @racesGmqTarget.
  ///
  /// In fr, this message translates to:
  /// **'GMQ cible: {gmq} g/j'**
  String racesGmqTarget(String gmq);

  /// No description provided for @racesHeatScore.
  ///
  /// In fr, this message translates to:
  /// **'Chaleur: {score}/5'**
  String racesHeatScore(String score);

  /// No description provided for @racesCompareCta.
  ///
  /// In fr, this message translates to:
  /// **'Comparer'**
  String get racesCompareCta;

  /// No description provided for @racesCompareTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comparateur de races'**
  String get racesCompareTitle;

  /// No description provided for @racesCompareMetricColumn.
  ///
  /// In fr, this message translates to:
  /// **'Critère'**
  String get racesCompareMetricColumn;

  /// No description provided for @racesComparePickTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez 2–3 races'**
  String get racesComparePickTitle;

  /// No description provided for @racesCompareNeedTwoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins 2 races'**
  String get racesCompareNeedTwoTitle;

  /// No description provided for @racesCompareNeedTwoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez 2 ou 3 races pour afficher le tableau comparatif.'**
  String get racesCompareNeedTwoSubtitle;

  /// No description provided for @racesComparePickMoreCta.
  ///
  /// In fr, this message translates to:
  /// **'Choisir des races'**
  String get racesComparePickMoreCta;

  /// No description provided for @racesRecommendCta.
  ///
  /// In fr, this message translates to:
  /// **'Recommander'**
  String get racesRecommendCta;

  /// No description provided for @racesRecommendTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recommandation de race'**
  String get racesRecommendTitle;

  /// No description provided for @racesRecommendFormTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre contexte'**
  String get racesRecommendFormTitle;

  /// No description provided for @racesCountryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get racesCountryLabel;

  /// No description provided for @racesCityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get racesCityLabel;

  /// No description provided for @racesGoalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get racesGoalLabel;

  /// No description provided for @racesResourcesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ressources disponibles'**
  String get racesResourcesLabel;

  /// No description provided for @racesAiNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'IA non configurée sur le serveur.'**
  String get racesAiNotConfigured;

  /// No description provided for @racesRecommendEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recommandation'**
  String get racesRecommendEmptyTitle;

  /// No description provided for @racesRecommendEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Remplissez le formulaire puis lancez la recommandation.'**
  String get racesRecommendEmptySubtitle;

  /// No description provided for @racesRecommendNoResultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune recommandation'**
  String get racesRecommendNoResultTitle;

  /// No description provided for @racesRecommendNoResultSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Réessayez avec un autre objectif ou d\'autres ressources.'**
  String get racesRecommendNoResultSubtitle;

  /// No description provided for @racesRecommendResultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Top recommandations'**
  String get racesRecommendResultTitle;

  /// No description provided for @racesRecommendReasonsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi'**
  String get racesRecommendReasonsLabel;

  /// No description provided for @racesRecommendWarningsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Points d\'attention'**
  String get racesRecommendWarningsLabel;

  /// No description provided for @racesGoalMeat.
  ///
  /// In fr, this message translates to:
  /// **'Viande'**
  String get racesGoalMeat;

  /// No description provided for @racesGoalBreeding.
  ///
  /// In fr, this message translates to:
  /// **'Reproduction'**
  String get racesGoalBreeding;

  /// No description provided for @racesGoalHeatResilience.
  ///
  /// In fr, this message translates to:
  /// **'Climat chaud'**
  String get racesGoalHeatResilience;

  /// No description provided for @raceDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche race'**
  String get raceDetailTitle;

  /// No description provided for @raceNotFoundTitle.
  ///
  /// In fr, this message translates to:
  /// **'Race introuvable'**
  String get raceNotFoundTitle;

  /// No description provided for @raceNotFoundSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger cette race.'**
  String get raceNotFoundSubtitle;

  /// No description provided for @raceSectionPerformance.
  ///
  /// In fr, this message translates to:
  /// **'Performance'**
  String get raceSectionPerformance;

  /// No description provided for @raceSectionReproduction.
  ///
  /// In fr, this message translates to:
  /// **'Reproduction'**
  String get raceSectionReproduction;

  /// No description provided for @raceSectionClimate.
  ///
  /// In fr, this message translates to:
  /// **'Climat'**
  String get raceSectionClimate;

  /// No description provided for @raceSectionHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get raceSectionHealth;

  /// No description provided for @raceAdultWeightLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poids adulte'**
  String get raceAdultWeightLabel;

  /// No description provided for @raceGmqLabel.
  ///
  /// In fr, this message translates to:
  /// **'GMQ cible'**
  String get raceGmqLabel;

  /// No description provided for @raceGmqValue.
  ///
  /// In fr, this message translates to:
  /// **'{gmq} g/j'**
  String raceGmqValue(int gmq);

  /// No description provided for @raceLitterSizeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Taille portée moyenne'**
  String get raceLitterSizeLabel;

  /// No description provided for @raceLitterSizeValue.
  ///
  /// In fr, this message translates to:
  /// **'{value}'**
  String raceLitterSizeValue(double value);

  /// No description provided for @raceFirstBirthAgeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Âge 1ère mise bas'**
  String get raceFirstBirthAgeLabel;

  /// No description provided for @raceFirstBirthAgeValue.
  ///
  /// In fr, this message translates to:
  /// **'{days} jours'**
  String raceFirstBirthAgeValue(int days);

  /// No description provided for @raceHeatAdaptationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adaptation chaleur'**
  String get raceHeatAdaptationLabel;

  /// No description provided for @raceHeatAdaptationValue.
  ///
  /// In fr, this message translates to:
  /// **'{score}/5'**
  String raceHeatAdaptationValue(int score);

  /// No description provided for @raceNoSensitivities.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sensibilité renseignée.'**
  String get raceNoSensitivities;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @motherLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mère'**
  String get motherLabel;

  /// No description provided for @fatherLabel.
  ///
  /// In fr, this message translates to:
  /// **'Père'**
  String get fatherLabel;

  /// No description provided for @motherFallback.
  ///
  /// In fr, this message translates to:
  /// **'Mère'**
  String get motherFallback;

  /// No description provided for @fatherFallback.
  ///
  /// In fr, this message translates to:
  /// **'Père'**
  String get fatherFallback;

  /// No description provided for @statusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get statusLabel;

  /// No description provided for @saillieDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de saillie'**
  String get saillieDateLabel;

  /// No description provided for @expectedBirthDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mise bas prévue'**
  String get expectedBirthDateLabel;

  /// No description provided for @porteeDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détails portée'**
  String get porteeDetailTitle;

  /// No description provided for @porteeInfoSection.
  ///
  /// In fr, this message translates to:
  /// **'Infos'**
  String get porteeInfoSection;

  /// No description provided for @recordMiseBasCta.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer mise bas'**
  String get recordMiseBasCta;

  /// No description provided for @lapereauxCta.
  ///
  /// In fr, this message translates to:
  /// **'Lapereaux'**
  String get lapereauxCta;

  /// No description provided for @recordSevrageCta.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer sevrage'**
  String get recordSevrageCta;

  /// No description provided for @sevrageDestinationDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Destination par défaut au sevrage'**
  String get sevrageDestinationDialogTitle;

  /// No description provided for @lapereauDestinationConserve.
  ///
  /// In fr, this message translates to:
  /// **'Conservé'**
  String get lapereauDestinationConserve;

  /// No description provided for @lapereauDestinationVendu.
  ///
  /// In fr, this message translates to:
  /// **'Vendu'**
  String get lapereauDestinationVendu;

  /// No description provided for @lapereauDestinationConsomme.
  ///
  /// In fr, this message translates to:
  /// **'Consommé'**
  String get lapereauDestinationConsomme;

  /// No description provided for @selectFemaleAndMaleError.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une femelle et un mâle'**
  String get selectFemaleAndMaleError;

  /// No description provided for @femaleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Femelle'**
  String get femaleLabel;

  /// No description provided for @maleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mâle'**
  String get maleLabel;

  /// No description provided for @consanguinityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Consanguinité'**
  String get consanguinityTitle;

  /// No description provided for @consanguinityOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get consanguinityOk;

  /// No description provided for @consanguinityWarn.
  ///
  /// In fr, this message translates to:
  /// **'Avertissement'**
  String get consanguinityWarn;

  /// No description provided for @consanguinityBlock.
  ///
  /// In fr, this message translates to:
  /// **'Bloquée'**
  String get consanguinityBlock;

  /// No description provided for @consanguinityUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Non vérifiable'**
  String get consanguinityUnknown;

  /// No description provided for @consanguinityOffline.
  ///
  /// In fr, this message translates to:
  /// **'Vérification indisponible hors-ligne'**
  String get consanguinityOffline;

  /// No description provided for @consanguinityBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Saillie bloquée (consanguinité trop élevée).'**
  String get consanguinityBlocked;

  /// No description provided for @miseBasTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer mise bas'**
  String get miseBasTitle;

  /// No description provided for @miseBasDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de mise bas'**
  String get miseBasDateLabel;

  /// No description provided for @invalidNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide'**
  String get invalidNumber;

  /// No description provided for @nbVivantsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Vivants'**
  String get nbVivantsLabel;

  /// No description provided for @nbMortsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Morts'**
  String get nbMortsLabel;

  /// No description provided for @poidsTotalPorteeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poids total (g)'**
  String get poidsTotalPorteeLabel;

  /// No description provided for @lapereauxTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lapereaux'**
  String get lapereauxTitle;

  /// No description provided for @lapereauxEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lapereau'**
  String get lapereauxEmpty;

  /// No description provided for @lapereauxEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les lapereaux apparaîtront après l\'enregistrement de la mise bas.'**
  String get lapereauxEmptySubtitle;

  /// No description provided for @lapereauLabel.
  ///
  /// In fr, this message translates to:
  /// **'Lapereau'**
  String get lapereauLabel;

  /// No description provided for @lapereauEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier lapereau'**
  String get lapereauEditTitle;

  /// No description provided for @lapereauSexeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sexe'**
  String get lapereauSexeLabel;

  /// No description provided for @lapereauStatutLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get lapereauStatutLabel;

  /// No description provided for @lapereauPoidsNaissanceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poids naissance (g)'**
  String get lapereauPoidsNaissanceLabel;

  /// No description provided for @preMiseBasChecklistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Checklist pré-mise bas (J25)'**
  String get preMiseBasChecklistTitle;

  /// No description provided for @checklistCageMaternite.
  ///
  /// In fr, this message translates to:
  /// **'Cage maternité'**
  String get checklistCageMaternite;

  /// No description provided for @checklistNid.
  ///
  /// In fr, this message translates to:
  /// **'Nid'**
  String get checklistNid;

  /// No description provided for @checklistTemperature.
  ///
  /// In fr, this message translates to:
  /// **'Température'**
  String get checklistTemperature;

  /// No description provided for @checklistAliments.
  ///
  /// In fr, this message translates to:
  /// **'Aliments'**
  String get checklistAliments;

  /// No description provided for @checklistIsolement.
  ///
  /// In fr, this message translates to:
  /// **'Isolement'**
  String get checklistIsolement;

  /// No description provided for @gestationTimelineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Timeline gestation'**
  String get gestationTimelineTitle;

  /// No description provided for @gestationDayProgress.
  ///
  /// In fr, this message translates to:
  /// **'Jour {day} / 31'**
  String gestationDayProgress(int day);

  /// No description provided for @gestationMilestoneJ7.
  ///
  /// In fr, this message translates to:
  /// **'Implantation'**
  String get gestationMilestoneJ7;

  /// No description provided for @gestationMilestoneJ25.
  ///
  /// In fr, this message translates to:
  /// **'Préparer le nid'**
  String get gestationMilestoneJ25;

  /// No description provided for @gestationMilestoneJ28.
  ///
  /// In fr, this message translates to:
  /// **'Alerte'**
  String get gestationMilestoneJ28;

  /// No description provided for @gestationMilestoneJ31.
  ///
  /// In fr, this message translates to:
  /// **'Mise bas'**
  String get gestationMilestoneJ31;

  /// No description provided for @porteeSaillieDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Saillie : {date}'**
  String porteeSaillieDateLabel(String date);

  /// No description provided for @porteeGestationProgressLabel.
  ///
  /// In fr, this message translates to:
  /// **'J{elapsed} — {remaining} jours restants'**
  String porteeGestationProgressLabel(int elapsed, int remaining);

  /// No description provided for @porteesHelpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Guide de test (Portées)'**
  String get porteesHelpTitle;

  /// No description provided for @porteesHelpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez ces étapes pour tester rapidement les nouvelles fonctionnalités.'**
  String get porteesHelpSubtitle;

  /// No description provided for @porteesHelpStep1.
  ///
  /// In fr, this message translates to:
  /// **'Créez une saillie (bouton +) : choisissez une femelle au repos et un mâle.'**
  String get porteesHelpStep1;

  /// No description provided for @porteesHelpStep2.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez la portée : vérifiez la timeline et la progression de gestation.'**
  String get porteesHelpStep2;

  /// No description provided for @porteesHelpStep3.
  ///
  /// In fr, this message translates to:
  /// **'À partir de J25 : cochez la checklist pré‑mise bas (elle est sauvegardée en local).'**
  String get porteesHelpStep3;

  /// No description provided for @porteesHelpStep4.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez la mise bas : cela crée automatiquement les lapereaux.'**
  String get porteesHelpStep4;

  /// No description provided for @porteesHelpStep5.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez “Lapereaux” : modifiez sexe/statut/poids, puis enregistrez le sevrage.'**
  String get porteesHelpStep5;

  /// No description provided for @porteesHelpCtaNewSaillie.
  ///
  /// In fr, this message translates to:
  /// **'Créer une saillie'**
  String get porteesHelpCtaNewSaillie;

  /// No description provided for @porteeNextStepTitle.
  ///
  /// In fr, this message translates to:
  /// **'Étape suivante'**
  String get porteeNextStepTitle;

  /// No description provided for @porteeNextStepGestation.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes en gestation : suivez la timeline, et enregistrez la mise bas quand elle a lieu.'**
  String get porteeNextStepGestation;

  /// No description provided for @porteeNextStepMiseBas.
  ///
  /// In fr, this message translates to:
  /// **'Mise bas en cours : enregistrez la mise bas puis gérez les lapereaux.'**
  String get porteeNextStepMiseBas;

  /// No description provided for @porteeNextStepLactation.
  ///
  /// In fr, this message translates to:
  /// **'Lactation : gérez les lapereaux, puis enregistrez le sevrage quand c’est prêt.'**
  String get porteeNextStepLactation;

  /// No description provided for @porteeNextStepSevrage.
  ///
  /// In fr, this message translates to:
  /// **'Sevrage : vérifiez la destination des lapereaux et ajustez si besoin.'**
  String get porteeNextStepSevrage;

  /// No description provided for @porteeNextStepTerminee.
  ///
  /// In fr, this message translates to:
  /// **'Portée terminée : consultez l’historique des lapereaux.'**
  String get porteeNextStepTerminee;
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
