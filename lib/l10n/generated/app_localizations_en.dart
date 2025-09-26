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
  String get profile => 'Profile';

  @override
  String get personalization => 'Personalization';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get noEmail => 'No email';

  @override
  String get user => 'User';

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get active => 'Active';

  @override
  String get unlimitedConsultations => 'Unlimited AI consultations';

  @override
  String get expiresOn => 'Expires: March 15, 2025';

  @override
  String get medicalPreferencesUpdated => 'Medical preferences updated';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get personalizeExperience => 'Personalize your experience';

  @override
  String get personalizeDescription =>
      'Help us offer you more accurate and personalized recommendations.';

  @override
  String get basicInformation => 'Basic information';

  @override
  String get ageRange => 'Age range';

  @override
  String get gender => 'Gender';

  @override
  String get medicalPreferences => 'Medical preferences';

  @override
  String get preferredMedicineType => 'Preferred medicine type';

  @override
  String get medicalInformation => 'Medical information';

  @override
  String get allergies => 'Allergies';

  @override
  String get allergiesHint => 'E.g: penicillin, nuts, pollen (comma separated)';

  @override
  String get chronicConditions => 'Chronic conditions';

  @override
  String get chronicConditionsHint =>
      'E.g: diabetes, hypertension, asthma (comma separated)';

  @override
  String get currentMedications => 'Current medications';

  @override
  String get currentMedicationsHint =>
      'E.g: aspirin, omeprazole (comma separated)';

  @override
  String get additionalNotes => 'Additional notes';

  @override
  String get additionalInformation => 'Additional information';

  @override
  String get additionalInformationHint =>
      'Any other relevant information for your medical care...';

  @override
  String get disclaimerText =>
      'This information helps us personalize responses, but does not replace professional medical consultation.';

  @override
  String get preferencesSavedSuccess => 'Preferences saved successfully';

  @override
  String errorLoadingPreferences(String error) {
    return 'Error loading preferences: $error';
  }

  @override
  String errorSavingPreferences(String error) {
    return 'Error saving: $error';
  }

  @override
  String get userNotFound => 'User not found';
}
