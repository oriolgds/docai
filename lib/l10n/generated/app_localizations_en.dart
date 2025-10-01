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
  String get medicalDisclaimerCard =>
      'DocAI does not replace professional medical advice. The information provided is for educational purposes. For diagnoses, treatments or emergencies consult a healthcare professional.';

  @override
  String get customizeYourExperience => 'Customize your experience';

  @override
  String get updateYourInformation => 'Update your information';

  @override
  String get manageYourAlerts => 'Manage your alerts';

  @override
  String get privacySecuritySettings => 'Privacy & security settings';

  @override
  String get getHelpWhenYouNeedIt => 'Get help when you need it';

  @override
  String get learnMoreAboutDocAI => 'Learn more about DocAI';

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

  @override
  String get home => 'Home';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search';

  @override
  String get refresh => 'Refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get confirm => 'Confirm';

  @override
  String get medications => 'Medications';

  @override
  String get naturalRemedies => 'Natural Remedies';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get diagnosis => 'Diagnosis';

  @override
  String get treatment => 'Treatment';

  @override
  String get prescription => 'Prescription';

  @override
  String get dosage => 'Dosage';

  @override
  String get sideEffects => 'Side Effects';

  @override
  String get contraindications => 'Contraindications';

  @override
  String get medicalHistory => 'Medical History';

  @override
  String get familyHistory => 'Family History';

  @override
  String get allergicReactions => 'Allergic Reactions';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get sendMessage => 'Send message';

  @override
  String get askDocAI => 'Ask DocAI';

  @override
  String get thinking => 'Thinking...';

  @override
  String get processing => 'Processing...';

  @override
  String get generatingResponse => 'Generating response...';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startConversation => 'Start a conversation with DocAI';

  @override
  String get conversationHistory => 'Conversation History';

  @override
  String get messageOptions => 'Message Options';

  @override
  String get copyMessage => 'Copy Message';

  @override
  String get reportMessage => 'Report Message';

  @override
  String get deleteMessage => 'Delete Message';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get exportHistory => 'Export History';

  @override
  String get importHistory => 'Import History';

  @override
  String get deleteConversation => 'Delete Conversation';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get lastActivity => 'Last activity';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This week';

  @override
  String get lastWeek => 'Last week';

  @override
  String get thisMonth => 'This month';

  @override
  String get older => 'Older';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get systemLanguage => 'System Language';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get networkError => 'Network error';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get tryAgain => 'Try again';

  @override
  String get requestTimeout => 'Request timeout';

  @override
  String get serverError => 'Server error';

  @override
  String get notFound => 'Not found';

  @override
  String get unauthorized => 'Unauthorized';

  @override
  String get forbidden => 'Forbidden';

  @override
  String get badRequest => 'Bad request';

  @override
  String get medicalDisclaimer => 'Medical Disclaimer';

  @override
  String get medicalDisclaimerText =>
      'DocAI provides general health information and should not replace professional medical advice, diagnosis, or treatment. Always consult with qualified healthcare providers for medical concerns.';

  @override
  String get emergencyWarning => 'Emergency Warning';

  @override
  String get emergencyWarningText =>
      'If you are experiencing a medical emergency, please call emergency services immediately or go to the nearest emergency room.';

  @override
  String get notMedicalAdvice => 'This is not medical advice';

  @override
  String get consultDoctor => 'Please consult a doctor';

  @override
  String get seekImmediateHelp => 'Seek immediate medical help';

  @override
  String get medicalProfileConfigured => 'Medical Profile Configured';

  @override
  String get medicalProfileIncomplete => 'Medical Profile Incomplete';

  @override
  String get medicalProfileConfiguredDescription =>
      'Your medical profile is configured. DocAI can provide more personalized advice.';

  @override
  String get medicalProfileIncompleteDescription =>
      'Configure your medical profile to receive more accurate and personalized advice.';

  @override
  String yearsOld(int age) {
    return '$age years old';
  }

  @override
  String allergiesCount(int count) {
    return '$count allergies';
  }

  @override
  String get naturalMedicine => 'Natural medicine';

  @override
  String get conventionalMedicine => 'Conventional medicine';

  @override
  String get integralMedicine => 'Integral medicine';

  @override
  String conditionsCount(int count) {
    return '$count conditions';
  }

  @override
  String get medicalPersonalization => 'Medical Personalization';

  @override
  String get configureMedicalPreferences =>
      'Configure allergies, treatment preferences and more';

  @override
  String get privacyAndSecurity => 'Privacy and Security';

  @override
  String get yourPrivacyIsOurPriority => 'Your Privacy is Our Priority';

  @override
  String get privacyIntroduction =>
      'At DocAI, we understand the importance of protecting your health information. This section explains how we collect, process and protect your personal data.';

  @override
  String get dataWeCollect => 'Data we collect';

  @override
  String get requiredAccountData => 'Account Data (Required)';

  @override
  String get requiredAccountDataDescription =>
      'To use DocAI, we need to collect certain basic information that is essential for the service to function:\n\n**Email address** To create your account, authentication, and important communications.\n**Password** Stored securely with hash to protect your account.\n**Account creation date** For auditing and technical support purposes.\n\nThis data is absolutely necessary to provide you with the service and cannot be optional.';

  @override
  String get conversationData => 'Conversation Data';

  @override
  String get conversationDataDescription =>
      'All conversations you have with DocAI are stored for:\n\n**Service continuity** To maintain the context of your medical consultations.\n**Personalized medical history** Offer more accurate recommendations based on your history.\n**Service improvement** Analyze patterns to improve responses anonymously.\n\nEach message includes:\nMessage content\nDate and time\nType of consultation\nResponse generated by AI';

  @override
  String get technicalData => 'Technical Data';

  @override
  String get technicalDataDescription =>
      'To ensure security and optimal service operation, we automatically collect:\n\n**IP address** To prevent abuse and detect suspicious activity.\n**Device information** Device type, operating system, app version.\n**Usage data** Usage frequency, functions used, session times.\n**Error logs** To identify and solve technical problems.\n\nThis information is collected automatically and is necessary for the secure operation of the service.';

  @override
  String get optionalDataYouChoose => 'Optional Data (You Choose)';

  @override
  String get medicalPreferencesData => 'Medical Preferences';

  @override
  String get medicalPreferencesDataDescription =>
      'To personalize your experience and offer more accurate recommendations, you can choose to share:\n\n**Known allergies** To avoid recommendations for medications or treatments that could cause reactions.\n**Chronic medical conditions** Diabetes, hypertension, etc., to contextualize recommendations.\n**Current medications** To detect possible drug interactions.\n**Treatment preferences** Natural vs. conventional.\n**Age range and gender** For more specific recommendations.\n\n**IMPORTANT** All this information is completely optional. You can use DocAI without providing any of this data.';

  @override
  String get profileInformation => 'Profile Information';

  @override
  String get profileInformationDescription =>
      'Optionally, you can complete your profile with:\n\n**Full name** To personalize the experience.\n**Profile photo** Only stored locally on your device.\n**Language preferences** To adapt the interface.\n**Notification settings** To control alerts.\n\nAll this information is optional and can be modified or deleted at any time from your profile.';

  @override
  String get howWeProcessYourData => 'How We Process Your Data';

  @override
  String get medicalConsultationProcessing => 'Medical Consultation Processing';

  @override
  String get medicalConsultationProcessingDescription =>
      'When you make a medical consultation to DocAI:\n\n1. Your message is sent securely to our servers using **TLS 1.3** encryption.\n2. It is combined with your medical history (if it exists) to provide context.\n3. Your medical preferences (if you have provided them) are incorporated to personalize the response.\n4. It is processed by specialized medical AI that has been trained with verified medical knowledge.\n5. The response is generated and encrypted before being sent back to your device.\n\nThis entire process occurs in real-time and is designed to protect your privacy at every step.';

  @override
  String get serviceAnalysisImprovement => 'Analysis and Service Improvement';

  @override
  String get serviceAnalysisImprovementDescription =>
      'To continuously improve DocAI, we perform data analysis anonymously:\n\n**Consultation patterns** We identify the most common types of questions to improve responses.\n**Response effectiveness** We analyze which responses are most useful.\n**Technical performance** We monitor response times and errors.\n**Health trends** We identify emerging health topics in an aggregated and anonymous manner.\n\n**IMPORTANT** This analysis is **ALWAYS** performed with anonymized data. Specific analyses will never be linked to your personal identity.';

  @override
  String get encryptionAndSecurity => 'Encryption and Security in Transit';

  @override
  String get encryptionInTransit => 'Encryption in Transit';

  @override
  String get encryptionInTransitDescription =>
      'All communication between your device and our servers is protected by multiple layers of security:\n\n**TLS 1.3 (Transport Layer Security)** The most advanced encryption protocol available.\n**Enterprise-grade SSL certificates** Validated by globally recognized certification authorities.\n**Perfect Forward Secrecy** Even if a future key is compromised, past communications remain secure.\n**HSTS (HTTP Strict Transport Security)** Ensures that all connections use HTTPS.\n\nThis means it is virtually impossible for third parties to intercept or read your data while it travels over the internet.';

  @override
  String get encryptionAtRest => 'Encryption at Rest';

  @override
  String get encryptionAtRestDescription =>
      'When your data is stored on our servers, it is protected by:\n\n**AES-256 encryption** The gold standard for data encryption.\n**Rotating encryption keys** Keys are changed periodically for greater security.\n**Distributed storage** Data is fragmented and stored in multiple secure locations.\n**Restricted access** Only authorized personnel with legitimate purpose can access the systems.\n\nEven our own technical staff cannot read your conversations without appropriate authorization processes.';

  @override
  String get passwordProtection => 'Password Protection';

  @override
  String get passwordProtectionDescription =>
      'Your password receives special security treatment:\n\n**Salted hashing** Your password is never stored in plain text.\n**bcrypt algorithm** Used by banks and high-security organizations.\n**Multiple hash rounds** Makes decrypting the password computationally prohibitive.\n**Breach detection** Continuous monitoring to detect unauthorized access attempts.\n\nNot even we can see your real password. If you forget it, we can only help you create a new one.';

  @override
  String get dataStorageAndLocation => 'Data Storage and Location';

  @override
  String get whereYourDataIsStored => 'Where Your Data is Stored';

  @override
  String get whereYourDataIsStoredDescription =>
      'Your data is stored in enterprise cloud infrastructure with the highest security certifications:\n\n**Certified data centers** ISO 27001, SOC 2 Type II, and other international standards.\n**Geographic location** Servers in Europe (GDPR compliance) and America.\n**Geographic redundancy** Backups in multiple locations to prevent data loss.\n**High availability** 99.9% uptime guaranteed.\n\nWe work only with cloud providers that comply with the strictest health regulations.';

  @override
  String get dataRetention => 'Data Retention';

  @override
  String get dataRetentionDescription =>
      'We establish clear periods for how long we retain your information:\n\n**Medical conversations** Retained while you maintain your active account.\n**Account data** Maintained until you request deletion.\n**Technical logs** Automatically deleted after 90 days.\n**Anonymous analysis data** Retained indefinitely for service improvement.\n\nYou can request complete deletion of all your data at any time.';

  @override
  String get dataBackups => 'Data Backups';

  @override
  String get dataBackupsDescription =>
      'To protect your data against accidental loss:\n\n**Automatic daily backups** Performed automatically.\n**Distributed backups** Stored in multiple geographic locations.\n**Encrypted backups** All backups maintain the same level of encryption.\n**Limited retention** Backups are deleted after 30 days.\n\nThis ensures you never lose your medical history, even in case of technical failures.';

  @override
  String get yourRightsAndControl => 'Your Rights and Control Over Your Data';

  @override
  String get rightOfAccess => 'Right of Access';

  @override
  String get rightOfAccessDescription =>
      'You have the complete right to access all the data we have about you:\n\n**Complete download** You can download all your data in readable format.\n**Detailed history** Access to all your conversations and metadata.\n**Account information** All data associated with your profile.\n**Activity logs** Record of when and how your data has been used.\n\nYou can request this information at any time from your profile or by contacting us directly.';

  @override
  String get rightOfRectification => 'Right of Rectification';

  @override
  String get rightOfRectificationDescription =>
      'You can correct any incorrect information:\n\n**Profile data** Modify name, preferences, etc., directly from the app.\n**Medical preferences** Update allergies, medications, conditions at any time.\n**Conversation correction** Request corrections of misinterpreted medical information.\n**Automatic update** Changes are applied immediately to all future conversations.\n\nKeeping your data up to date helps DocAI provide you with the best recommendations.';

  @override
  String get rightOfErasure => 'Right of Erasure';

  @override
  String get rightOfErasureDescription =>
      'You can delete your data partially or completely:\n\n**Specific conversation deletion** From chat history.\n**Complete history cleanup** Delete all conversations while maintaining the account.\n**Complete account deletion** Permanent deletion of all data.\n**30-day process** Grace period to recover accidentally deleted data.\n\nOnce the deletion process is complete, data cannot be recovered.';

  @override
  String get rightOfPortability => 'Right of Portability';

  @override
  String get rightOfPortabilityDescription =>
      'You can take your data to another service:\n\n**Standard format** Export in JSON, CSV, or PDF.\n**Complete data** Includes conversations, preferences, and metadata.\n**Simple process** Download available from account settings.\n**No restrictions** We do not charge or limit data exports.\n\nYour information belongs to you and you can take it with you whenever you wish.';

  @override
  String get additionalSecurityMeasures => 'Additional Security Measures';

  @override
  String get security247Monitoring => '24/7 Security Monitoring';

  @override
  String get security247MonitoringDescription =>
      'We protect your data with constant vigilance:\n\n**Anomaly detection** AI systems that identify suspicious patterns.\n**Real-time alerts** Immediate notification of any unusual activity.\n**Response team** Security specialists available 24 hours a day.\n**Regular audits** Monthly reviews of all security systems.\n\nAny potential threat is identified and neutralized before it can affect your data.';

  @override
  String get authenticationAccessControl => 'Authentication and Access Control';

  @override
  String get authenticationAccessControlDescription =>
      'Multiple layers of protection for your account:\n\n**Multi-factor authentication available** Optional additional protection for your account.\n**Secure sessions** Session tokens that expire automatically.\n**Device detection** Alerts when accessed from new devices.\n**Failed attempt blocking** Protection against brute force attacks.\n\nYour account is protected even if your password is compromised.';

  @override
  String get regulatoryCompliance => 'Regulatory Compliance';

  @override
  String get regulatoryComplianceDescription =>
      'We comply with the strictest privacy regulations:\n\n**GDPR (Europe)** General Data Protection Regulation.\n**HIPAA (United States)** Health Insurance Portability and Accountability Act.\n**PIPEDA (Canada)** Personal Information Protection and Electronic Documents Act.\n**Independent audits** Annual certifications by third parties.\n\nOur privacy practices are verified by external auditors specialized in digital health.';

  @override
  String get contactAndSupport => 'Contact and Support';

  @override
  String get privacyQuestions => 'Privacy Questions';

  @override
  String get privacyQuestionsDescription =>
      'If you have any questions about how we handle your data:\n\n**Privacy email** privacy@docai.app\n**Response time** Maximum 48 hours.\n**Data Protection Officer** Available for specific consultations.\n**Live chat** Immediate support during business hours.\n\nOur privacy team is specialized in answering all your personal data concerns.';

  @override
  String get reportSecurityIssues => 'Report Security Issues';

  @override
  String get reportSecurityIssuesDescription =>
      'If you discover a security issue, contact us immediately:\n\n**Security email** security@docai.app\n**Bug bounty program** Rewards for vulnerability discoveries.\n**Responsible disclosure** Established process for reporting issues.\n**Guaranteed response** Confirmation in less than 24 hours.\n\nYour help in keeping DocAI secure is invaluable and always recognized.';
}
