import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('es'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'DocAI'**
  String get appTitle;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Personalization menu item and screen title
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// Edit profile menu item
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Privacy and security menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Placeholder when user has no email
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Default username placeholder
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Premium subscription plan title
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// Active subscription status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Premium plan benefit
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI consultations'**
  String get unlimitedConsultations;

  /// Subscription expiration date
  ///
  /// In en, this message translates to:
  /// **'Expires: March 15, 2025'**
  String get expiresOn;

  /// Success message when medical preferences are updated
  ///
  /// In en, this message translates to:
  /// **'Medical preferences updated'**
  String get medicalPreferencesUpdated;

  /// Logout confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// Logout confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Personalization screen header title
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience'**
  String get personalizeExperience;

  /// Personalization screen description
  ///
  /// In en, this message translates to:
  /// **'Help us offer you more accurate and personalized recommendations.'**
  String get personalizeDescription;

  /// Basic information section title
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get basicInformation;

  /// Age range field label
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get ageRange;

  /// Gender field label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Medical preferences section title
  ///
  /// In en, this message translates to:
  /// **'Medical preferences'**
  String get medicalPreferences;

  /// Medicine preference field label
  ///
  /// In en, this message translates to:
  /// **'Preferred medicine type'**
  String get preferredMedicineType;

  /// Medical information section title
  ///
  /// In en, this message translates to:
  /// **'Medical information'**
  String get medicalInformation;

  /// Allergies field label
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// Allergies field hint text
  ///
  /// In en, this message translates to:
  /// **'E.g: penicillin, nuts, pollen (comma separated)'**
  String get allergiesHint;

  /// Chronic conditions field label
  ///
  /// In en, this message translates to:
  /// **'Chronic conditions'**
  String get chronicConditions;

  /// Chronic conditions field hint text
  ///
  /// In en, this message translates to:
  /// **'E.g: diabetes, hypertension, asthma (comma separated)'**
  String get chronicConditionsHint;

  /// Current medications field label
  ///
  /// In en, this message translates to:
  /// **'Current medications'**
  String get currentMedications;

  /// Current medications field hint text
  ///
  /// In en, this message translates to:
  /// **'E.g: aspirin, omeprazole (comma separated)'**
  String get currentMedicationsHint;

  /// Additional notes section title
  ///
  /// In en, this message translates to:
  /// **'Additional notes'**
  String get additionalNotes;

  /// Additional information field label
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get additionalInformation;

  /// Additional information field hint text
  ///
  /// In en, this message translates to:
  /// **'Any other relevant information for your medical care...'**
  String get additionalInformationHint;

  /// Medical disclaimer text
  ///
  /// In en, this message translates to:
  /// **'This information helps us personalize responses, but does not replace professional medical consultation.'**
  String get disclaimerText;

  /// Success message when preferences are saved
  ///
  /// In en, this message translates to:
  /// **'Preferences saved successfully'**
  String get preferencesSavedSuccess;

  /// Error message when loading preferences fails
  ///
  /// In en, this message translates to:
  /// **'Error loading preferences: {error}'**
  String errorLoadingPreferences(String error);

  /// Error message when saving preferences fails
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSavingPreferences(String error);

  /// Error message when user is not found
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// App subtitle/tagline
  ///
  /// In en, this message translates to:
  /// **'Your Personal AI Doctor'**
  String get yourPersonalAIDoctor;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Email sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmail;

  /// Divider text between sign in options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Loading text for Google sign in
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Sign up prompt text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Sign up link text
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// Email verification dialog title
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get emailVerificationRequired;

  /// Email verification dialog message
  ///
  /// In en, this message translates to:
  /// **'Your email address needs to be verified before you can sign in.'**
  String get emailVerificationMessage;

  /// Verify email button text
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailButton;

  /// Reset password dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Reset password dialog message
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a password reset link.'**
  String get resetPasswordMessage;

  /// Email address field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Send reset link button text
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Password reset success message
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Check your email.'**
  String get passwordResetSent;

  /// Create account title and button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Sign up screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Join DocAI today'**
  String get joinDocAI;

  /// Email field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailAddress;

  /// Password field hint text
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get createStrongPassword;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password field hint text
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// Password requirements section title
  ///
  /// In en, this message translates to:
  /// **'Password requirements:'**
  String get passwordRequirements;

  /// Password requirement
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// Password requirement
  ///
  /// In en, this message translates to:
  /// **'Contains uppercase letter'**
  String get containsUppercase;

  /// Password requirement
  ///
  /// In en, this message translates to:
  /// **'Contains lowercase letter'**
  String get containsLowercase;

  /// Password requirement
  ///
  /// In en, this message translates to:
  /// **'Contains number'**
  String get containsNumber;

  /// Email validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterEmailAddress;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordMinLength;

  /// Password uppercase validation error
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordNeedsUppercase;

  /// Password lowercase validation error
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordNeedsLowercase;

  /// Password number validation error
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordNeedsNumber;

  /// Confirm password validation error
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Password confirmation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Account creation success message
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Please check your email for verification.'**
  String get accountCreatedSuccess;

  /// Account already exists error message
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please try signing in instead.'**
  String get accountAlreadyExists;

  /// Loading text for Google sign up
  ///
  /// In en, this message translates to:
  /// **'Signing up...'**
  String get signingUp;

  /// Google sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// Sign in prompt text
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Sign in link text
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Initial assistant message
  ///
  /// In en, this message translates to:
  /// **'Hello, I\'m Docai. How can I help you today?'**
  String get helloImDocai;

  /// New conversation button tooltip and dialog title
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newConversation;

  /// View history button tooltip
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get viewHistory;

  /// Medical notice dialog title
  ///
  /// In en, this message translates to:
  /// **'Medical notice'**
  String get medicalNotice;

  /// Understood button text
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// New conversation confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start a new conversation?'**
  String get newConversationConfirm;

  /// Delete history dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete history'**
  String get deleteHistory;

  /// Delete history confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all chat history? This action cannot be undone and will remove all conversations both locally and in the cloud.'**
  String get deleteHistoryConfirm;

  /// Delete all button text
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// Deleting history loading message
  ///
  /// In en, this message translates to:
  /// **'Deleting history...'**
  String get deletingHistory;

  /// History deletion success message
  ///
  /// In en, this message translates to:
  /// **'History deleted successfully'**
  String get historyDeletedSuccess;

  /// Error deleting history message
  ///
  /// In en, this message translates to:
  /// **'Error deleting history: {error}'**
  String errorDeletingHistory(String error);

  /// Personalization card title
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience'**
  String get personalizeYourExperience;

  /// Personalization card message
  ///
  /// In en, this message translates to:
  /// **'For more accurate and personalized recommendations, configure your medical preferences, allergies and conditions.'**
  String get personalizeExperienceMessage;

  /// Not now button text
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Personalize button text
  ///
  /// In en, this message translates to:
  /// **'Personalize'**
  String get personalize;

  /// Regeneration configuration sheet title
  ///
  /// In en, this message translates to:
  /// **'Configure regeneration'**
  String get configureRegeneration;

  /// Advanced reasoning toggle label
  ///
  /// In en, this message translates to:
  /// **'Advanced reasoning'**
  String get advancedReasoning;

  /// Advanced reasoning description
  ///
  /// In en, this message translates to:
  /// **'Docai will provide a more detailed step-by-step analysis.'**
  String get advancedReasoningDescription;

  /// Regenerate button text
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// Sync error status message
  ///
  /// In en, this message translates to:
  /// **'Sync error. Tap refresh to try again.'**
  String get syncError;

  /// Local storage status message
  ///
  /// In en, this message translates to:
  /// **'Conversations saved only on this device'**
  String get conversationsLocalOnly;

  /// Syncing status message
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// Recent sync status message
  ///
  /// In en, this message translates to:
  /// **'Synced less than a minute ago'**
  String get syncedLessThanMinute;

  /// Sync status message for minutes
  ///
  /// In en, this message translates to:
  /// **'Synced {minutes}m ago'**
  String syncedMinutesAgo(int minutes);

  /// Sync status message for hours
  ///
  /// In en, this message translates to:
  /// **'Synced {hours}h ago'**
  String syncedHoursAgo(int hours);

  /// Sync status message for days
  ///
  /// In en, this message translates to:
  /// **'Synced {days}d ago'**
  String syncedDaysAgo(int days);

  /// Auto sync enabled status message
  ///
  /// In en, this message translates to:
  /// **'Automatic sync enabled'**
  String get autoSyncEnabled;

  /// Cloud sync enabled success message
  ///
  /// In en, this message translates to:
  /// **'Cloud sync enabled'**
  String get cloudSyncEnabled;

  /// Cloud sync disabled success message
  ///
  /// In en, this message translates to:
  /// **'Cloud sync disabled'**
  String get cloudSyncDisabled;

  /// Sync completed success message
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get syncCompleted;

  /// Sync error message
  ///
  /// In en, this message translates to:
  /// **'Sync error: {error}'**
  String syncErrorMessage(String error);

  /// History screen title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Chat screen title
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
