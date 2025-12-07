// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DocAI';

  @override
  String get chatTitle => 'Chat';

  @override
  String get menuHome => 'Home';

  @override
  String get menuHistory => 'History';

  @override
  String get medicalSpecialty => 'Medical Specialty';

  @override
  String get menuReload => 'Reload';

  @override
  String get menuMoreInfo => 'More info';

  @override
  String get menuTwitter => 'Twitter';

  @override
  String get menuPortfolio => 'Portfolio';

  @override
  String get menuProjectSite => 'Project website';

  @override
  String get menuPlayStore => 'Play Store';

  @override
  String get menuUpdateAvailable => 'Update available';

  @override
  String get newWindowTitle => 'New window';

  @override
  String get loadingLabel => 'Loading...';

  @override
  String get offlineTitle => 'You\'re offline';

  @override
  String get offlineDescription => 'Check your connection and try again.';

  @override
  String get offlineRetry => 'Retry';

  @override
  String get linkOpenError => 'Couldn\'t open link';

  @override
  String get infoTwitterSubtitle => 'Follow DocAI news and updates on X.';

  @override
  String get infoPortfolioSubtitle => 'Discover @oriolgds work and projects.';

  @override
  String get infoProjectSiteSubtitle => 'Learn more about DocAI on the official site.';

  @override
  String get infoPlayStoreSubtitle => 'Download DocAI on Google Play.';

  @override
  String get languageSelectorLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageCatalan => 'Catalan';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageGerman => 'German';

  @override
  String get languageFrench => 'French';

  @override
  String get menuSuggestions => 'Suggestions form';

  @override
  String get infoSuggestionsSubtitle => 'Share your ideas to improve DocAI.';

  @override
  String get welcomeTitle => 'Hello! I\'m Doky, your medical assistant.';

  @override
  String get welcomeSubtitle => 'How can I help you today?';

  @override
  String get inputPlaceholder => 'Type your medical query...';

  @override
  String get incognitoMode => 'Incognito';

  @override
  String get incognitoTooltip => 'Incognito mode - won\'t save to history';

  @override
  String get selectModel => 'Select a model';

  @override
  String get selectPreset => 'Select a specialty';

  @override
  String get presetGeneralName => 'General';

  @override
  String get presetGeneralDesc => 'General medical inquiries';

  @override
  String get presetDiagnosisName => 'Diagnosis';

  @override
  String get presetDiagnosisDesc => 'Analysis of possible diagnoses';

  @override
  String get presetSymptomsName => 'Symptom Analysis';

  @override
  String get presetSymptomsDesc => 'Detailed evaluation';

  @override
  String get presetMedicationName => 'Medication';

  @override
  String get presetMedicationDesc => 'Pharmacological information';

  @override
  String get presetNutritionName => 'Nutrition';

  @override
  String get presetNutritionDesc => 'Dietary advice';

  @override
  String get presetExerciseName => 'Exercise';

  @override
  String get presetExerciseDesc => 'Fitness and physical health';

  @override
  String get suggestionGeneral1 => 'What are the symptoms of the flu?';

  @override
  String get suggestionGeneral2 => 'How can I improve my health?';

  @override
  String get suggestionGeneral3 => 'Tell me about vaccines';

  @override
  String get suggestionDiagnosis1 => 'What do these symptoms mean?';

  @override
  String get suggestionDiagnosis2 => 'Interpret my results';

  @override
  String get suggestionDiagnosis3 => 'When should I see a doctor?';

  @override
  String get suggestionSymptoms1 => 'I have a constant headache';

  @override
  String get suggestionSymptoms2 => 'I have fever and cough';

  @override
  String get suggestionSymptoms3 => 'I feel unexplained fatigue';

  @override
  String get suggestionMedication1 => 'What is Ibuprofen for?';

  @override
  String get suggestionMedication2 => 'Side effects of antibiotics';

  @override
  String get suggestionMedication3 => 'How to take this medicine?';

  @override
  String get suggestionNutrition1 => 'Healthy diet plan';

  @override
  String get suggestionNutrition2 => 'Foods rich in iron';

  @override
  String get suggestionNutrition3 => 'Tips for losing weight';

  @override
  String get suggestionExercise1 => 'Routine for beginners';

  @override
  String get suggestionExercise2 => 'Exercises for back pain';

  @override
  String get suggestionExercise3 => 'Improve cardiovascular endurance';

  @override
  String get dialogNewChatTitle => 'New chat';

  @override
  String get dialogChangeSpecialtyTitle => 'Change specialty';

  @override
  String get dialogNewChatContent => 'Do you want to start a new chat? Current history will be cleared.';

  @override
  String get dialogChangeSpecialtyContent => 'Changing specialty requires clearing current history. Do you want to continue?';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirmNewChat => 'Yes, new chat';

  @override
  String get dialogConfirmChange => 'Yes, change';

  @override
  String get chatNewConversation => 'New conversation';

  @override
  String get chatUntitled => 'Untitled';

  @override
  String get chatYou => 'You';

  @override
  String get chatDoky => 'Doky';

  @override
  String get chatNoHistory => 'No saved chats';

  @override
  String get chatHistoryPlaceholder => 'Your conversations will appear here';

  @override
  String get deleteDialogTitle => 'Delete all chats?';

  @override
  String get deleteDialogContent => 'This action cannot be undone. All your chat history will be permanently deleted.';

  @override
  String get deleteDialogCancel => 'Cancel';

  @override
  String get deleteDialogConfirm => 'Delete All';
}
