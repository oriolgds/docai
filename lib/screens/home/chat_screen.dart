import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final WebViewController _webController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Inject JavaScript after page loads
            _injectJavaScript();
          },
          onHttpError: (HttpResponseError error) {
            print('HTTP error: ${error.response?.statusCode}');
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation request: ${request.url}');

            // Handle external URLs or verification pages
            if (_shouldOpenExternally(request.url)) {
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      // Add JavaScript handlers
      ..addJavaScriptChannel(
        'FlutterApp',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..loadRequest(
        Uri.parse('https://docai.is-best.net/gaia/'));
  }

  bool _shouldOpenExternally(String url) {
    // Define patterns that should open externally
    return url.contains('verification') ||
        url.contains('auth') ||
        url.contains('login') ||
        url.contains('oauth') ||
        !url.startsWith('https://docai.is-best.net');
  }

  void _handleJavaScriptMessage(String message) {
    print('JavaScript message: $message');

    if (message.startsWith('OPEN_EXTERNAL:')) {
      final url = message.substring('OPEN_EXTERNAL:'.length);
      _launchExternalUrl(url);
    } else if (message == 'VERIFICATION_COMPLETED') {
      // Handle verification completion
      _webController.reload();
    }
  }

  void _injectJavaScript() {
    _webController.runJavaScript('''
    console.log('DocAI: Injecting JavaScript handlers');
    
    // Store original window.open
    window.originalOpen = window.open;
    
    // Override window.open to handle new window requests
    window.open = function(url, name, specs) {
      console.log('DocAI: Attempting to open:', url);
      
      // If it's a verification URL, send message to Flutter
      if (url && (url.includes('verification') || 
                 url.includes('auth') || 
                 url.includes('login') ||
                 url.includes('oauth'))) {
        
        window.FlutterApp.postMessage('OPEN_EXTERNAL:' + url);
        
        // Return a mock window object to prevent errors
        return {
          closed: false,
          close: function() { this.closed = true; },
          focus: function() {},
          blur: function() {}
        };
      }
      
      // For same-origin URLs, navigate in current window
      if (url && url.startsWith(window.location.origin)) {
        window.location.href = url;
        return null;
      }
      
      // For other external URLs
      if (url) {
        window.FlutterApp.postMessage('OPEN_EXTERNAL:' + url);
      }
      
      return null;
    };
    
    // Handle Puter.js specific events if available
    if (typeof window.puter !== 'undefined') {
      console.log('DocAI: Puter.js detected, setting up handlers');
      
      // Listen for authentication events
      document.addEventListener('puter-auth-required', function(event) {
        console.log('DocAI: Puter auth required:', event.detail);
      });
      
      // Listen for verification events
      document.addEventListener('puter-verification', function(event) {
        console.log('DocAI: Puter verification:', event.detail);
        if (event.detail && event.detail.url) {
          window.FlutterApp.postMessage('OPEN_EXTERNAL:' + event.detail.url);
        }
      });
    }
    
    // REMOVIDO: No más preventDefault en beforeunload
    // Esto eliminará el popup de confirmación al recargar
    window.addEventListener('beforeunload', function(e) {
      console.log('DocAI: Page unloading - allowing normal reload');
      // No llamamos e.preventDefault() ni return ''
      // Esto permite recargas sin popup de confirmación
    });
    
    // Listen for focus events to detect when user returns from external verification
    window.addEventListener('focus', function() {
      console.log('DocAI: Window focused - user may have returned from verification');
      // Check if verification was completed
      setTimeout(function() {
        if (typeof window.puter !== 'undefined' && window.puter.auth && window.puter.auth.isAuthenticated) {
          window.FlutterApp.postMessage('VERIFICATION_COMPLETED');
        }
      }, 1000);
    });
    
    // Disable any existing beforeunload handlers that might cause popups
    window.onbeforeunload = null;
    
    // Override any attempts to set beforeunload handlers
    Object.defineProperty(window, 'onbeforeunload', {
      set: function(fn) {
        console.log('DocAI: Prevented setting onbeforeunload handler');
        // No asignar el handler para evitar popups
      },
      get: function() {
        return null;
      }
    });
    
    console.log('DocAI: JavaScript injection completed - reload popups disabled');
  ''');
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Show verification dialog
        if (mounted) {
          _showVerificationDialog();
        }
      } else {
        print('Could not launch URL: $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verificación de Dispositivo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.security, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Se ha abierto una ventana externa para verificar tu dispositivo. '
              'Una vez completada la verificación, regresa a la aplicación y presiona "Continuar".',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reload the WebView to refresh the session
              _webController.reload();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showReloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Recargar Chat?'),
        content: const Text(
          '¿Deseas recargar el chat? Esto puede ayudar si hay problemas de conexión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _webController.reload();
            },
            child: const Text('Recargar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocAI Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showReloadDialog,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Si experimentas pantallas azules, presiona el botón de recarga.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webController),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando DocAI Chat...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
