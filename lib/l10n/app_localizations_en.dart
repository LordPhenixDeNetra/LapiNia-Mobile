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
  String get errorGeneric => 'An error occurred.';

  @override
  String get errorUnknown => 'Unknown error';

  @override
  String get retry => 'Retry';

  @override
  String get goToLogin => 'Go to login';

  @override
  String get startupErrorTitle => 'Startup error';

  @override
  String get dashboardTitle => 'Home';

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
  String get lapinsSearchHint => 'Search a rabbit...';

  @override
  String get porteesTitle => 'My litters';

  @override
  String get porteesEmpty => 'No litter';

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
