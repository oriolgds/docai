import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../l10n/generated/app_localizations.dart';

class Chat2Screen extends StatefulWidget {
  const Chat2Screen({super.key});

  @override
  State<Chat2Screen> createState() => _Chat2ScreenState();
}

class _Chat2ScreenState extends State<Chat2Screen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  String _currentUrl = 'https://docai-chat.oriolginger2008.workers.dev/';
  bool _canGoBack = false;
  bool _canGoForward = false;

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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chat 2',
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
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () async {
              await _webViewController?.reload();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) async {
              switch (value) {
                case 'home':
                  await _webViewController?.loadUrl(
                    urlRequest: URLRequest(
                      url: WebUri(_currentUrl),
                    ),
                  );
                  break;
                case 'open_browser':
                  final url = await _webViewController?.getUrl();
                  if (url != null) {
                    await _webViewController?.loadUrl(
                      urlRequest: URLRequest(url: url),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'home',
                child: Row(
                  children: [
                    const Icon(Icons.home, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.home ?? 'Home'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'open_browser',
                child: Row(
                  children: [
                    const Icon(Icons.open_in_browser, size: 20),
                    const SizedBox(width: 12),
                    const Text('Reload'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(_currentUrl),
        ),
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
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: const Text(
                          'Nueva ventana',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: InAppWebView(
                          windowId: createWindowAction.windowId,
                          initialSettings: _settings,
                          shouldOverrideUrlLoading: (controller, navigationAction) async {
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
