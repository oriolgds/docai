import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final WebViewController _webController;
  WebViewController? _popupController;
  bool _isLoading = true;
  bool _showPopupModal = false;
  String _popupUrl = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webController = WebViewController.fromPlatformCreationParams(params);

    // Configuración específica para Android
    if (_webController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Configurar manejo de cookies y localStorage
            _setupBrowserFeatures();
          },
          onWebResourceError: (WebResourceError error) {
            print('Error cargando página: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Detectar si es una ventana emergente o verificación
            if (_isPopupUrl(request.url)) {
              _showPopup(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'PopupHandler',
        onMessageReceived: (JavaScriptMessage message) {
          // Manejar mensajes de JavaScript para detectar popups
          final data = message.message;
          if (data.startsWith('popup:')) {
            final url = data.substring(6);
            _showPopup(url);
          } else if (data == 'popup:close') {
            _closePopup();
          }
        },
      )
      ..loadRequest(
        Uri.parse('https://docai.is-best.net/gaia/?i=1'),
      );

    // Inyectar JavaScript para manejar window.open
    _injectPopupHandler();
  }

  bool _isPopupUrl(String url) {
    // Detectar URLs que son típicamente ventanas de verificación
    final popupPatterns = [
      'auth',
      'verify',
      'login',
      'oauth',
      'popup',
      'verification',
      'puter.js',
    ];
    
    return popupPatterns.any((pattern) => 
      url.toLowerCase().contains(pattern)) ||
      url != 'https://docai.is-best.net/gaia/?i=1';
  }

  void _injectPopupHandler() {
    // Inyectar JavaScript para interceptar window.open
    const script = '''
      (function() {
        const originalOpen = window.open;
        window.open = function(url, name, specs) {
          // Enviar mensaje a Flutter en lugar de abrir nueva ventana
          if (window.PopupHandler) {
            window.PopupHandler.postMessage('popup:' + url);
          }
          return null;
        };
        
        // Interceptar eventos de Puter.js
        document.addEventListener('DOMContentLoaded', function() {
          // Buscar elementos que puedan trigger popups
          const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
              mutation.addedNodes.forEach(function(node) {
                if (node.nodeType === 1) { // Element node
                  // Verificar si es un iframe o elemento de verificación
                  if (node.tagName === 'IFRAME' || 
                      node.className.includes('verification') ||
                      node.className.includes('auth')) {
                    if (window.PopupHandler) {
                      window.PopupHandler.postMessage('popup:' + (node.src || window.location.href));
                    }
                  }
                }
              });
            });
          });
          
          observer.observe(document.body, {
            childList: true,
            subtree: true
          });
        });
      })();
    ''';

    _webController.runJavaScript(script);
  }

  void _setupBrowserFeatures() {
    // Configurar características del navegador para persistir cookies
    const cookieScript = '''
      // Configurar almacenamiento persistente
      if (typeof(Storage) !== "undefined") {
        // Guardar estado de autenticación
        const saveAuthState = () => {
          const authData = {
            timestamp: Date.now(),
            cookies: document.cookie,
            localStorage: JSON.stringify(localStorage)
          };
          sessionStorage.setItem('docai_auth', JSON.stringify(authData));
        };
        
        // Restaurar estado si existe
        const restoreAuthState = () => {
          const saved = sessionStorage.getItem('docai_auth');
          if (saved) {
            const authData = JSON.parse(saved);
            // Las cookies se restauran automáticamente
            // localStorage se maneja automáticamente por el WebView
          }
        };
        
        restoreAuthState();
        
        // Guardar estado periódicamente
        setInterval(saveAuthState, 5000);
        
        // Guardar al cerrar
        window.addEventListener('beforeunload', saveAuthState);
      }
    ''';

    _webController.runJavaScript(cookieScript);
  }

  void _showPopup(String url) {
    setState(() {
      _popupUrl = url;
      _showPopupModal = true;
    });

    // Crear controlador para el popup
    _createPopupController(url);

    // Auto-cerrar después de verificación (simulamos el comportamiento del navegador)
    Future.delayed(const Duration(seconds: 5), () {
      if (_showPopupModal) {
        _checkAndClosePopup();
      }
    });
  }

  void _createPopupController(String url) {
    late final PlatformWebViewControllerCreationParams params;
    
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _popupController = WebViewController.fromPlatformCreationParams(params);

    _popupController!
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String finishedUrl) {
            // Verificar si la página de verificación ha terminado
            _checkVerificationComplete(finishedUrl);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _checkVerificationComplete(String url) {
    // Verificar si la verificación está completa
    const checkScript = '''
      (function() {
        // Buscar indicadores de verificación completa
        const indicators = [
          'success', 'complete', 'verified', 'authenticated',
          'done', 'finished', 'close'
        ];
        
        const bodyText = document.body.innerText.toLowerCase();
        const hasCompleteIndicator = indicators.some(indicator => 
          bodyText.includes(indicator)
        );
        
        // También verificar si la página está intentando cerrarse
        const hasCloseScript = document.querySelector('script[src*="close"]') ||
          document.body.innerHTML.includes('window.close') ||
          document.body.innerHTML.includes('self.close');
        
        return hasCompleteIndicator || hasCloseScript;
      })();
    ''';

    _popupController?.runJavaScriptReturningResult(checkScript).then((result) {
      if (result.toString() == 'true') {
        Future.delayed(const Duration(seconds: 2), () {
          _closePopup();
        });
      }
    });
  }

  void _checkAndClosePopup() {
    if (_popupController != null) {
      _checkVerificationComplete(_popupUrl);
    } else {
      _closePopup();
    }
  }

  void _closePopup() {
    setState(() {
      _showPopupModal = false;
      _popupController = null;
      _popupUrl = '';
    });

    // Recargar la página principal para que reconozca la nueva autenticación
    _webController.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocAI Gaia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webController.reload(),
            tooltip: 'Recargar',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearCookiesAndReload,
            tooltip: 'Limpiar datos',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webController),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando Gaia...'),
                  ],
                ),
              ),
            ),
          
          // Modal para popup de verificación
          if (_showPopupModal)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Header del modal
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2196F3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.security,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Verificación de seguridad',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: _closePopup,
                            ),
                          ],
                        ),
                      ),
                      
                      // Contenido del popup
                      Expanded(
                        child: _popupController != null
                            ? WebViewWidget(controller: _popupController!)
                            : const Center(
                                child: CircularProgressIndicator(),
                              ),
                      ),
                      
                      // Footer con información
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Esta ventana se cerrará automáticamente',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _closePopup,
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _clearCookiesAndReload() {
    // Limpiar cookies y datos almacenados
    _webController.clearCache();
    _webController.clearLocalStorage();
    
    const clearScript = '''
      // Limpiar cookies
      document.cookie.split(";").forEach(function(c) { 
        document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/"); 
      });
      
      // Limpiar localStorage y sessionStorage
      localStorage.clear();
      sessionStorage.clear();
    ''';
    
    _webController.runJavaScript(clearScript).then((_) {
      _webController.reload();
    });
  }

  @override
  void dispose() {
    _popupController = null;
    super.dispose();
  }
}
