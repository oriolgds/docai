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
