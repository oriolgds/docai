// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'DocAI';

  @override
  String get chatTitle => 'Chat';

  @override
  String get menuHome => 'Accueil';

  @override
  String get menuReload => 'Recharger';

  @override
  String get newWindowTitle => 'Nouvelle fenêtre';

  @override
  String get loadingLabel => 'Chargement...';
}
