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
import 'screens/splash/splash_screen.dart';
import 'services/supabase_service.dart';
import 'services/localization_service.dart';
import 'services/remote_config_service.dart';
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
  
  // Initialize Remote Config
  await RemoteConfigService.initialize();
  
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
  bool _isInitialized = false;
  bool _isHandlingDeepLink = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Initialize locale
    await _initializeLocale();
    
    // Setup listeners
    _setupAuthListener();
    _setupDeepLinks();
    
    // Mark as initialized
    setState(() {
      _isInitialized = true;
    });
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
      _handleDeepLink(uri);
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (_isHandlingDeepLink) return;
    _isHandlingDeepLink = true;

    try {
      debugPrint('Handling deep link: $uri');
      
      // Handle email verification deep links
      if (uri.host == 'email-verified' || uri.path.contains('email-verified')) {
        await _handleEmailVerificationLink(uri);
      }
      // Handle auth callback deep links from Supabase
      else if (uri.fragment.contains('access_token') || uri.fragment.contains('refresh_token')) {
        await _handleAuthCallback(uri);
      }
      // Handle generic auth deep links
      else if (uri.host == 'auth' || uri.path.contains('auth')) {
        await _handleAuthLink(uri);
      }
      // Handle login deep links
      else if (uri.host == 'login' || uri.path.contains('login')) {
        await _handleLoginLink();
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
      // On error, just refresh current state
      await _refreshAuthState();
    } finally {
      _isHandlingDeepLink = false;
    }
  }

  Future<void> _handleEmailVerificationLink(Uri uri) async {
    // For email verification, always redirect to login screen
    // so users can log in with their now-verified account
    try {
      // Show a message that email is verified and redirect to login
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
      
      // Show a snackbar to inform the user
      Future.delayed(const Duration(milliseconds: 500), () {
        final scaffoldMessenger = ScaffoldMessenger.of(_navigatorKey.currentContext!);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully! Please log in to continue.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      });
    } catch (e) {
      debugPrint('Error handling email verification link: $e');
      // Fallback to login screen
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleAuthCallback(Uri uri) async {
    // Handle Supabase auth callback with tokens
    try {
      // Extract tokens from fragment
      final fragment = uri.fragment;
      final params = Uri.splitQueryString(fragment);
      
      if (params.containsKey('access_token') && params.containsKey('refresh_token')) {
        // Let Supabase handle the session
        await SupabaseService.client.auth.getSessionFromUrl(uri);
        
        // Check if user is now authenticated and verified  
        final user = SupabaseService.currentUser;
        if (user != null) {
          if (user.emailConfirmedAt != null) {
            // User is verified, go to dashboard
            _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          } else {
            // User exists but email not verified, redirect to login
            _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        } else {
          // No user found, redirect to login
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling auth callback: $e');
      // On error, redirect to login
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleAuthLink(Uri uri) async {
    // Handle generic auth deep links
    try {
      // Refresh session to get latest auth state
      await SupabaseService.client.auth.refreshSession();
      final user = SupabaseService.currentUser;
      
      if (user != null && user.emailConfirmedAt != null) {
        // User is authenticated and verified
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else {
        // No authenticated user or email not verified, go to login
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error handling auth link: $e');
      // On error, redirect to login
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleLoginLink() async {
    // Handle login deep links
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _refreshAuthState() async {
    try {
      await SupabaseService.client.auth.refreshSession();
      final user = SupabaseService.currentUser;
      
      Widget destination;
      if (user != null && user.emailConfirmedAt != null) {
        destination = const DashboardScreen();
      } else {
        destination = const LoginScreen();
      }
      
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => destination),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error refreshing auth state: $e');
      // On error, default to login
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _setupAuthListener() {
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      final user = session?.user;
      
      debugPrint('Auth state changed: $event, user: ${user?.email}');
      
      if (event == AuthChangeEvent.signedOut && _isInitialized) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else if (event == AuthChangeEvent.signedIn && user != null && _isInitialized) {
        // User signed in, check if email is verified
        if (user.emailConfirmedAt != null) {
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        }
      } else if (event == AuthChangeEvent.tokenRefreshed && user == null && _isInitialized) {
        // Token refreshed but no user, redirect to login
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocAI',
      theme: AppTheme.theme,
      navigatorKey: _navigatorKey,
      home: _isInitialized ? const SplashScreen() : const _InitializingScreen(),
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
}

// Simple initialization screen shown during initial setup
class _InitializingScreen extends StatelessWidget {
  const _InitializingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 2,
        ),
      ),
    );
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