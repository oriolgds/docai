import 'package:flutter/foundation.dart';
// Solo importar dart:js cuando sea necesario
import 'dart:js' as js if (dart.library.js) 'dart:js';

class PlatformService {
  /// Detecta si el usuario está accediendo desde un dispositivo Android
  /// cuando la app se ejecuta en web
  static bool isAndroidOnWeb() {
    if (!kIsWeb) return false;
    
    try {
      // Usar dart:js para obtener user agent
      final navigator = js.context['navigator'];
      if (navigator != null) {
        final userAgent = navigator['userAgent']?.toString().toLowerCase() ?? '';
        return userAgent.contains('android');
      }
    } catch (e) {
      debugPrint('Error detecting Android: $e');
    }
    return false;
  }
  
  /// Detecta si el usuario está accediendo desde un dispositivo móvil
  /// cuando la app se ejecuta en web
  static bool isMobileOnWeb() {
    if (!kIsWeb) return false;
    
    try {
      // Usar dart:js para obtener user agent
      final navigator = js.context['navigator'];
      if (navigator != null) {
        final userAgent = navigator['userAgent']?.toString().toLowerCase() ?? '';
        return userAgent.contains('android') || 
               userAgent.contains('iphone') || 
               userAgent.contains('ipad') ||
               userAgent.contains('mobile');
      }
    } catch (e) {
      debugPrint('Error detecting mobile: $e');
    }
    return false;
  }
  
  /// Abre una URL en una nueva ventana/pestaña
  static void openUrl(String url) {
    if (!kIsWeb) return;
    
    try {
      // Usar dart:js para abrir URL
      final window = js.context['window'];
      if (window != null) {
        window.callMethod('open', [url, '_self']);
      }
    } catch (e) {
      debugPrint('Error opening URL: $e');
    }
  }
}