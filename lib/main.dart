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
      debugPrint('Deep link host: ${uri.host}');
      debugPrint('Deep link path: ${uri.path}');
      debugPrint('Deep link fragment: ${uri.fragment}');
      debugPrint('Deep link query: ${uri.query}');
      
      // Check for OAuth tokens or PKCE code
      // Tokens can be in fragment (#) or query (?)
      final hasTokensInFragment = uri.fragment.contains('access_token') || 
                                   uri.fragment.contains('refresh_token');
      final hasTokensInQuery = uri.query.contains('access_token') ||
                               uri.query.contains('refresh_token');
      final hasPKCECode = uri.query.contains('code=');
      
      // Handle OAuth callback (with tokens or PKCE code)
      if (hasTokensInFragment || hasTokensInQuery || hasPKCECode) {
        debugPrint('OAuth/Auth callback detected (tokens or code found)');
        await _handleAuthCallback(uri);
      }
      // Handle generic auth deep links (fallback for auth host without tokens)
      else if (uri.host == 'auth' || uri.path.contains('auth')) {
        debugPrint('Generic auth link detected - checking session');
        await _handleAuthLink(uri);
      }
      // Handle login deep links
      else if (uri.host == 'login' || uri.path.contains('login')) {
        debugPrint('Login link detected');
        await _handleLoginLink();
      }
      else {
        debugPrint('Unknown deep link type - refreshing auth state');
        await _refreshAuthState();
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
      // On error, just refresh current state
      await _refreshAuthState();
    } finally {
      _isHandlingDeepLink = false;
    }
  }

  Future<void> _handleAuthCallback(Uri uri) async {
    // Handle Supabase auth callback with tokens (OAuth flow)
    try {
      debugPrint('Handling OAuth callback...');
      
      // Try to get session from URL (handles both fragment and query params)
      await SupabaseService.client.auth.getSessionFromUrl(uri);
      debugPrint('Session established from URL');
      
      // Small delay to ensure session is fully established
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if user is now authenticated
      final user = SupabaseService.currentUser;
      debugPrint('Current user after OAuth: ${user?.email}');
      
      if (user != null) {
        // OAuth providers (GitHub, Discord, Google) don't require email verification
        // They're already verified by the OAuth provider
        final provider = user.appMetadata['provider'] as String?;
        debugPrint('User provider: $provider');
        
        // For OAuth providers, go directly to dashboard (no message needed)
        if (provider == 'github' || provider == 'discord' || provider == 'google') {
          debugPrint('OAuth provider detected, navigating to dashboard');
          // Navigate silently without any snackbar
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        } else if (user.emailConfirmedAt != null) {
          // Email/password user with verified email
          debugPrint('Email verified, navigating to dashboard');
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        } else {
          // Email/password user without verification
          debugPrint('Email not verified, staying on login');
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } else {
        debugPrint('No user found after OAuth callback');
        // No user found, redirect to login
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
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
        // User signed in, check provider and email verification
        final provider = user.appMetadata['provider'] as String?;
        
        // OAuth providers (GitHub, Discord, Google) are pre-verified
        if (provider == 'github' || provider == 'discord' || provider == 'google') {
          debugPrint('OAuth sign-in detected, navigating to dashboard');
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        } else if (user.emailConfirmedAt != null) {
          // Email/password user with verified email
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