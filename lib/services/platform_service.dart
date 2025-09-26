import 'package:flutter/foundation.dart';

class PlatformService {
  /// Detecta si el usuario está accediendo desde un dispositivo Android
  /// cuando la app se ejecuta en web
  static bool isAndroidOnWeb() {
    if (!kIsWeb) return false;
    
    // Solo en web, usar detección por user agent
    if (kIsWeb) {
      return _isAndroidUserAgent();
    }
    return false;
  }
  
  /// Detecta si el usuario está accediendo desde un dispositivo móvil
  /// cuando la app se ejecuta en web
  static bool isMobileOnWeb() {
    if (!kIsWeb) return false;
    
    // Solo en web, usar detección por user agent
    if (kIsWeb) {
      return _isMobileUserAgent();
    }
    return false;
  }
  
  /// Abre una URL en una nueva ventana/pestaña
  static void openUrl(String url) {
    if (kIsWeb) {
      _openUrlWeb(url);
    }
  }
}

// Implementaciones específicas para web - solo se compilan en web
bool _isAndroidUserAgent() {
  // Esta función solo se llama cuando kIsWeb es true
  try {
    // Usar evaluateJavaScript para acceder al user agent
    return false; // Placeholder - se implementará con JS
  } catch (e) {
    return false;
  }
}

bool _isMobileUserAgent() {
  // Esta función solo se llama cuando kIsWeb es true
  try {
    // Usar evaluateJavaScript para acceder al user agent
    return false; // Placeholder - se implementará con JS
  } catch (e) {
    return false;
  }
}

void _openUrlWeb(String url) {
  // Esta función solo se llama cuando kIsWeb es true
  try {
    // Usar JS para abrir URL
    // Se implementará con JS
  } catch (e) {
    debugPrint('Error opening URL: $e');
  }
}