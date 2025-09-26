import 'package:flutter/foundation.dart';
import 'dart:js_interop' as js;

class PlatformService {
  /// Detecta si el usuario está accediendo desde un dispositivo Android
  /// cuando la app se ejecuta en web
  static bool isAndroidOnWeb() {
    if (!kIsWeb) return false;
    
    try {
      // Usar JavaScript interop para obtener user agent
      final userAgent = js.globalContext['navigator']['userAgent'].toString().toLowerCase();
      return userAgent.contains('android');
    } catch (e) {
      return false;
    }
  }
  
  /// Detecta si el usuario está accediendo desde un dispositivo móvil
  /// cuando la app se ejecuta en web
  static bool isMobileOnWeb() {
    if (!kIsWeb) return false;
    
    try {
      // Usar JavaScript interop para obtener user agent
      final userAgent = js.globalContext['navigator']['userAgent'].toString().toLowerCase();
      return userAgent.contains('android') || 
             userAgent.contains('iphone') || 
             userAgent.contains('ipad') ||
             userAgent.contains('mobile');
    } catch (e) {
      return false;
    }
  }
  
  /// Abre una URL en una nueva ventana/pestaña
  static void openUrl(String url) {
    if (kIsWeb) {
      try {
        // Usar JavaScript interop para abrir URL
        js.globalContext['window'].callMethod('open', [url, '_self']);
      } catch (e) {
        debugPrint('Error opening URL: $e');
      }
    }
  }
}