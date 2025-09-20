import 'dart:async';
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
  Timer? _popupCloseTimer;

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

    if (_webController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => setState(() => _isLoading = true),
          onPageFinished: (String url) => setState(() => _isLoading = false),
          onWebResourceError: (WebResourceError error) {
            // Ignoramos el error ORB ya que es esperado y manejado.
            if (error.errorCode != -24) {
              // net::ERR_BLOCKED_BY_ORB en Android
              print('Error en WebView: ${error.description}');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
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
          if (message.message.startsWith('popup:')) {
            final url = message.message.substring(6);
            _showPopup(url);
          }
        },
      )
      ..loadRequest(Uri.parse('https://docai-508.pages.dev/gaia/'));

    _injectWindowOpenInterceptor();
  }

  void _injectWindowOpenInterceptor() {
    const script = '''
      (function() {
        window.open = function(url, name, specs) {
          if (window.PopupHandler && url) {
            window.PopupHandler.postMessage('popup:' + url);
          }
          return null;
        };
      })();
    ''';
    _webController.runJavaScript(script);
  }

  bool _isPopupUrl(String url) {
    final popupPatterns = ['auth', 'verify', 'login', 'oauth', 'puter.js'];
    final mainUri = Uri.parse('https://docai-508.pages.dev/gaia/');
    final requestUri = Uri.parse(url);

    if (requestUri.host == mainUri.host && requestUri.path == mainUri.path) {
      return false;
    }
    return popupPatterns.any((pattern) => url.toLowerCase().contains(pattern));
  }

  void _showPopup(String url) {
    setState(() {
      _showPopupModal = true;
    });

    // Inicia un temporizador de seguridad para cerrar el popup después de 45 segundos.
    _popupCloseTimer?.cancel();
    _popupCloseTimer = Timer(const Duration(seconds: 45), () {
      if (_showPopupModal) {
        _closePopup();
      }
    });

    _createPopupController(url);
  }

  void _createPopupController(String url) {
    late final PlatformWebViewControllerCreationParams params;
    params = const PlatformWebViewControllerCreationParams();

    _popupController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String finishedUrl) async {
            // Detectamos if url es about:blank o similar
            if (finishedUrl == 'about:blank' || finishedUrl.trim().isEmpty) {
              _closePopup();
              return;
            }

            try {
              // Ejecutamos JS para obtener el contenido visible del body y ver si está vacio
              final content = await _popupController!
                  .runJavaScriptReturningResult(
                    "document.body.innerText.trim()",
                  );
              if (content == null || content.toString().isEmpty) {
                // Página está vacía: cerramos popup automáticamente
                _closePopup();
                return;
              }
            } catch (e) {
              // Error leyendo JS: posible restricción, no cerramos para no interferir
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final mainAppUrl = Uri.parse('https://docai-508.pages.dev/gaia/');
            final requestUrl = Uri.parse(request.url);

            // If the popup tries to navigate back to main app URL, close modal.
            if (requestUrl.host == mainAppUrl.host &&
                requestUrl.path == mainAppUrl.path) {
              _closePopup();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _closePopup() {
    _popupCloseTimer
        ?.cancel(); // Cancela el temporizador si cerramos manualmente
    if (mounted && _showPopupModal) {
      setState(() {
        _showPopupModal = false;
        _popupController = null;
      });
      // MUY IMPORTANTE: Recargar la página principal para que reconozca la nueva sesión.
      _webController.reload();
    }
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
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webController),

          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),

          if (_showPopupModal)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Completando verificación...',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _popupController != null
                            ? WebViewWidget(controller: _popupController!)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            const Text(
                              "Una vez completada la verificación, pulsa 'Hecho' para continuar.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Hecho'),
                                onPressed: _closePopup,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
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

  @override
  void dispose() {
    _popupCloseTimer?.cancel();
    _popupController = null;
    super.dispose();
  }
}
