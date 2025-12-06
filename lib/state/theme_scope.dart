import 'dart:io';
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _themePrefKey = 'selected_theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void updateThemeMode(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;
    if (!Platform.isWindows) {
      FirebaseAnalytics.instance.logEvent(
        name: 'change_theme',
        parameters: {'theme_mode': mode.toString()},
      );
    }
    notifyListeners();
    unawaited(_persistThemeMode(mode));
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.system) {
      updateThemeMode(ThemeMode.light);
    } else if (_themeMode == ThemeMode.light) {
      updateThemeMode(ThemeMode.dark);
    } else {
      updateThemeMode(ThemeMode.system);
    }
  }

  Future<void> loadSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeModeString = prefs.getString(_themePrefKey);
    if (savedThemeModeString == null || savedThemeModeString.isEmpty) {
      return;
    }

    final savedThemeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == savedThemeModeString,
      orElse: () => ThemeMode.system,
    );

    if (_themeMode == savedThemeMode) {
      return;
    }

    _themeMode = savedThemeMode;
    notifyListeners();
  }

  Future<void> _persistThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, mode.toString());
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    required ThemeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope not found in context');
    return scope!.notifier!;
  }
}
