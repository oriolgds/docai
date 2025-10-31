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
  String get menuReload => 'Reload';

  @override
  String get newWindowTitle => 'New window';

  @override
  String get loadingLabel => 'Loading...';
}
