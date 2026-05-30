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
  String get plusQrScan => 'Scan QR';

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
  String get loading => 'Loading…';

  @override
  String get rentabilityTitle => 'Profitability score';

  @override
  String rentabilityScoreValue(int score) {
    return '$score/100';
  }

  @override
  String get timelineTitle => 'Timeline (7 days)';

  @override
  String get timelineAdd => 'Add';

  @override
  String get timelineEmptyTitle => 'Nothing upcoming';

  @override
  String get timelineEmptySubtitle => 'Add a planned weight or vaccine.';

  @override
  String timelineBirthTitle(String mother) {
    return 'Expected birth — $mother';
  }

  @override
  String get timelineBirthSubtitle => 'Prepare the nest early.';

  @override
  String get timelineWeightTitle => 'Weigh-in due';

  @override
  String get timelineWeightSubtitle => 'Planned weigh-in';

  @override
  String get timelineVaccineTitle => 'Vaccine due';

  @override
  String get timelineVaccineSubtitle => 'Planned vaccine';

  @override
  String get timelineAddTitle => 'Add an event';

  @override
  String get timelineAddWeight => 'Weight';

  @override
  String get timelineAddVaccine => 'Vaccine';

  @override
  String get timelineAddLapin => 'Rabbit';

  @override
  String get timelineAddDate => 'Date';

  @override
  String get timelineAddNote => 'Note (optional)';

  @override
  String get timelineAddSave => 'Save';

  @override
  String get timelineAddSaved => 'Event added';

  @override
  String get quickWeightTitle => 'Quick weigh-in';

  @override
  String get quickWeightLapin => 'Rabbit';

  @override
  String get quickWeightValueLabel => 'Weight';

  @override
  String get quickWeightUnit => 'g';

  @override
  String get quickWeightInvalid => 'Please enter a valid weight';

  @override
  String get quickWeightSave => 'Save';

  @override
  String get quickWeightSaved => 'Weight saved';

  @override
  String get quickWeightOffline => 'Quick weigh-in is unavailable offline';

  @override
  String get quickWeightNoLapins => 'Add a rabbit to record a weight';

  @override
  String get kpiLapins => 'Rabbits';

  @override
  String get kpiGestantes => 'Pregnant';

  @override
  String get kpiAttendus => 'Expected';

  @override
  String get kpiNextBirth => 'Next birth';

  @override
  String get kpiNextBirthNone => '—';

  @override
  String kpiNextBirthValue(String date, int days) {
    return '$date (D-$days)';
  }

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
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonAll => 'All';

  @override
  String get commonSelectDate => 'Select a date';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonUpdate => 'Update';

  @override
  String get photoCamera => 'Camera';

  @override
  String get photoGallery => 'Gallery';

  @override
  String get photoChangeRequiresOnline =>
      'Internet connection required to change the photo';

  @override
  String get photoUploadRequiresOnline =>
      'Internet connection required to upload the photo';

  @override
  String get photoTooLarge => 'Image too large (max 200 KB).';

  @override
  String get lapinsTitle => 'My rabbits';

  @override
  String get lapinTitle => 'Rabbit';

  @override
  String get lapinAddWeightTitle => 'Add a weight';

  @override
  String get lapinWeightGramLabel => 'Weight (g)';

  @override
  String get lapinsFilterTitle => 'Filter';

  @override
  String get lapinsFilterStatut => 'Status';

  @override
  String get lapinsFilterRace => 'Breed';

  @override
  String get lapinsFilterSexe => 'Sex';

  @override
  String get lapinsFilterReset => 'Reset';

  @override
  String get lapinsFilterApply => 'Apply';

  @override
  String get lapinFormIdentityStep => 'Identity';

  @override
  String get lapinFormParamsStep => 'Settings';

  @override
  String get lapinFormGenealogyStep => 'Genealogy';

  @override
  String get lapinFieldNom => 'Name';

  @override
  String get lapinFieldDateNaissance => 'Birth date';

  @override
  String get lapinFieldPoidsActuel => 'Current weight (grams)';

  @override
  String get lapinFieldNumeroIdentification => 'Identification number';

  @override
  String get lapinFormFatherOptional => 'Father (optional)';

  @override
  String get lapinFormMotherOptional => 'Mother (optional)';

  @override
  String get lapinFormNoneMasculine => 'None';

  @override
  String get lapinFormNoneFeminine => 'None';

  @override
  String get lapinValidationNameRequired => 'Please enter a name';

  @override
  String get lapinTabGrowth => 'Growth';

  @override
  String get lapinTabHealth => 'Health';

  @override
  String get lapinTabRepro => 'Breeding';

  @override
  String get lapinTabInfo => 'Info';

  @override
  String get growthNoWeights => 'No weight recorded yet.';

  @override
  String get growthLowGmqBadge => 'Low ADG';

  @override
  String get growthPredictButton => 'Predict';

  @override
  String get growthPredictTitle => 'Growth prediction';

  @override
  String get growthPredictNeededGmq => 'Required ADG';

  @override
  String get growthPredictRaceGmq => 'Breed ADG';

  @override
  String get growthPredictWeek10 => 'At 10 weeks';

  @override
  String get growthPredictWeek12 => 'At 12 weeks';

  @override
  String get growthPredictWeek14 => 'At 14 weeks';

  @override
  String get growthPredictSaleDate => 'Optimal sale date';

  @override
  String get growthPredictNoSaleDate => '—';

  @override
  String comingSoonLabel(String title) {
    return '$title: coming soon';
  }

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
  String get lapinOfflineNotFound => 'Rabbit not found offline';

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

  @override
  String get plusRaces => 'Breeds';

  @override
  String get qrLapinTitle => 'Rabbit QR code';

  @override
  String get qrShare => 'Share';

  @override
  String get qrPrint => 'Print';

  @override
  String get qrScanTitle => 'Scan a QR code';

  @override
  String get qrScanInvalid => 'Unrecognized QR code';

  @override
  String get racesTitle => 'Breeds';

  @override
  String get racesSearchHint => 'Search a breed...';

  @override
  String get racesEmptyTitle => 'No breeds';

  @override
  String get racesEmptySubtitle =>
      'Check that the \"races\" table contains data.';

  @override
  String get racesNoSummary => 'See details';

  @override
  String racesWeightRange(String min, String max) {
    return 'Adult weight: $min–$max kg';
  }

  @override
  String racesGmqTarget(String gmq) {
    return 'Target ADG: $gmq g/day';
  }

  @override
  String racesHeatScore(String score) {
    return 'Heat: $score/5';
  }

  @override
  String get racesCompareCta => 'Compare';

  @override
  String get racesCompareTitle => 'Breed comparison';

  @override
  String get racesCompareMetricColumn => 'Metric';

  @override
  String get racesComparePickTitle => 'Select 2–3 breeds';

  @override
  String get racesCompareNeedTwoTitle => 'Select at least 2 breeds';

  @override
  String get racesCompareNeedTwoSubtitle =>
      'Choose 2 or 3 breeds to display the comparison table.';

  @override
  String get racesComparePickMoreCta => 'Pick breeds';

  @override
  String get racesRecommendCta => 'Recommend';

  @override
  String get racesRecommendTitle => 'Breed recommendation';

  @override
  String get racesRecommendFormTitle => 'Your context';

  @override
  String get racesCountryLabel => 'Country';

  @override
  String get racesCityLabel => 'City';

  @override
  String get racesGoalLabel => 'Goal';

  @override
  String get racesResourcesLabel => 'Available resources';

  @override
  String get racesAiNotConfigured => 'AI is not configured on the server.';

  @override
  String get racesRecommendEmptyTitle => 'Recommendation';

  @override
  String get racesRecommendEmptySubtitle =>
      'Fill the form and start the recommendation.';

  @override
  String get racesRecommendNoResultTitle => 'No recommendation';

  @override
  String get racesRecommendNoResultSubtitle =>
      'Try again with another goal or resources.';

  @override
  String get racesRecommendResultTitle => 'Top recommendations';

  @override
  String get racesRecommendReasonsLabel => 'Why';

  @override
  String get racesRecommendWarningsLabel => 'Watch-outs';

  @override
  String get racesGoalMeat => 'Meat';

  @override
  String get racesGoalBreeding => 'Breeding';

  @override
  String get racesGoalHeatResilience => 'Hot climate';

  @override
  String get raceDetailTitle => 'Breed details';

  @override
  String get raceNotFoundTitle => 'Breed not found';

  @override
  String get raceNotFoundSubtitle => 'Could not load this breed.';

  @override
  String get raceSectionPerformance => 'Performance';

  @override
  String get raceSectionReproduction => 'Breeding';

  @override
  String get raceSectionClimate => 'Climate';

  @override
  String get raceSectionHealth => 'Health';

  @override
  String get raceAdultWeightLabel => 'Adult weight';

  @override
  String get raceGmqLabel => 'Target ADG';

  @override
  String raceGmqValue(int gmq) {
    return '$gmq g/day';
  }

  @override
  String get raceLitterSizeLabel => 'Avg litter size';

  @override
  String raceLitterSizeValue(double value) {
    return '$value';
  }

  @override
  String get raceFirstBirthAgeLabel => 'Age at first birth';

  @override
  String raceFirstBirthAgeValue(int days) {
    return '$days days';
  }

  @override
  String get raceHeatAdaptationLabel => 'Heat adaptation';

  @override
  String raceHeatAdaptationValue(int score) {
    return '$score/5';
  }

  @override
  String get raceNoSensitivities => 'No sensitivities provided.';

  @override
  String get confirm => 'Confirm';

  @override
  String get notes => 'Notes';

  @override
  String get motherLabel => 'Mother';

  @override
  String get fatherLabel => 'Father';

  @override
  String get motherFallback => 'Mother';

  @override
  String get fatherFallback => 'Father';

  @override
  String get statusLabel => 'Status';

  @override
  String get saillieDateLabel => 'Mating date';

  @override
  String get expectedBirthDateLabel => 'Expected birth';

  @override
  String get porteeDetailTitle => 'Litter details';

  @override
  String get porteeInfoSection => 'Info';

  @override
  String get recordMiseBasCta => 'Record birth';

  @override
  String get lapereauxCta => 'Kits';

  @override
  String get recordSevrageCta => 'Record weaning';

  @override
  String get sevrageDestinationDialogTitle => 'Default destination at weaning';

  @override
  String get lapereauDestinationConserve => 'Keep';

  @override
  String get lapereauDestinationVendu => 'Sold';

  @override
  String get lapereauDestinationConsomme => 'Consumed';

  @override
  String get selectFemaleAndMaleError => 'Select a female and a male';

  @override
  String get femaleLabel => 'Female';

  @override
  String get maleLabel => 'Male';

  @override
  String get consanguinityTitle => 'Inbreeding';

  @override
  String get consanguinityOk => 'OK';

  @override
  String get consanguinityWarn => 'Warning';

  @override
  String get consanguinityBlock => 'Blocked';

  @override
  String get consanguinityUnknown => 'Unknown';

  @override
  String get consanguinityOffline => 'Inbreeding check unavailable offline';

  @override
  String get consanguinityBlocked => 'Mating blocked (inbreeding too high).';

  @override
  String get miseBasTitle => 'Record birth';

  @override
  String get miseBasDateLabel => 'Birth date';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get nbVivantsLabel => 'Alive';

  @override
  String get nbMortsLabel => 'Dead';

  @override
  String get poidsTotalPorteeLabel => 'Total weight (g)';

  @override
  String get lapereauxTitle => 'Kits';

  @override
  String get lapereauxEmpty => 'No kits';

  @override
  String get lapereauxEmptySubtitle =>
      'Kits will appear after recording the birth.';

  @override
  String get lapereauLabel => 'Kit';

  @override
  String get lapereauEditTitle => 'Edit kit';

  @override
  String get lapereauSexeLabel => 'Sex';

  @override
  String get lapereauStatutLabel => 'Status';

  @override
  String get lapereauPoidsNaissanceLabel => 'Birth weight (g)';

  @override
  String get preMiseBasChecklistTitle => 'Pre-birth checklist (D25)';

  @override
  String get checklistCageMaternite => 'Maternity cage';

  @override
  String get checklistNid => 'Nest';

  @override
  String get checklistTemperature => 'Temperature';

  @override
  String get checklistAliments => 'Feed';

  @override
  String get checklistIsolement => 'Isolation';

  @override
  String get gestationTimelineTitle => 'Gestation timeline';

  @override
  String gestationDayProgress(int day) {
    return 'Day $day / 31';
  }

  @override
  String get gestationMilestoneJ7 => 'Implantation';

  @override
  String get gestationMilestoneJ25 => 'Prepare the nest';

  @override
  String get gestationMilestoneJ28 => 'Alert';

  @override
  String get gestationMilestoneJ31 => 'Birth';

  @override
  String porteeSaillieDateLabel(String date) {
    return 'Mating: $date';
  }

  @override
  String porteeGestationProgressLabel(int elapsed, int remaining) {
    return 'D$elapsed — $remaining days left';
  }

  @override
  String get porteesHelpTitle => 'Test guide (Litters)';

  @override
  String get porteesHelpSubtitle =>
      'Follow these steps to quickly test the new features.';

  @override
  String get porteesHelpStep1 =>
      'Create a mating (+ button): pick a resting female and a male.';

  @override
  String get porteesHelpStep2 =>
      'Open the litter: check the timeline and gestation progress.';

  @override
  String get porteesHelpStep3 =>
      'From day 25: tick the pre-birth checklist (saved locally).';

  @override
  String get porteesHelpStep4 =>
      'Record the birth: this automatically creates the kits.';

  @override
  String get porteesHelpStep5 =>
      'Open “Kits”: edit sex/status/weight, then record weaning.';

  @override
  String get porteesHelpCtaNewSaillie => 'Create mating';

  @override
  String get porteeNextStepTitle => 'Next step';

  @override
  String get porteeNextStepGestation =>
      'Gestation: follow the timeline and record the birth when it happens.';

  @override
  String get porteeNextStepMiseBas =>
      'Birth in progress: record the birth, then manage the kits.';

  @override
  String get porteeNextStepLactation =>
      'Lactation: manage the kits, then record weaning when ready.';

  @override
  String get porteeNextStepSevrage =>
      'Weaning: review kit destinations and adjust if needed.';

  @override
  String get porteeNextStepTerminee => 'Completed: review the kit history.';
}
