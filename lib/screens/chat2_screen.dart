import 'dart:collection';
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
    // Core JavaScript settings
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: true,

    // Storage and caching - Essential for captcha and window communication
    domStorageEnabled: true,
    databaseEnabled: true,
    cacheEnabled: true,
    thirdPartyCookiesEnabled: true,

    // Security and content settings
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,

    // Media settings
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,

    // iFrame settings
    iframeAllow: "camera; microphone; geolocation",
    iframeAllowFullscreen: true,

    // Scrolling
    disableVerticalScroll: false,
    disableHorizontalScroll: false,
    verticalScrollBarEnabled: true,
    horizontalScrollBarEnabled: true,

    // Window communication settings
    incognito: false,
    sharedCookiesEnabled: true,

    // User agent - simular navegador Chrome real sin identificadores de WebView
    userAgent: 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36',
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
                // No inyectar scripts que identifiquen la WebView para evitar detección de Cloudflare
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
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return _PopupWindow(
                        createWindowAction: createWindowAction,
                        settings: _settings,
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

class _PopupWindow extends StatefulWidget {
  final CreateWindowAction createWindowAction;
  final InAppWebViewSettings settings;

  const _PopupWindow({
    required this.createWindowAction,
    required this.settings,
  });

  @override
  State<_PopupWindow> createState() => _PopupWindowState();
}

class _PopupWindowState extends State<_PopupWindow> {
  InAppWebViewController? _popupController;
  double _progress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = math.min(mediaQuery.size.width * 0.95, 800.0);
    final height = mediaQuery.size.height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // Toolbar with navigation controls
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: _canGoBack ? Colors.black87 : Colors.grey,
                      ),
                      onPressed: _canGoBack
                          ? () => _popupController?.goBack()
                          : null,
                      tooltip: 'Back',
                    ),
                    // Forward button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward,
                        color: _canGoForward ? Colors.black87 : Colors.grey,
                      ),
                      onPressed: _canGoForward
                          ? () => _popupController?.goForward()
                          : null,
                      tooltip: 'Forward',
                    ),
                    // Reload button
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black87),
                      onPressed: () => _popupController?.reload(),
                      tooltip: 'Reload',
                    ),
                    const Spacer(),
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              // Progress bar
              if (_progress > 0 && _progress < 1.0)
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 2,
                ),
              // WebView
              Expanded(
                child: InAppWebView(
                  windowId: widget.createWindowAction.windowId,
                  initialSettings: widget.settings,
                  // No inyectar scripts que identifiquen la WebView para evitar detección de Cloudflare
                  onWebViewCreated: (controller) {
                    _popupController = controller;
                  },
                  onLoadStart: (controller, url) {
                    if (mounted) {
                      setState(() {
                        _progress = 0;
                      });
                    }
                  },
                  onLoadStop: (controller, url) async {
                    if (mounted) {
                      setState(() {
                        _progress = 1;
                      });
                      await _updateNavigationButtons();
                    }
                  },
                  onProgressChanged: (controller, progress) {
                    if (mounted) {
                      setState(() {
                        _progress = progress / 100.0;
                      });
                    }
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) async {
                    await _updateNavigationButtons();
                  },
                  onCloseWindow: (controller) {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  onCreateWindow: (controller, createWindowAction) async {
                    // Support nested popups
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) {
                        return _PopupWindow(
                          createWindowAction: createWindowAction,
                          settings: widget.settings,
                        );
                      },
                    );
                    return true;
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    return NavigationActionPolicy.ALLOW;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateNavigationButtons() async {
    if (_popupController != null) {
      final canGoBack = await _popupController!.canGoBack();
      final canGoForward = await _popupController!.canGoForward();
      if (mounted) {
        setState(() {
          _canGoBack = canGoBack;
          _canGoForward = canGoForward;
        });
      }
    }
  }

  @override
  void dispose() {
    _popupController = null;
    super.dispose();
  }
}
