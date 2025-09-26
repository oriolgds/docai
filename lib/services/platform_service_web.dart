import 'dart:html' as html;

class PlatformServiceWeb {
  /// Detecta si el usuario está accediendo desde un dispositivo Android
  static bool isAndroidOnWeb() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('android');
  }
  
  /// Detecta si el usuario está accediendo desde un dispositivo móvil
  static bool isMobileOnWeb() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('android') || 
           userAgent.contains('iphone') || 
           userAgent.contains('ipad') ||
           userAgent.contains('mobile');
  }
  
  /// Abre una URL en una nueva ventana/pestaña
  static void openUrl(String url) {
    html.window.open(url, '_self');
  }
}