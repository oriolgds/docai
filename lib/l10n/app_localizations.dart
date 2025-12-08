import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DocAI'**
  String get appTitle;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get menuHistory;

  /// No description provided for @medicalSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Medical Specialty'**
  String get medicalSpecialty;

  /// No description provided for @menuReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get menuReload;

  /// No description provided for @menuMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get menuMoreInfo;

  /// No description provided for @menuTwitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get menuTwitter;

  /// No description provided for @menuPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get menuPortfolio;

  /// No description provided for @menuProjectSite.
  ///
  /// In en, this message translates to:
  /// **'Project website'**
  String get menuProjectSite;

  /// No description provided for @menuPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Play Store'**
  String get menuPlayStore;

  /// No description provided for @menuUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get menuUpdateAvailable;

  /// No description provided for @newWindowTitle.
  ///
  /// In en, this message translates to:
  /// **'New window'**
  String get newWindowTitle;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineTitle;

  /// No description provided for @offlineDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get offlineDescription;

  /// No description provided for @offlineRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get offlineRetry;

  /// No description provided for @linkOpenError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open link'**
  String get linkOpenError;

  /// No description provided for @infoTwitterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow DocAI news and updates on X.'**
  String get infoTwitterSubtitle;

  /// No description provided for @infoPortfolioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover @oriolgds work and projects.'**
  String get infoPortfolioSubtitle;

  /// No description provided for @infoProjectSiteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn more about DocAI on the official site.'**
  String get infoProjectSiteSubtitle;

  /// No description provided for @infoPlayStoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download DocAI on Google Play.'**
  String get infoPlayStoreSubtitle;

  /// No description provided for @languageSelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSelectorLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageCatalan.
  ///
  /// In en, this message translates to:
  /// **'Catalan'**
  String get languageCatalan;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @menuSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions form'**
  String get menuSuggestions;

  /// No description provided for @infoSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your ideas to improve DocAI.'**
  String get infoSuggestionsSubtitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m Doky, your medical assistant.'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How can I help you today?'**
  String get welcomeSubtitle;

  /// No description provided for @inputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type your medical query...'**
  String get inputPlaceholder;

  /// No description provided for @incognitoMode.
  ///
  /// In en, this message translates to:
  /// **'Incognito'**
  String get incognitoMode;

  /// No description provided for @incognitoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Incognito mode - won\'t save to history'**
  String get incognitoTooltip;

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select a model'**
  String get selectModel;

  /// No description provided for @selectPreset.
  ///
  /// In en, this message translates to:
  /// **'Select a specialty'**
  String get selectPreset;

  /// No description provided for @presetGeneralName.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get presetGeneralName;

  /// No description provided for @presetGeneralDesc.
  ///
  /// In en, this message translates to:
  /// **'General medical inquiries'**
  String get presetGeneralDesc;

  /// No description provided for @presetDiagnosisName.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get presetDiagnosisName;

  /// No description provided for @presetDiagnosisDesc.
  ///
  /// In en, this message translates to:
  /// **'Analysis of possible diagnoses'**
  String get presetDiagnosisDesc;

  /// No description provided for @presetSymptomsName.
  ///
  /// In en, this message translates to:
  /// **'Symptom Analysis'**
  String get presetSymptomsName;

  /// No description provided for @presetSymptomsDesc.
  ///
  /// In en, this message translates to:
  /// **'Detailed evaluation'**
  String get presetSymptomsDesc;

  /// No description provided for @presetMedicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get presetMedicationName;

  /// No description provided for @presetMedicationDesc.
  ///
  /// In en, this message translates to:
  /// **'Pharmacological information'**
  String get presetMedicationDesc;

  /// No description provided for @presetNutritionName.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get presetNutritionName;

  /// No description provided for @presetNutritionDesc.
  ///
  /// In en, this message translates to:
  /// **'Dietary advice'**
  String get presetNutritionDesc;

  /// No description provided for @presetExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get presetExerciseName;

  /// No description provided for @presetExerciseDesc.
  ///
  /// In en, this message translates to:
  /// **'Fitness and physical health'**
  String get presetExerciseDesc;

  /// No description provided for @suggestionGeneral1.
  ///
  /// In en, this message translates to:
  /// **'What are the symptoms of the flu?'**
  String get suggestionGeneral1;

  /// No description provided for @suggestionGeneral2.
  ///
  /// In en, this message translates to:
  /// **'How can I improve my health?'**
  String get suggestionGeneral2;

  /// No description provided for @suggestionGeneral3.
  ///
  /// In en, this message translates to:
  /// **'Tell me about vaccines'**
  String get suggestionGeneral3;

  /// No description provided for @suggestionDiagnosis1.
  ///
  /// In en, this message translates to:
  /// **'What do these symptoms mean?'**
  String get suggestionDiagnosis1;

  /// No description provided for @suggestionDiagnosis2.
  ///
  /// In en, this message translates to:
  /// **'Interpret my results'**
  String get suggestionDiagnosis2;

  /// No description provided for @suggestionDiagnosis3.
  ///
  /// In en, this message translates to:
  /// **'When should I see a doctor?'**
  String get suggestionDiagnosis3;

  /// No description provided for @suggestionSymptoms1.
  ///
  /// In en, this message translates to:
  /// **'I have a constant headache'**
  String get suggestionSymptoms1;

  /// No description provided for @suggestionSymptoms2.
  ///
  /// In en, this message translates to:
  /// **'I have fever and cough'**
  String get suggestionSymptoms2;

  /// No description provided for @suggestionSymptoms3.
  ///
  /// In en, this message translates to:
  /// **'I feel unexplained fatigue'**
  String get suggestionSymptoms3;

  /// No description provided for @suggestionMedication1.
  ///
  /// In en, this message translates to:
  /// **'What is Ibuprofen for?'**
  String get suggestionMedication1;

  /// No description provided for @suggestionMedication2.
  ///
  /// In en, this message translates to:
  /// **'Side effects of antibiotics'**
  String get suggestionMedication2;

  /// No description provided for @suggestionMedication3.
  ///
  /// In en, this message translates to:
  /// **'How to take this medicine?'**
  String get suggestionMedication3;

  /// No description provided for @suggestionNutrition1.
  ///
  /// In en, this message translates to:
  /// **'Healthy diet plan'**
  String get suggestionNutrition1;

  /// No description provided for @suggestionNutrition2.
  ///
  /// In en, this message translates to:
  /// **'Foods rich in iron'**
  String get suggestionNutrition2;

  /// No description provided for @suggestionNutrition3.
  ///
  /// In en, this message translates to:
  /// **'Tips for losing weight'**
  String get suggestionNutrition3;

  /// No description provided for @suggestionExercise1.
  ///
  /// In en, this message translates to:
  /// **'Routine for beginners'**
  String get suggestionExercise1;

  /// No description provided for @suggestionExercise2.
  ///
  /// In en, this message translates to:
  /// **'Exercises for back pain'**
  String get suggestionExercise2;

  /// No description provided for @suggestionExercise3.
  ///
  /// In en, this message translates to:
  /// **'Improve cardiovascular endurance'**
  String get suggestionExercise3;

  /// No description provided for @dialogNewChatTitle.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get dialogNewChatTitle;

  /// No description provided for @dialogChangeSpecialtyTitle.
  ///
  /// In en, this message translates to:
  /// **'Change specialty'**
  String get dialogChangeSpecialtyTitle;

  /// No description provided for @dialogNewChatContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to start a new chat? Current history will be cleared.'**
  String get dialogNewChatContent;

  /// No description provided for @dialogChangeSpecialtyContent.
  ///
  /// In en, this message translates to:
  /// **'Changing specialty requires clearing current history. Do you want to continue?'**
  String get dialogChangeSpecialtyContent;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogConfirmNewChat.
  ///
  /// In en, this message translates to:
  /// **'Yes, new chat'**
  String get dialogConfirmNewChat;

  /// No description provided for @dialogConfirmChange.
  ///
  /// In en, this message translates to:
  /// **'Yes, change'**
  String get dialogConfirmChange;

  /// No description provided for @chatNewConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get chatNewConversation;

  /// No description provided for @chatUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get chatUntitled;

  /// No description provided for @chatYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatYou;

  /// No description provided for @chatDoky.
  ///
  /// In en, this message translates to:
  /// **'Doky'**
  String get chatDoky;

  /// No description provided for @chatNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No saved chats'**
  String get chatNoHistory;

  /// No description provided for @chatHistoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your conversations will appear here'**
  String get chatHistoryPlaceholder;

  /// No description provided for @deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all chats?'**
  String get deleteDialogTitle;

  /// No description provided for @deleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your chat history will be permanently deleted.'**
  String get deleteDialogContent;

  /// No description provided for @deleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteDialogCancel;

  /// No description provided for @deleteDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteDialogConfirm;

  /// No description provided for @deleteDialogConfirmed.
  ///
  /// In en, this message translates to:
  /// **'All chats deleted'**
  String get deleteDialogConfirmed;

  /// No description provided for @reportContent.
  ///
  /// In en, this message translates to:
  /// **'Report content'**
  String get reportContent;

  /// No description provided for @copyContent.
  ///
  /// In en, this message translates to:
  /// **'Copy content'**
  String get copyContent;

  /// No description provided for @reportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Report content'**
  String get reportDialogTitle;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect information'**
  String get reportReasonIncorrect;

  /// No description provided for @reportReasonHarmful.
  ///
  /// In en, this message translates to:
  /// **'Harmful or dangerous'**
  String get reportReasonHarmful;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @reportButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportButtonLabel;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get reportSuccess;

  /// No description provided for @reportError.
  ///
  /// In en, this message translates to:
  /// **'Error submitting report'**
  String get reportError;

  /// No description provided for @contentCopied.
  ///
  /// In en, this message translates to:
  /// **'Content copied to clipboard'**
  String get contentCopied;

  /// No description provided for @menuMyReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get menuMyReports;

  /// No description provided for @reportStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reportStatusPending;

  /// No description provided for @reportStatusSolved.
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get reportStatusSolved;

  /// No description provided for @reportStatusRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get reportStatusRefused;

  /// No description provided for @reportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Received'**
  String get reportSuccessTitle;

  /// No description provided for @reportSuccessContent.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your report. We will review it shortly. You can track its status in \'My Reports\'.'**
  String get reportSuccessContent;

  /// No description provided for @reportViewReports.
  ///
  /// In en, this message translates to:
  /// **'View My Reports'**
  String get reportViewReports;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get reportsTitle;

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// No description provided for @errorLoadingReports.
  ///
  /// In en, this message translates to:
  /// **'Error loading reports'**
  String get errorLoadingReports;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ca', 'de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca': return AppLocalizationsCa();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
