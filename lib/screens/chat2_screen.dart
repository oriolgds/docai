import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/screens/info_screen.dart';
import 'package:docai/state/locale_scope.dart';

class Chat2Screen extends StatefulWidget {
  const Chat2Screen({super.key});

  @override
  State<Chat2Screen> createState() => _Chat2ScreenState();
}

class _Chat2ScreenState extends State<Chat2Screen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  static const String _homeUrl = 'https://docai-chat.pages.dev/';
  String _currentUrl = _homeUrl;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isShowingOfflineFallback = false;
  LocaleController? _localeController;

  final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone; geolocation",
    iframeAllowFullscreen: true,
    disableVerticalScroll: false,
    disableHorizontalScroll: false,
    verticalScrollBarEnabled: true,
    horizontalScrollBarEnabled: true,
  );

  Route<void> _buildInfoRoute() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const InfoScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureLocaleListener();

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.chatTitle,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: _progress < 1.0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : null,
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _canGoBack ? Colors.black : Colors.grey,
              ),
              onPressed: _canGoBack
                  ? () async {
                      setState(() {
                        _isLoading = true;
                        _hasError = false;
                        _isShowingOfflineFallback = false;
                        _progress = 0;
                      });
                      await _webViewController?.goBack();
                    }
                  : null,
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: _canGoForward ? Colors.black : Colors.grey,
              ),
              onPressed: _canGoForward
                  ? () async {
                      setState(() {
                        _isLoading = true;
                        _hasError = false;
                        _isShowingOfflineFallback = false;
                        _progress = 0;
                      });
                      await _webViewController?.goForward();
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              tooltip: AppLocalizations.of(context)!.menuHome,
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                  _currentUrl = _homeUrl;
                  _hasError = false;
                  _isShowingOfflineFallback = false;
                  _progress = 0;
                });
                await _webViewController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(_homeUrl)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              tooltip: AppLocalizations.of(context)!.menuReload,
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _isShowingOfflineFallback = false;
                  _progress = 0;
                });
                await _webViewController?.reload();
              },
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.menuMoreInfo,
              icon: const Icon(Icons.info_outline, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(_buildInfoRoute());
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Visibility(
              visible: !_hasError,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
                initialSettings: _settings,
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                  _postLocaleToWeb();
                },
                onLoadStart: (controller, url) {
                  if (_isShowingOfflineFallback) {
                    return;
                  }
                  setState(() {
                    _currentUrl = url.toString();
                    _isLoading = true;
                    _hasError = false;
                    _progress = 0;
                  });
                },
                onLoadStop: (controller, url) async {
                  if (_isShowingOfflineFallback) {
                    return;
                  }
                  setState(() {
                    _currentUrl = url.toString();
                    _isLoading = false;
                    _hasError = false;
                    _progress = 1;
                  });
                  _updateNavigationButtons();
                  _postLocaleToWeb();
                },
                onProgressChanged: (controller, progress) {
                  if (_isShowingOfflineFallback) {
                    return;
                  }
                  setState(() {
                    _progress = progress / 100;
                  });
                },
                onReceivedError: (controller, request, error) async {
                  if (!mounted || request.isForMainFrame == false) {
                    return;
                  }
                  await controller.loadData(data: '<html></html>');
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _progress = 0;
                    _isShowingOfflineFallback = true;
                  });
                },
                onReceivedHttpError: (controller, request, response) async {
                  if (!mounted || request.isForMainFrame == false) {
                    return;
                  }
                  await controller.loadData(data: '<html></html>');
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _progress = 0;
                    _isShowingOfflineFallback = true;
                  });
                },
                onUpdateVisitedHistory: (controller, url, isReload) {
                  _updateNavigationButtons();
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url;
                  if (navigationAction.isForMainFrame == false) {
                    return NavigationActionPolicy.ALLOW;
                  }
                  if (uri != null && uri.toString().startsWith('http')) {
                    return NavigationActionPolicy.ALLOW;
                  }
                  return NavigationActionPolicy.CANCEL;
                },
                onCreateWindow: (controller, createWindowAction) async {
                  bool popupClosed = false;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      final mediaQuery = MediaQuery.of(dialogContext);
                      final dialogWidth = math.min(
                        mediaQuery.size.width * 0.9,
                        720.0,
                      );
                      final dialogHeight = mediaQuery.size.height * 0.8;

                      return PopScope(
                        canPop: true,
                        onPopInvokedWithResult: (didPop, result) {
                          if (!popupClosed) {
                            popupClosed = true;
                          }
                        },
                        child: Dialog(
                          child: SizedBox(
                            width: dialogWidth,
                            height: dialogHeight,
                            child: Column(
                              children: [
                                AppBar(
                                  backgroundColor: Colors.white,
                                  elevation: 1,
                                  leading: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      popupClosed = true;
                                      Navigator.pop(dialogContext);
                                    },
                                  ),
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.newWindowTitle,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InAppWebView(
                                    windowId: createWindowAction.windowId,
                                    initialSettings: _settings,
                                    shouldOverrideUrlLoading:
                                        (controller, navigationAction) async {
                                          return NavigationActionPolicy.ALLOW;
                                        },
                                    onLoadStop: (controller, url) async {
                                      if (popupClosed) return;

                                      // Esperar un momento y verificar el estado
                                      await Future.delayed(
                                        const Duration(milliseconds: 500),
                                      );

                                      try {
                                        // Verificar si la ventana debe cerrarse
                                        final result = await controller
                                            .evaluateJavascript(
                                              source: '''
                            (function() {
                              // Verificar si hay contenido o está vacío
                              const body = document.body;
                              const isEmpty = !body || body.innerText.trim().length < 10;
                              const hasCloseIndicator = body && body.innerText.toLowerCase().includes('success');
                              return isEmpty || hasCloseIndicator;
                            })();
                          ''',
                                            );

                                        if (result == true && !popupClosed) {
                                          popupClosed = true;
                                          if (dialogContext.mounted) {
                                            Navigator.pop(dialogContext);
                                          }
                                        }
                                      } catch (e) {
                                        debugPrint(
                                          'Error checking popup state: $e',
                                        );
                                      }
                                    },
                                    onCloseWindow: (controller) {
                                      if (!popupClosed &&
                                          dialogContext.mounted) {
                                        popupClosed = true;
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                  return true;
                },
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.loadingLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_hasError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, size: 64, color: Colors.black54),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.offlineTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.offlineDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () async {
                            final url = _currentUrl.isNotEmpty
                                ? _currentUrl
                                : _homeUrl;
                            setState(() {
                              _isLoading = true;
                              _hasError = false;
                              _isShowingOfflineFallback = false;
                              _progress = 0;
                            });
                            await _webViewController?.loadUrl(
                              urlRequest: URLRequest(url: WebUri(url)),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.offlineRetry,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateNavigationButtons() async {
    final canGoBack = await _webViewController?.canGoBack() ?? false;

    final canGoForward = await _webViewController?.canGoForward() ?? false;

    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  void _ensureLocaleListener() {
    final controller = LocaleScope.of(context);
    if (identical(controller, _localeController)) {
      return;
    }

    _localeController?.removeListener(_postLocaleToWeb);
    _localeController = controller;
    _localeController?.addListener(_postLocaleToWeb);
  }

  void _postLocaleToWeb() {
    final locale = _localeController?.locale;
    if (locale == null || _webViewController == null) {
      return;
    }

    final localeCode = locale.toLanguageTag();
    _webViewController!.evaluateJavascript(
      source:
          "window.postMessage({ type: 'appLocaleChanged', locale: '$localeCode' }, '*');",
    );
  }

  @override
  void dispose() {
    _localeController?.removeListener(_postLocaleToWeb);
    super.dispose();
  }
}
