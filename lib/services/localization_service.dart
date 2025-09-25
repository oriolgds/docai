import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageCodeKey = 'language_code';
  static const String _countryCodeKey = 'country_code';
  
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
  ];
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
  };
  
  // Get the current saved locale from SharedPreferences
  static Future<Locale?> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);
    
    if (languageCode != null) {
      final countryCode = prefs.getString(_countryCodeKey);
      return Locale(languageCode, countryCode);
    }
    
    return null;
  }
  
  // Save the locale to SharedPreferences
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    
    if (locale.countryCode != null) {
      await prefs.setString(_countryCodeKey, locale.countryCode!);
    } else {
      await prefs.remove(_countryCodeKey);
    }
  }
  
  // Clear saved locale
  static Future<void> clearSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageCodeKey);
    await prefs.remove(_countryCodeKey);
  }
  
  // Get the device's locale if supported, otherwise return fallback
  static Locale getFallbackLocale(Locale? deviceLocale) {
    if (deviceLocale != null) {
      // Check if device locale is supported
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == deviceLocale.languageCode) {
          return supportedLocale;
        }
      }
    }
    
    // Return default locale (English)
    return supportedLocales.first;
  }
  
  // Get display name for a language code
  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
}