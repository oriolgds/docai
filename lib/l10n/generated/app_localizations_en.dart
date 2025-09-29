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

  @override
  String get yourPersonalAIDoctor => 'Your Personal AI Doctor';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get signInWithEmail => 'Sign in with Email';

  @override
  String get or => 'or';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get emailVerificationRequired => 'Email Verification Required';

  @override
  String get emailVerificationMessage =>
      'Your email address needs to be verified before you can sign in.';

  @override
  String get verifyEmailButton => 'Verify Email';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordMessage =>
      'Enter your email address to receive a password reset link.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get passwordResetSent => 'Password reset link sent! Check your email.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinDocAI => 'Join DocAI today';

  @override
  String get enterEmailAddress => 'Enter your email address';

  @override
  String get createStrongPassword => 'Create a strong password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get passwordRequirements => 'Password requirements:';

  @override
  String get atLeast8Characters => 'At least 8 characters';

  @override
  String get containsUppercase => 'Contains uppercase letter';

  @override
  String get containsLowercase => 'Contains lowercase letter';

  @override
  String get containsNumber => 'Contains number';

  @override
  String get pleaseEnterEmailAddress => 'Please enter your email address';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters long';

  @override
  String get passwordNeedsUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get passwordNeedsLowercase =>
      'Password must contain at least one lowercase letter';

  @override
  String get passwordNeedsNumber => 'Password must contain at least one number';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get accountCreatedSuccess =>
      'Account created successfully! Please check your email for verification.';

  @override
  String get accountAlreadyExists =>
      'An account with this email already exists. Please try signing in instead.';

  @override
  String get signingUp => 'Signing up...';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signIn => 'Sign in';

  @override
  String get helloImDocai => 'Hello, I\'m Docai. How can I help you today?';

  @override
  String get newConversation => 'New conversation';

  @override
  String get viewHistory => 'View history';

  @override
  String get medicalNotice => 'Medical notice';

  @override
  String get understood => 'Understood';

  @override
  String get newConversationConfirm =>
      'Are you sure you want to start a new conversation?';

  @override
  String get deleteHistory => 'Delete history';

  @override
  String get deleteHistoryConfirm =>
      'Are you sure you want to delete all chat history? This action cannot be undone and will remove all conversations both locally and in the cloud.';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get deletingHistory => 'Deleting history...';

  @override
  String get historyDeletedSuccess => 'History deleted successfully';

  @override
  String errorDeletingHistory(String error) {
    return 'Error deleting history: $error';
  }

  @override
  String get personalizeYourExperience => 'Personalize your experience';

  @override
  String get personalizeExperienceMessage =>
      'For more accurate and personalized recommendations, configure your medical preferences, allergies and conditions.';

  @override
  String get notNow => 'Not now';

  @override
  String get personalize => 'Personalize';

  @override
  String get configureRegeneration => 'Configure regeneration';

  @override
  String get advancedReasoning => 'Advanced reasoning';

  @override
  String get advancedReasoningDescription =>
      'Docai will provide a more detailed step-by-step analysis.';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get syncError => 'Sync error. Tap refresh to try again.';

  @override
  String get conversationsLocalOnly =>
      'Conversations saved only on this device';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncedLessThanMinute => 'Synced less than a minute ago';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Synced ${minutes}m ago';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Synced ${hours}h ago';
  }

  @override
  String syncedDaysAgo(int days) {
    return 'Synced ${days}d ago';
  }

  @override
  String get autoSyncEnabled => 'Automatic sync enabled';

  @override
  String get cloudSyncEnabled => 'Cloud sync enabled';

  @override
  String get cloudSyncDisabled => 'Cloud sync disabled';

  @override
  String get syncCompleted => 'Sync completed';

  @override
  String syncErrorMessage(String error) {
    return 'Sync error: $error';
  }

  @override
  String get history => 'History';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get chat => 'Chat';
}
