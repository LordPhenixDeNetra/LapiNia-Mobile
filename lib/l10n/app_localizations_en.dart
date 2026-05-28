// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'lapiNia';

  @override
  String get welcomeTagline => 'Your smart rabbit farming assistant';

  @override
  String get welcomeStart => 'Get started';

  @override
  String get welcomeAlreadyAccount => 'I already have an account';

  @override
  String get welcomeOfflineNotice =>
      'Offline mode is available to view already-synced data.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitleSignIn => 'Sign in with your email';

  @override
  String get loginSubtitleSignUp => 'Create your account';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get loginToggleToSignIn => 'I already have an account';

  @override
  String get loginToggleToSignUp => 'Create an account';

  @override
  String signUpCheckEmail(String email) {
    return 'Account created. Check your email: $email';
  }

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingRabbitsCountTitle => 'How many rabbits do you have?';

  @override
  String get onboardingRabbitsCountLt10 => 'Less than 10';

  @override
  String get onboardingRabbitsCount10to50 => '10 to 50';

  @override
  String get onboardingRabbitsCount50to200 => '50 to 200';

  @override
  String get onboardingRabbitsCountGt200 => 'More than 200';

  @override
  String get onboardingGoalsTitle => 'What is your main goal?';

  @override
  String get onboardingGoalSellKits => 'Sell kits';

  @override
  String get onboardingGoalMeat => 'Family meat';

  @override
  String get onboardingGoalBreeders => 'Breeders';

  @override
  String get onboardingGoalHobby => 'Hobby';

  @override
  String get onboardingRegionTitle => 'Your region?';

  @override
  String get onboardingCountryLabel => 'Country';

  @override
  String get onboardingCityLabel => 'City';

  @override
  String get onboardingCityHint => 'e.g. Dakar';

  @override
  String get onboardingRacesTitle => 'Which breeds do you have?';

  @override
  String get onboardingRacesSkip => 'You can fill this in later.';

  @override
  String get onboardingExperienceTitle => 'Your experience level?';

  @override
  String get onboardingExperienceBeginner => 'Beginner';

  @override
  String get onboardingExperienceIntermediate => 'Intermediate';

  @override
  String get onboardingExperienceExpert => 'Expert';

  @override
  String get onboardingAdviceTitle => 'Your first tip';

  @override
  String get onboardingAdviceSubtitle => 'Tip of the day';

  @override
  String get onboardingAdviceContinue => 'Continue';

  @override
  String get onboardingAdviceFallbackSell =>
      'Start by tracking pregnant does and keep a simple routine: fresh water, consistent feed, and a kidding calendar.';

  @override
  String get onboardingAdviceFallbackMeat =>
      'For steady meat production, track weight and secure feeding: stable ration, clean water, and daily observation.';

  @override
  String get onboardingAdviceFallbackBreeders =>
      'To improve your herd, keep genealogy up to date and avoid inbreeding: track parents, dates, and litter performance.';

  @override
  String get onboardingAdviceFallbackGeneric =>
      'Start simple: add your rabbits, record matings, then rely on alerts so you don’t miss anything.';

  @override
  String get errorGeneric => 'An error occurred.';

  @override
  String get errorUnknown => 'Unknown error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmTitle => 'Delete';

  @override
  String deleteConfirmBody(String name) {
    return 'Delete $name?';
  }

  @override
  String get goToLogin => 'Go to login';

  @override
  String get startupErrorTitle => 'Startup error';

  @override
  String get dashboardTitle => 'Home';

  @override
  String get navHome => 'Home';

  @override
  String get navLapins => 'Rabbits';

  @override
  String get navPortees => 'Litters';

  @override
  String get navIa => 'AI';

  @override
  String get navPlus => 'More';

  @override
  String get plusTitle => 'More';

  @override
  String get plusAlerts => 'Alerts';

  @override
  String get plusFeed => 'Feed';

  @override
  String get plusSettings => 'Settings';

  @override
  String get alertesTitle => 'Alerts';

  @override
  String get alertesFilterUnread => 'Unread';

  @override
  String get alertesFilterAll => 'All';

  @override
  String get alertesEmptyTitle => 'No alerts';

  @override
  String get alertesEmptySubtitle => 'Everything looks good for now.';

  @override
  String get alertesMarkRead => 'Mark as read';

  @override
  String get alertesActionDone => 'Done';

  @override
  String get dashboardAlerts => 'Alerts';

  @override
  String get dashboardSeeAll => 'See all';

  @override
  String get dashboardNoAlerts => 'No alerts';

  @override
  String get dashboardNextBirths => 'Upcoming births';

  @override
  String get dashboardSeeAllPortees => 'See all';

  @override
  String get dashboardNoGestation => 'No gestation litter';

  @override
  String get dashboardUnknownMother => 'Mother';

  @override
  String dashboardGestationProgress(int elapsed, int remaining) {
    return 'Day $elapsed — $remaining days left';
  }

  @override
  String get dashboardQuickActions => 'Quick actions';

  @override
  String get quickAddLapin => 'Add a rabbit';

  @override
  String get quickNewSaillie => 'New mating';

  @override
  String get quickRecordEvent => 'Record';

  @override
  String get quickSync => 'Sync';

  @override
  String quickSyncPending(int count) {
    return 'Sync ($count)';
  }

  @override
  String get quickEventWeight => 'Weight';

  @override
  String get quickEventHealth => 'Health';

  @override
  String get quickEventStock => 'Stock';

  @override
  String get dashboardAiTipTitle => 'Tip of the day';

  @override
  String get dashboardAiTipBody =>
      'The forecast temperature is high this week. Make sure your rabbits have plenty of fresh water and a shaded area.';

  @override
  String get dashboardAiTipWeather => '32°C forecast';

  @override
  String get kpiLapins => 'Rabbits';

  @override
  String get kpiGestantes => 'Pregnant';

  @override
  String get kpiAttendus => 'Expected';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsConnection => 'Connection';

  @override
  String get settingsSync => 'Sync';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsOnline => 'Online';

  @override
  String get settingsOffline => 'Offline';

  @override
  String get settingsOnlineHelp => 'Data can be synced.';

  @override
  String get settingsOfflineHelp => 'Actions will be queued.';

  @override
  String get settingsStatusUnknown => 'Unknown status';

  @override
  String settingsQueueTitle(int count) {
    return '$count pending action(s)';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncStarted => 'Sync started';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get lapinsTitle => 'My rabbits';

  @override
  String get lapinTitle => 'Rabbit';

  @override
  String get lapinAddWeightTitle => 'Add a weight';

  @override
  String get lapinWeightGramLabel => 'Weight (g)';

  @override
  String get lapinInfoSection => 'Info';

  @override
  String get lapinNotesSection => 'Notes';

  @override
  String get lapinFieldRace => 'Breed';

  @override
  String get lapinFieldSexe => 'Sex';

  @override
  String get lapinFieldStatut => 'Status';

  @override
  String get lapinFieldPoids => 'Weight';

  @override
  String get lapinFieldAge => 'Age';

  @override
  String get lapinFieldId => 'ID';

  @override
  String get lapinsSearchHint => 'Search a rabbit...';

  @override
  String get lapinsEmptyTitle => 'No rabbits yet';

  @override
  String get lapinsEmptySubtitle => 'Add your first rabbit to get started.';

  @override
  String get lapinsEmptyAction => 'Add a rabbit';

  @override
  String get porteesTitle => 'My litters';

  @override
  String get porteesEmpty => 'No litter';

  @override
  String get porteesEmptySubtitle =>
      'Create your first mating to track a litter.';

  @override
  String get porteesEmptyAction => 'New mating';

  @override
  String get newSaillie => 'New mating';

  @override
  String get save => 'Save';

  @override
  String get validationEmailRequired => 'Please enter your email';

  @override
  String get validationEmailInvalid => 'Invalid email';

  @override
  String get validationPasswordRequired => 'Please enter your password';

  @override
  String get validationPasswordTooShort => 'Password too short';
}
