import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class PlatformService {
  /// Detecta si el usuario está accediendo desde un dispositivo Android
  /// cuando la app se ejecuta en web
  static bool isAndroidOnWeb() {
    if (!kIsWeb) return false;
    
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('android');
  }
  
  /// Detecta si el usuario está accediendo desde un dispositivo móvil
  /// cuando la app se ejecuta en web
  static bool isMobileOnWeb() {
    if (!kIsWeb) return false;
    
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('android') || 
           userAgent.contains('iphone') || 
           userAgent.contains('ipad') ||
           userAgent.contains('mobile');
  }
  
  /// Abre una URL en una nueva ventana/pestaña
  static void openUrl(String url) {
    if (kIsWeb) {
      html.window.open(url, '_self');
    }
  }
}
