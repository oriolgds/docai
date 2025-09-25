import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/auth/email_verified_screen.dart';
import 'services/supabase_service.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(const DocAIApp());
}

class DocAIApp extends StatefulWidget {
  const DocAIApp({super.key});

  @override
  State<DocAIApp> createState() => _DocAIAppState();
}

class _DocAIAppState extends State<DocAIApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _setupDeepLinks();
  }

  void _setupDeepLinks() {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      if (uri.host == 'email-verified') {
        final user = SupabaseService.currentUser;
        if (user?.emailConfirmedAt != null) {
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const EmailVerifiedScreen()),
            (route) => false,
          );
        }
      }
    });
  }

  void _setupAuthListener() {
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut || event == AuthChangeEvent.tokenRefreshed) {
        final user = SupabaseService.currentUser;
        if (user == null) {
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocAI',
      theme: AppTheme.theme,
      navigatorKey: _navigatorKey,
      home: _getInitialScreen(),
      debugShowCheckedModeBanner: false,
      // Localization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      // Optionally set the locale resolution callback
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
    );
  }
  
  Widget _getInitialScreen() {
    final user = SupabaseService.currentUser;
    if (user != null && user.emailConfirmedAt != null) {
      return const DashboardScreen();
    }
    return const LoginScreen();
  }
}