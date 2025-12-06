import 'dart:io';
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _localePrefKey = 'selected_locale';
  Locale? _locale;

  Locale? get locale => _locale;

  void updateLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    if (!Platform.isWindows) {
      FirebaseAnalytics.instance.logEvent(
        name: 'change_language',
        parameters: {'language_code': locale.languageCode},
      );
    }
    notifyListeners();
    unawaited(_persistLocale(locale));
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_localePrefKey);
    if (savedLanguageCode == null || savedLanguageCode.isEmpty) {
      return;
    }

    final savedLocale = Locale(savedLanguageCode);
    if (_locale == savedLocale) {
      return;
    }

    _locale = savedLocale;
    notifyListeners();
  }

  Future<void> _persistLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, locale.languageCode);
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    required LocaleController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found in context');
    return scope!.notifier!;
  }
}
