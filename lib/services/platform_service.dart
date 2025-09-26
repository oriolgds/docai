import 'package:flutter/foundation.dart';
// Import condicional para web
import 'dart:html' as html show window if (dart.library.html) 'dart:html';

class PlatformService {
  /// Detecta si el usuario está accediendo desde un dispositivo Android
  /// cuando la app se ejecuta en web
  static bool isAndroidOnWeb() {
    if (!kIsWeb) return false;
    
    try {
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      return userAgent.contains('android');
    } catch (e) {
      // Si falla la detección (por ejemplo, en desarrollo), retorna false
      return false;
    }
  }
  
  /// Detecta si el usuario está accediendo desde un dispositivo móvil
  /// cuando la app se ejecuta en web
  static bool isMobileOnWeb() {
    if (!kIsWeb) return false;
    
    try {
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      return userAgent.contains('android') || 
             userAgent.contains('iphone') || 
             userAgent.contains('ipad') ||
             userAgent.contains('mobile');
    } catch (e) {
      // Si falla la detección, retorna false
      return false;
    }
  }
  
  /// Abre una URL en una nueva ventana/pestaña
  static void openUrl(String url) {
    if (kIsWeb) {
      try {
        html.window.open(url, '_self');
      } catch (e) {
        // Si falla la apertura de URL, no hace nada
        // En un entorno de producción, podrías manejar esto de otra manera
        debugPrint('Error opening URL: $e');
      }
    }
  }
}