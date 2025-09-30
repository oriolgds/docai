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

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Back navigation button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next navigation button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Search functionality
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning message
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Information message
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// Affirmative response
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Negative response
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Medications preset
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// Natural remedies preset
  ///
  /// In en, this message translates to:
  /// **'Natural Remedies'**
  String get naturalRemedies;

  /// Symptoms field
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// Diagnosis information
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// Treatment information
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatment;

  /// Prescription information
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescription;

  /// Dosage information
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// Side effects information
  ///
  /// In en, this message translates to:
  /// **'Side Effects'**
  String get sideEffects;

  /// Contraindications information
  ///
  /// In en, this message translates to:
  /// **'Contraindications'**
  String get contraindications;

  /// Medical history field
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// Family history field
  ///
  /// In en, this message translates to:
  /// **'Family History'**
  String get familyHistory;

  /// Allergic reactions field
  ///
  /// In en, this message translates to:
  /// **'Allergic Reactions'**
  String get allergicReactions;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// Send message button
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// Ask DocAI button
  ///
  /// In en, this message translates to:
  /// **'Ask DocAI'**
  String get askDocAI;

  /// AI thinking message
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// Processing message
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Response generation message
  ///
  /// In en, this message translates to:
  /// **'Generating response...'**
  String get generatingResponse;

  /// Empty chat state
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Empty chat call to action
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with DocAI'**
  String get startConversation;

  /// Conversation history title
  ///
  /// In en, this message translates to:
  /// **'Conversation History'**
  String get conversationHistory;

  /// Message options menu
  ///
  /// In en, this message translates to:
  /// **'Message Options'**
  String get messageOptions;

  /// Copy message option
  ///
  /// In en, this message translates to:
  /// **'Copy Message'**
  String get copyMessage;

  /// Report message option
  ///
  /// In en, this message translates to:
  /// **'Report Message'**
  String get reportMessage;

  /// Delete message option
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessage;

  /// Empty history state
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// Clear history button
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// Export history button
  ///
  /// In en, this message translates to:
  /// **'Export History'**
  String get exportHistory;

  /// Import history button
  ///
  /// In en, this message translates to:
  /// **'Import History'**
  String get importHistory;

  /// Delete conversation button
  ///
  /// In en, this message translates to:
  /// **'Delete Conversation'**
  String get deleteConversation;

  /// Conversation deleted message
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// History cleared message
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// Last activity label
  ///
  /// In en, this message translates to:
  /// **'Last activity'**
  String get lastActivity;

  /// Today date label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday date label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// This week date label
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// Last week date label
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// This month date label
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// Older date label
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get older;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Change language option
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Language changed confirmation
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// Select language prompt
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// System language option
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get systemLanguage;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// Connection failed message
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Request timeout message
  ///
  /// In en, this message translates to:
  /// **'Request timeout'**
  String get requestTimeout;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// Not found error message
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// Unauthorized error message
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// Forbidden error message
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get forbidden;

  /// Bad request error message
  ///
  /// In en, this message translates to:
  /// **'Bad request'**
  String get badRequest;

  /// Medical disclaimer title
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get medicalDisclaimer;

  /// Medical disclaimer text
  ///
  /// In en, this message translates to:
  /// **'DocAI provides general health information and should not replace professional medical advice, diagnosis, or treatment. Always consult with qualified healthcare providers for medical concerns.'**
  String get medicalDisclaimerText;

  /// Emergency warning title
  ///
  /// In en, this message translates to:
  /// **'Emergency Warning'**
  String get emergencyWarning;

  /// Emergency warning text
  ///
  /// In en, this message translates to:
  /// **'If you are experiencing a medical emergency, please call emergency services immediately or go to the nearest emergency room.'**
  String get emergencyWarningText;

  /// Not medical advice disclaimer
  ///
  /// In en, this message translates to:
  /// **'This is not medical advice'**
  String get notMedicalAdvice;

  /// Consult doctor advice
  ///
  /// In en, this message translates to:
  /// **'Please consult a doctor'**
  String get consultDoctor;

  /// Seek immediate help advice
  ///
  /// In en, this message translates to:
  /// **'Seek immediate medical help'**
  String get seekImmediateHelp;

  /// Medical profile configured status title
  ///
  /// In en, this message translates to:
  /// **'Medical Profile Configured'**
  String get medicalProfileConfigured;

  /// Medical profile incomplete status title
  ///
  /// In en, this message translates to:
  /// **'Medical Profile Incomplete'**
  String get medicalProfileIncomplete;

  /// Medical profile configured status description
  ///
  /// In en, this message translates to:
  /// **'Your medical profile is configured. DocAI can provide more personalized advice.'**
  String get medicalProfileConfiguredDescription;

  /// Medical profile incomplete status description
  ///
  /// In en, this message translates to:
  /// **'Configure your medical profile to receive more accurate and personalized advice.'**
  String get medicalProfileIncompleteDescription;

  /// Age display format
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String yearsOld(int age);

  /// Allergies count format
  ///
  /// In en, this message translates to:
  /// **'{count} allergies'**
  String allergiesCount(int count);

  /// Natural medicine preference
  ///
  /// In en, this message translates to:
  /// **'Natural medicine'**
  String get naturalMedicine;

  /// Conventional medicine preference
  ///
  /// In en, this message translates to:
  /// **'Conventional medicine'**
  String get conventionalMedicine;

  /// Both medicine types preference
  ///
  /// In en, this message translates to:
  /// **'Integral medicine'**
  String get integralMedicine;

  /// Conditions count format
  ///
  /// In en, this message translates to:
  /// **'{count} conditions'**
  String conditionsCount(int count);

  /// Medical personalization button title
  ///
  /// In en, this message translates to:
  /// **'Medical Personalization'**
  String get medicalPersonalization;

  /// Medical personalization button subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure allergies, treatment preferences and more'**
  String get configureMedicalPreferences;
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
