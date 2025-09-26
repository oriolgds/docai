import 'package:flutter/foundation.dart';
import 'dart:js_interop';

@JS('window')
external Window get window;

@JS()
@anonymous
extension type Window(JSObject _) implements JSObject {
  external Navigator get navigator;
  external void open(String url, String target);
}

@JS()
@anonymous
extension type Navigator(JSObject _) implements JSObject {
  external String get userAgent;
}

class PlatformService {
  /// Detecta si estamos en Android desde un navegador web
  static bool isAndroidOnWeb() {
    if (!kIsWeb) return false;
    
    try {
      final userAgent = window.navigator.userAgent.toLowerCase();
      return userAgent.contains('android');
    } catch (e) {
      if (kDebugMode) {
        print('Error detecting Android on web: $e');
      }
      return false;
    }
  }

  /// Detecta si estamos en un dispositivo móvil desde web
  static bool isMobileOnWeb() {
    if (!kIsWeb) return false;
    
    try {
      final userAgent = window.navigator.userAgent.toLowerCase();
      return userAgent.contains('android') || 
             userAgent.contains('iphone') || 
             userAgent.contains('ipad');
    } catch (e) {
      if (kDebugMode) {
        print('Error detecting mobile on web: $e');
      }
      return false;
    }
  }

  /// Abre una URL en el navegador
  static void openUrl(String url) {
    if (!kIsWeb) return;
    
    try {
      window.open(url, '_self');
    } catch (e) {
      if (kDebugMode) {
        print('Error opening URL: $e');
      }
    }
  }
}
