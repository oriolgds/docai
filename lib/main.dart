import 'package:flutter/material.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/state/locale_scope.dart';
import 'package:docai/state/theme_scope.dart';
import 'package:docai/screens/native_chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:docai/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timeago locales for all supported languages
  timeago.setLocaleMessages('es', timeago.EsMessages());
  timeago.setLocaleMessages('ca', timeago.CaMessages());
  timeago.setLocaleMessages('de', timeago.DeMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final localeController = LocaleController();
  await localeController.loadSavedLocale();

  final themeController = ThemeController();
  await themeController.loadSavedThemeMode();

  runApp(
    LocaleScope(
      controller: localeController,
      child: ThemeScope(controller: themeController, child: const DocAIApp()),
    ),
  );
}

class DocAIApp extends StatelessWidget {
  const DocAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = LocaleScope.of(context);
    final themeController = ThemeScope.of(context);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
          surface: const Color(0xFF121212), // Explicit dark surface
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      themeMode: themeController.themeMode,
      locale: localeController.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const NativeChatScreen(),
    );
  }
}
