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
import 'services/localization_service.dart';
import 'l10n/generated/app_localizations.dart';
import 'widgets/android_download_modal.dart';

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
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _setupAuthListener();
    _setupDeepLinks();
  }
  
  Future<void> _initializeLocale() async {
    final savedLocale = await LocalizationService.getSavedLocale();
    if (savedLocale != null) {
      setState(() {
        _currentLocale = savedLocale;
      });
    }
  }
  
  void _changeLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
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
      home: AndroidDownloadWrapper(
        child: _getInitialScreen(),
      ),
      debugShowCheckedModeBanner: false,
      // Localization configuration
      locale: _currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      // Locale resolution callback
      localeResolutionCallback: (locale, supportedLocales) {
        // If we have a saved locale, use it
        if (_currentLocale != null) {
          return _currentLocale;
        }
        
        // Otherwise, check if the current device locale is supported
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      // Pass the locale change callback down to the app
      builder: (context, child) {
        return LocaleProvider(
          onLocaleChanged: _changeLocale,
          child: child!,
        );
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

// Provider to pass locale change callback through the widget tree
class LocaleProvider extends InheritedWidget {
  final Function(Locale) onLocaleChanged;
  
  const LocaleProvider({
    super.key,
    required this.onLocaleChanged,
    required super.child,
  });
  
  static LocaleProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleProvider>();
  }
  
  @override
  bool updateShouldNotify(LocaleProvider oldWidget) {
    return onLocaleChanged != oldWidget.onLocaleChanged;
  }
}