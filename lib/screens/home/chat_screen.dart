import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  InAppWebViewController? _webController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocAI Gaia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webController?.reload(),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://docai-508.pages.dev/gaia/'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              thirdPartyCookiesEnabled: true,
              supportMultipleWindows: true, // CRÍTICO: Habilita popups
              javaScriptCanOpenWindowsAutomatically: true,
              sharedCookiesEnabled: true,
            ),
            onWebViewCreated: (controller) {
              _webController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
            onCreateWindow: (controller, createWindowAction) async {
              // AQUÍ SE MANEJA EL POPUP AUTOMÁTICAMENTE
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Column(
                        children: [
                          AppBar(
                            title: const Text('Verificación'),
                            leading: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Expanded(
                            child: InAppWebView(
                              windowId: createWindowAction.windowId,
                              initialSettings: InAppWebViewSettings(
                                javaScriptEnabled: true,
                                domStorageEnabled: true,
                              ),
                              onLoadStop: (controller, url) {
                                // Detectar si es una página de cierre
                                if (url.toString().contains('close') || 
                                    url.toString() == 'about:blank') {
                                  Navigator.of(context).pop();
                                  _webController?.reload(); // Recargar página principal
                                }
                              },
                              onCloseWindow: (controller) {
                                // El popup se cerró desde JavaScript
                                Navigator.of(context).pop();
                                _webController?.reload();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              return true; // Permite crear la ventana
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
