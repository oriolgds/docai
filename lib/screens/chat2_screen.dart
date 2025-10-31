import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:docai/l10n/app_localizations.dart';
import 'package:docai/screens/info_screen.dart';

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

  final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone; geolocation",
    iframeAllowFullscreen: true,
  );

  @override
  Widget build(BuildContext context) {
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
                await _webViewController?.reload();
              },
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.menuMoreInfo,
              icon: const Icon(Icons.info_outline, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const InfoScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
              initialSettings: _settings,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _currentUrl = url.toString();
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _currentUrl = url.toString();
                  _isLoading = false;
                });
                _updateNavigationButtons();
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
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
                  builder: (context) {
                    return Dialog(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.8,
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
                                onPressed: () => Navigator.pop(context),
                              ),
                              title: Text(
                                AppLocalizations.of(context)!.newWindowTitle,
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
                                onCloseWindow: (controller) {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
                return true;
              },
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
}
