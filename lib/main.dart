import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/state/locale_scope.dart';
import 'package:docai/state/theme_scope.dart';
import 'package:docai/state/settings_scope.dart';
import 'package:docai/screens/native_chat_screen.dart';
import 'package:docai/screens/splash_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:docai/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:docai/services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timeago locales for all supported languages
  timeago.setLocaleMessages('es', timeago.EsMessages());
  timeago.setLocaleMessages('ca', timeago.CaMessages());
  timeago.setLocaleMessages('de', timeago.DeMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());

  runApp(const DocAIAppWrapper());
}

class DocAIAppWrapper extends StatefulWidget {
  const DocAIAppWrapper({super.key});

  @override
  State<DocAIAppWrapper> createState() => _DocAIAppWrapperState();
}

class _DocAIAppWrapperState extends State<DocAIAppWrapper> {
  bool _isInitialized = false;
  LocaleController? _localeController;
  ThemeController? _themeController;
  SettingsController? _settingsController;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Perform all initialization tasks
    try {
      if (!Platform.isWindows) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        if (kDebugMode) {
          // Disable Crashlytics collection in debug mode
          await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
            false,
          );
        } else {
          // Enable Crashlytics collection in non-debug modes
          await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
            true,
          );

          // Pass all uncaught "fatal" errors from the framework to Crashlytics
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterFatalError;

          // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
          PlatformDispatcher.instance.onError = (error, stack) {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
            return true;
          };
        }

        // Set user ID for analytics to ensure consistent user tracking
        try {
          final firestoreService = FirestoreService();
          final userId = await firestoreService.getUserId();
          await FirebaseAnalytics.instance.setUserId(id: userId);
        } catch (e) {
          debugPrint("Failed to set analytics user ID: $e");
        }
      } else {
        // Attempt to initialize Firebase Core on Windows if configured,
        // but skip Crashlytics as it is not supported.
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ).timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint(
            "Firebase initialization failed on Windows (likely missing configuration): $e",
          );
        }
      }
    } catch (e) {
      debugPrint("Firebase initialization failed: $e");
    }

    try {
      final localeController = LocaleController();
      await localeController.loadSavedLocale();

      final themeController = ThemeController();
      await themeController.loadSavedThemeMode();

      final settingsController = SettingsController();
      await settingsController.loadSettings();

      // Update state to transition from splash screen
      if (mounted) {
        setState(() {
          _localeController = localeController;
          _themeController = themeController;
          _settingsController = settingsController;
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Critical initialization failed: $e");
      // Even if critical init fails, we should probably try to show the app or an error screen
      // For now, let's just try to set initialized to true to avoid stuck splash
      if (mounted) {
        setState(() {
          _isInitialized = true;
          // Fallback controllers if loading failed
          _localeController = LocaleController();
          _themeController = ThemeController();
          _settingsController = SettingsController();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a basic MaterialApp with splash screen while initializing
    if (!_isInitialized ||
        _localeController == null ||
        _themeController == null ||
        _settingsController == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
            surface: const Color(0xFF121212),
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          useMaterial3: true,
        ),
        home: SplashScreen(
          onInitializationComplete: () {
            // This callback is for future use if needed
          },
        ),
      );
    }

    // Once initialized, show the full app
    return SettingsScope(
      controller: _settingsController!,
      child: LocaleScope(
        controller: _localeController!,
        child: ThemeScope(controller: _themeController!, child: const DocAIApp()),
      ),
    );
  }
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
