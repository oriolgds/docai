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

  /// Preferred medicine type field label
  ///
  /// In en, this message translates to:
  /// **'Preferred Medicine Type'**
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

  /// Medical disclaimer card text in chat
  ///
  /// In en, this message translates to:
  /// **'DocAI does not replace professional medical advice. The information provided is for educational purposes. For diagnoses, treatments or emergencies consult a healthcare professional.'**
  String get medicalDisclaimerCard;

  /// Personalization menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get customizeYourExperience;

  /// Edit profile menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get updateYourInformation;

  /// Notifications menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your alerts'**
  String get manageYourAlerts;

  /// Privacy and security menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Privacy & security settings'**
  String get privacySecuritySettings;

  /// Help and support menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Get help when you need it'**
  String get getHelpWhenYouNeedIt;

  /// About menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Learn more about DocAI'**
  String get learnMoreAboutDocAI;

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

  /// Privacy and Security screen title
  ///
  /// In en, this message translates to:
  /// **'Privacy and Security'**
  String get privacyAndSecurity;

  /// Privacy screen header title
  ///
  /// In en, this message translates to:
  /// **'Your Privacy is Our Priority'**
  String get yourPrivacyIsOurPriority;

  /// Privacy screen introduction text
  ///
  /// In en, this message translates to:
  /// **'At DocAI, we understand the importance of protecting your health information. This section explains how we collect, process and protect your personal data.'**
  String get privacyIntroduction;

  /// Data collection section title
  ///
  /// In en, this message translates to:
  /// **'Data we collect'**
  String get dataWeCollect;

  /// Required account data subsection title
  ///
  /// In en, this message translates to:
  /// **'Account Data (Required)'**
  String get requiredAccountData;

  /// Required account data description
  ///
  /// In en, this message translates to:
  /// **'To use DocAI, we need to collect certain basic information that is essential for the service to function:\n\n**Email address** To create your account, authentication, and important communications.\n**Password** Stored securely with hash to protect your account.\n**Account creation date** For auditing and technical support purposes.\n\nThis data is absolutely necessary to provide you with the service and cannot be optional.'**
  String get requiredAccountDataDescription;

  /// Conversation data subsection title
  ///
  /// In en, this message translates to:
  /// **'Conversation Data'**
  String get conversationData;

  /// Conversation data description
  ///
  /// In en, this message translates to:
  /// **'All conversations you have with DocAI are stored for:\n\n**Service continuity** To maintain the context of your medical consultations.\n**Personalized medical history** Offer more accurate recommendations based on your history.\n**Service improvement** Analyze patterns to improve responses anonymously.\n\nEach message includes:\nMessage content\nDate and time\nType of consultation\nResponse generated by AI'**
  String get conversationDataDescription;

  /// Technical data subsection title
  ///
  /// In en, this message translates to:
  /// **'Technical Data'**
  String get technicalData;

  /// Technical data description
  ///
  /// In en, this message translates to:
  /// **'To ensure security and optimal service operation, we automatically collect:\n\n**IP address** To prevent abuse and detect suspicious activity.\n**Device information** Device type, operating system, app version.\n**Usage data** Usage frequency, functions used, session times.\n**Error logs** To identify and solve technical problems.\n\nThis information is collected automatically and is necessary for the secure operation of the service.'**
  String get technicalDataDescription;

  /// Optional data section title
  ///
  /// In en, this message translates to:
  /// **'Optional Data (You Choose)'**
  String get optionalDataYouChoose;

  /// Medical preferences subsection title
  ///
  /// In en, this message translates to:
  /// **'Medical Preferences'**
  String get medicalPreferencesData;

  /// Medical preferences data description
  ///
  /// In en, this message translates to:
  /// **'To personalize your experience and offer more accurate recommendations, you can choose to share:\n\n**Known allergies** To avoid recommendations for medications or treatments that could cause reactions.\n**Chronic medical conditions** Diabetes, hypertension, etc., to contextualize recommendations.\n**Current medications** To detect possible drug interactions.\n**Treatment preferences** Natural vs. conventional.\n**Age range and gender** For more specific recommendations.\n\n**IMPORTANT** All this information is completely optional. You can use DocAI without providing any of this data.'**
  String get medicalPreferencesDataDescription;

  /// Profile information subsection title
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// Profile information description
  ///
  /// In en, this message translates to:
  /// **'Optionally, you can complete your profile with:\n\n**Full name** To personalize the experience.\n**Profile photo** Only stored locally on your device.\n**Language preferences** To adapt the interface.\n**Notification settings** To control alerts.\n\nAll this information is optional and can be modified or deleted at any time from your profile.'**
  String get profileInformationDescription;

  /// Data processing section title
  ///
  /// In en, this message translates to:
  /// **'How We Process Your Data'**
  String get howWeProcessYourData;

  /// Medical consultation processing subsection title
  ///
  /// In en, this message translates to:
  /// **'Medical Consultation Processing'**
  String get medicalConsultationProcessing;

  /// Medical consultation processing description
  ///
  /// In en, this message translates to:
  /// **'When you make a medical consultation to DocAI:\n\n1. Your message is sent securely to our servers using **TLS 1.3** encryption.\n2. It is combined with your medical history (if it exists) to provide context.\n3. Your medical preferences (if you have provided them) are incorporated to personalize the response.\n4. It is processed by specialized medical AI that has been trained with verified medical knowledge.\n5. The response is generated and encrypted before being sent back to your device.\n\nThis entire process occurs in real-time and is designed to protect your privacy at every step.'**
  String get medicalConsultationProcessingDescription;

  /// Service analysis and improvement subsection title
  ///
  /// In en, this message translates to:
  /// **'Analysis and Service Improvement'**
  String get serviceAnalysisImprovement;

  /// Service analysis and improvement description
  ///
  /// In en, this message translates to:
  /// **'To continuously improve DocAI, we perform data analysis anonymously:\n\n**Consultation patterns** We identify the most common types of questions to improve responses.\n**Response effectiveness** We analyze which responses are most useful.\n**Technical performance** We monitor response times and errors.\n**Health trends** We identify emerging health topics in an aggregated and anonymous manner.\n\n**IMPORTANT** This analysis is **ALWAYS** performed with anonymized data. Specific analyses will never be linked to your personal identity.'**
  String get serviceAnalysisImprovementDescription;

  /// Encryption and security section title
  ///
  /// In en, this message translates to:
  /// **'Encryption and Security in Transit'**
  String get encryptionAndSecurity;

  /// Encryption in transit subsection title
  ///
  /// In en, this message translates to:
  /// **'Encryption in Transit'**
  String get encryptionInTransit;

  /// Encryption in transit description
  ///
  /// In en, this message translates to:
  /// **'All communication between your device and our servers is protected by multiple layers of security:\n\n**TLS 1.3 (Transport Layer Security)** The most advanced encryption protocol available.\n**Enterprise-grade SSL certificates** Validated by globally recognized certification authorities.\n**Perfect Forward Secrecy** Even if a future key is compromised, past communications remain secure.\n**HSTS (HTTP Strict Transport Security)** Ensures that all connections use HTTPS.\n\nThis means it is virtually impossible for third parties to intercept or read your data while it travels over the internet.'**
  String get encryptionInTransitDescription;

  /// Encryption at rest subsection title
  ///
  /// In en, this message translates to:
  /// **'Encryption at Rest'**
  String get encryptionAtRest;

  /// Encryption at rest description
  ///
  /// In en, this message translates to:
  /// **'When your data is stored on our servers, it is protected by:\n\n**AES-256 encryption** The gold standard for data encryption.\n**Rotating encryption keys** Keys are changed periodically for greater security.\n**Distributed storage** Data is fragmented and stored in multiple secure locations.\n**Restricted access** Only authorized personnel with legitimate purpose can access the systems.\n\nEven our own technical staff cannot read your conversations without appropriate authorization processes.'**
  String get encryptionAtRestDescription;

  /// Password protection subsection title
  ///
  /// In en, this message translates to:
  /// **'Password Protection'**
  String get passwordProtection;

  /// Password protection description
  ///
  /// In en, this message translates to:
  /// **'Your password receives special security treatment:\n\n**Salted hashing** Your password is never stored in plain text.\n**bcrypt algorithm** Used by banks and high-security organizations.\n**Multiple hash rounds** Makes decrypting the password computationally prohibitive.\n**Breach detection** Continuous monitoring to detect unauthorized access attempts.\n\nNot even we can see your real password. If you forget it, we can only help you create a new one.'**
  String get passwordProtectionDescription;

  /// Data storage and location section title
  ///
  /// In en, this message translates to:
  /// **'Data Storage and Location'**
  String get dataStorageAndLocation;

  /// Where data is stored subsection title
  ///
  /// In en, this message translates to:
  /// **'Where Your Data is Stored'**
  String get whereYourDataIsStored;

  /// Where data is stored description
  ///
  /// In en, this message translates to:
  /// **'Your data is stored in enterprise cloud infrastructure with the highest security certifications:\n\n**Certified data centers** ISO 27001, SOC 2 Type II, and other international standards.\n**Geographic location** Servers in Europe (GDPR compliance) and America.\n**Geographic redundancy** Backups in multiple locations to prevent data loss.\n**High availability** 99.9% uptime guaranteed.\n\nWe work only with cloud providers that comply with the strictest health regulations.'**
  String get whereYourDataIsStoredDescription;

  /// Data retention subsection title
  ///
  /// In en, this message translates to:
  /// **'Data Retention'**
  String get dataRetention;

  /// Data retention description
  ///
  /// In en, this message translates to:
  /// **'We establish clear periods for how long we retain your information:\n\n**Medical conversations** Retained while you maintain your active account.\n**Account data** Maintained until you request deletion.\n**Technical logs** Automatically deleted after 90 days.\n**Anonymous analysis data** Retained indefinitely for service improvement.\n\nYou can request complete deletion of all your data at any time.'**
  String get dataRetentionDescription;

  /// Data backups subsection title
  ///
  /// In en, this message translates to:
  /// **'Data Backups'**
  String get dataBackups;

  /// Data backups description
  ///
  /// In en, this message translates to:
  /// **'To protect your data against accidental loss:\n\n**Automatic daily backups** Performed automatically.\n**Distributed backups** Stored in multiple geographic locations.\n**Encrypted backups** All backups maintain the same level of encryption.\n**Limited retention** Backups are deleted after 30 days.\n\nThis ensures you never lose your medical history, even in case of technical failures.'**
  String get dataBackupsDescription;

  /// User rights and control section title
  ///
  /// In en, this message translates to:
  /// **'Your Rights and Control Over Your Data'**
  String get yourRightsAndControl;

  /// Right of access subsection title
  ///
  /// In en, this message translates to:
  /// **'Right of Access'**
  String get rightOfAccess;

  /// Right of access description
  ///
  /// In en, this message translates to:
  /// **'You have the complete right to access all the data we have about you:\n\n**Complete download** You can download all your data in readable format.\n**Detailed history** Access to all your conversations and metadata.\n**Account information** All data associated with your profile.\n**Activity logs** Record of when and how your data has been used.\n\nYou can request this information at any time from your profile or by contacting us directly.'**
  String get rightOfAccessDescription;

  /// Right of rectification subsection title
  ///
  /// In en, this message translates to:
  /// **'Right of Rectification'**
  String get rightOfRectification;

  /// Right of rectification description
  ///
  /// In en, this message translates to:
  /// **'You can correct any incorrect information:\n\n**Profile data** Modify name, preferences, etc., directly from the app.\n**Medical preferences** Update allergies, medications, conditions at any time.\n**Conversation correction** Request corrections of misinterpreted medical information.\n**Automatic update** Changes are applied immediately to all future conversations.\n\nKeeping your data up to date helps DocAI provide you with the best recommendations.'**
  String get rightOfRectificationDescription;

  /// Right of erasure subsection title
  ///
  /// In en, this message translates to:
  /// **'Right of Erasure'**
  String get rightOfErasure;

  /// Right of erasure description
  ///
  /// In en, this message translates to:
  /// **'You can delete your data partially or completely:\n\n**Specific conversation deletion** From chat history.\n**Complete history cleanup** Delete all conversations while maintaining the account.\n**Complete account deletion** Permanent deletion of all data.\n**30-day process** Grace period to recover accidentally deleted data.\n\nOnce the deletion process is complete, data cannot be recovered.'**
  String get rightOfErasureDescription;

  /// Right of portability subsection title
  ///
  /// In en, this message translates to:
  /// **'Right of Portability'**
  String get rightOfPortability;

  /// Right of portability description
  ///
  /// In en, this message translates to:
  /// **'You can take your data to another service:\n\n**Standard format** Export in JSON, CSV, or PDF.\n**Complete data** Includes conversations, preferences, and metadata.\n**Simple process** Download available from account settings.\n**No restrictions** We do not charge or limit data exports.\n\nYour information belongs to you and you can take it with you whenever you wish.'**
  String get rightOfPortabilityDescription;

  /// Additional security measures section title
  ///
  /// In en, this message translates to:
  /// **'Additional Security Measures'**
  String get additionalSecurityMeasures;

  /// 24/7 security monitoring subsection title
  ///
  /// In en, this message translates to:
  /// **'24/7 Security Monitoring'**
  String get security247Monitoring;

  /// 24/7 security monitoring description
  ///
  /// In en, this message translates to:
  /// **'We protect your data with constant vigilance:\n\n**Anomaly detection** AI systems that identify suspicious patterns.\n**Real-time alerts** Immediate notification of any unusual activity.\n**Response team** Security specialists available 24 hours a day.\n**Regular audits** Monthly reviews of all security systems.\n\nAny potential threat is identified and neutralized before it can affect your data.'**
  String get security247MonitoringDescription;

  /// Authentication and access control subsection title
  ///
  /// In en, this message translates to:
  /// **'Authentication and Access Control'**
  String get authenticationAccessControl;

  /// Authentication and access control description
  ///
  /// In en, this message translates to:
  /// **'Multiple layers of protection for your account:\n\n**Multi-factor authentication available** Optional additional protection for your account.\n**Secure sessions** Session tokens that expire automatically.\n**Device detection** Alerts when accessed from new devices.\n**Failed attempt blocking** Protection against brute force attacks.\n\nYour account is protected even if your password is compromised.'**
  String get authenticationAccessControlDescription;

  /// Regulatory compliance subsection title
  ///
  /// In en, this message translates to:
  /// **'Regulatory Compliance'**
  String get regulatoryCompliance;

  /// Regulatory compliance description
  ///
  /// In en, this message translates to:
  /// **'We comply with the strictest privacy regulations:\n\n**GDPR (Europe)** General Data Protection Regulation.\n**HIPAA (United States)** Health Insurance Portability and Accountability Act.\n**PIPEDA (Canada)** Personal Information Protection and Electronic Documents Act.\n**Independent audits** Annual certifications by third parties.\n\nOur privacy practices are verified by external auditors specialized in digital health.'**
  String get regulatoryComplianceDescription;

  /// Contact and support section title
  ///
  /// In en, this message translates to:
  /// **'Contact and Support'**
  String get contactAndSupport;

  /// Privacy questions subsection title
  ///
  /// In en, this message translates to:
  /// **'Privacy Questions'**
  String get privacyQuestions;

  /// Privacy questions description
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about how we handle your data:\n\n**Privacy email** privacy@docai.app\n**Response time** Maximum 48 hours.\n**Data Protection Officer** Available for specific consultations.\n**Live chat** Immediate support during business hours.\n\nOur privacy team is specialized in answering all your personal data concerns.'**
  String get privacyQuestionsDescription;

  /// Report security issues subsection title
  ///
  /// In en, this message translates to:
  /// **'Report Security Issues'**
  String get reportSecurityIssues;

  /// Report security issues description
  ///
  /// In en, this message translates to:
  /// **'If you discover a security issue, contact us immediately:\n\n**Security email** security@docai.app\n**Bug bounty program** Rewards for vulnerability discoveries.\n**Responsible disclosure** Established process for reporting issues.\n**Guaranteed response** Confirmation in less than 24 hours.\n\nYour help in keeping DocAI secure is invaluable and always recognized.'**
  String get reportSecurityIssuesDescription;

  /// Quick access section title
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// Favorites menu item
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Share menu item
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Backup menu item
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// Consultations count label
  ///
  /// In en, this message translates to:
  /// **'Consultations'**
  String get consultations;

  /// Last usage label
  ///
  /// In en, this message translates to:
  /// **'Last usage'**
  String get lastUsage;

  /// Satisfaction label
  ///
  /// In en, this message translates to:
  /// **'Satisfaction'**
  String get satisfaction;

  /// Never used label
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// Configure medical info subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure your medical information'**
  String get configureMedicalInfo;

  /// Premium plan subtitle
  ///
  /// In en, this message translates to:
  /// **'Enjoy all features'**
  String get enjoyAllFeatures;

  /// Manage button text
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// Language settings menu item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettings;

  /// Change app language subtitle
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// Privacy and security menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Privacy and security'**
  String get privacyAndSecuritySettings;

  /// Help center subtitle
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenter;

  /// About project subtitle
  ///
  /// In en, this message translates to:
  /// **'Project information'**
  String get projectInformation;

  /// Delete account menu item
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// Delete account description
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all associated data'**
  String get deleteAccountDescription;

  /// Dangerous action label
  ///
  /// In en, this message translates to:
  /// **'Dangerous'**
  String get dangerous;

  /// Quick settings modal title
  ///
  /// In en, this message translates to:
  /// **'Quick Settings'**
  String get quickSettings;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Location setting
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Select language modal title
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguageTitle;

  /// Premium plan modal title
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlanTitle;

  /// Premium feature
  ///
  /// In en, this message translates to:
  /// **'Unlimited consultations'**
  String get unlimitedConsultationsFeature;

  /// Premium feature
  ///
  /// In en, this message translates to:
  /// **'Priority access'**
  String get priorityAccess;

  /// Premium feature
  ///
  /// In en, this message translates to:
  /// **'Complete history'**
  String get completeHistory;

  /// Premium feature
  ///
  /// In en, this message translates to:
  /// **'Premium support'**
  String get premiumSupport;

  /// Cancel plan button
  ///
  /// In en, this message translates to:
  /// **'Cancel plan'**
  String get cancelPlan;

  /// Cloud sync modal title
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSyncTitle;

  /// Sync complete title
  ///
  /// In en, this message translates to:
  /// **'Sync Complete'**
  String get syncCompleteTitle;

  /// Syncing title
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncingTitle;

  /// Sync complete description
  ///
  /// In en, this message translates to:
  /// **'Your history has been successfully synced to the cloud. You can now access it from any device.'**
  String get syncCompleteDescription;

  /// Syncing description
  ///
  /// In en, this message translates to:
  /// **'We are securely saving your history to the cloud...'**
  String get syncingDescription;

  /// Cloud sync description
  ///
  /// In en, this message translates to:
  /// **'Back up your conversation history to the cloud to keep it safe and accessible from any device.'**
  String get cloudSyncDescription;

  /// Security feature title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Security feature description
  ///
  /// In en, this message translates to:
  /// **'End-to-end encryption'**
  String get endToEndEncryption;

  /// Multi-device feature title
  ///
  /// In en, this message translates to:
  /// **'Multi-device'**
  String get multiDevice;

  /// Multi-device feature description
  ///
  /// In en, this message translates to:
  /// **'Access from anywhere'**
  String get accessFromAnywhere;

  /// Automatic backup feature title
  ///
  /// In en, this message translates to:
  /// **'Automatic Backup'**
  String get automaticBackup;

  /// Automatic backup feature description
  ///
  /// In en, this message translates to:
  /// **'Continuous sync'**
  String get continuousSync;

  /// Sync now button
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Not now button
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNowButton;

  /// History synced success message
  ///
  /// In en, this message translates to:
  /// **'History synced successfully'**
  String get historySyncedSuccessfully;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type your medical query...'**
  String get typeYourMedicalQuery;

  /// Generating response placeholder
  ///
  /// In en, this message translates to:
  /// **'Generating response...'**
  String get generatingResponseMessage;

  /// Send button tooltip
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Cancel generation tooltip
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelGeneration;

  /// Scroll to bottom tooltip
  ///
  /// In en, this message translates to:
  /// **'Go to bottom'**
  String get scrollToBottom;

  /// Reasoning toggle label
  ///
  /// In en, this message translates to:
  /// **'Reasoning'**
  String get reasoning;

  /// Medical disclaimer card text
  ///
  /// In en, this message translates to:
  /// **'DocAI does not replace professional medical advice. The information provided is for educational purposes. For diagnoses, treatments or emergencies consult a healthcare professional.'**
  String get medicalDisclaimerCardText;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Delete conversation confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation?'**
  String get deleteConversationConfirm;

  /// Medical personalization screen title
  ///
  /// In en, this message translates to:
  /// **'Medical Personalization'**
  String get medicalPersonalizationTitle;

  /// Important notice card title
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get importantNotice;

  /// DocAI medical disclaimer text
  ///
  /// In en, this message translates to:
  /// **'DocAI does not replace professional medical advice. The information provided is for educational purposes. For diagnoses, treatments or emergencies consult a healthcare professional.'**
  String get docaiDisclaimer;

  /// Date of birth field label
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// Not specified option
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Prefer not to say gender option
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// Weight field label
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// Height field label
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// Allergies and intolerances section title
  ///
  /// In en, this message translates to:
  /// **'Allergies and Intolerances'**
  String get allergiesAndIntolerances;

  /// General allergies field title
  ///
  /// In en, this message translates to:
  /// **'General Allergies'**
  String get generalAllergies;

  /// Medication allergies field title
  ///
  /// In en, this message translates to:
  /// **'Medication Allergies'**
  String get medicationAllergies;

  /// Food intolerances field title
  ///
  /// In en, this message translates to:
  /// **'Food Intolerances'**
  String get foodIntolerances;

  /// Treatment preferences section title
  ///
  /// In en, this message translates to:
  /// **'Treatment Preferences'**
  String get treatmentPreferences;

  /// Both medicine types option
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// Medications to avoid field title
  ///
  /// In en, this message translates to:
  /// **'Medications to Avoid'**
  String get medicationsToAvoid;

  /// Preferred treatments field title
  ///
  /// In en, this message translates to:
  /// **'Preferred Treatments'**
  String get preferredTreatments;

  /// Previous surgeries field title
  ///
  /// In en, this message translates to:
  /// **'Previous Surgeries'**
  String get previousSurgeries;

  /// Smoking habit field label
  ///
  /// In en, this message translates to:
  /// **'Smoking Habit'**
  String get smokingHabit;

  /// Former smoker option
  ///
  /// In en, this message translates to:
  /// **'Former Smoker'**
  String get formerSmoker;

  /// Light smoker option
  ///
  /// In en, this message translates to:
  /// **'Light Smoker'**
  String get lightSmoker;

  /// Moderate smoker option
  ///
  /// In en, this message translates to:
  /// **'Moderate Smoker'**
  String get moderateSmoker;

  /// Heavy smoker option
  ///
  /// In en, this message translates to:
  /// **'Heavy Smoker'**
  String get heavySmoker;

  /// Alcohol consumption field label
  ///
  /// In en, this message translates to:
  /// **'Alcohol Consumption'**
  String get alcoholConsumption;

  /// Occasional alcohol consumption option
  ///
  /// In en, this message translates to:
  /// **'Occasional'**
  String get occasional;

  /// Frequent alcohol consumption option
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get frequent;

  /// Daily alcohol consumption option
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Exercise frequency field label
  ///
  /// In en, this message translates to:
  /// **'Exercise Frequency'**
  String get exerciseFrequency;

  /// Intense exercise option
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get intense;

  /// Diet type field label
  ///
  /// In en, this message translates to:
  /// **'Diet Type'**
  String get dietType;

  /// Omnivore diet option
  ///
  /// In en, this message translates to:
  /// **'Omnivore'**
  String get omnivore;

  /// Vegetarian diet option
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// Vegan diet option
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// Pescatarian diet option
  ///
  /// In en, this message translates to:
  /// **'Pescatarian'**
  String get pescatarian;

  /// Keto diet option
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get keto;

  /// Mediterranean diet option
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get mediterranean;

  /// Emergency contact section title
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// Emergency contact name field label
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// Emergency phone field label
  ///
  /// In en, this message translates to:
  /// **'Emergency Phone'**
  String get emergencyPhone;

  /// Additional preferences section title
  ///
  /// In en, this message translates to:
  /// **'Additional Preferences'**
  String get additionalPreferences;

  /// Preferred language field label
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get preferredLanguage;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Catalan language option
  ///
  /// In en, this message translates to:
  /// **'Catalan'**
  String get catalan;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Communication style field label
  ///
  /// In en, this message translates to:
  /// **'Communication Style'**
  String get communicationStyle;

  /// Direct communication style option
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get direct;

  /// Detailed communication style option
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get detailed;

  /// Gentle communication style option
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get gentle;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Lifestyle section title
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get lifestyle;

  /// Moderate option
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// None option
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Light option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Balanced communication style option
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// Maintenance mode title
  ///
  /// In en, this message translates to:
  /// **'Maintenance Mode'**
  String get maintenanceMode;

  /// Maintenance mode message
  ///
  /// In en, this message translates to:
  /// **'Chat is temporarily disabled for maintenance. Please try again later.'**
  String get maintenanceModeMessage;
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
