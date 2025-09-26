import 'package:flutter/foundation.dart';

// Importación condicional basada en la plataforma
import 'platform_service_web.dart'
    if (dart.library.io) 'platform_service_mobile.dart' as platform_impl;

class PlatformService {
  /// Detecta si el usuario está accediendo desde un dispositivo Android
  /// cuando la app se ejecuta en web
  static bool isAndroidOnWeb() {
    if (!kIsWeb) return false;
    
    if (kIsWeb) {
      return platform_impl.PlatformServiceWeb.isAndroidOnWeb();
    } else {
      return platform_impl.PlatformServiceMobile.isAndroidOnWeb();
    }
  }
  
  /// Detecta si el usuario está accediendo desde un dispositivo móvil
  /// cuando la app se ejecuta en web
  static bool isMobileOnWeb() {
    if (!kIsWeb) return false;
    
    if (kIsWeb) {
      return platform_impl.PlatformServiceWeb.isMobileOnWeb();
    } else {
      return platform_impl.PlatformServiceMobile.isMobileOnWeb();
    }
  }
  
  /// Abre una URL en una nueva ventana/pestaña
  static void openUrl(String url) {
    if (kIsWeb) {
      platform_impl.PlatformServiceWeb.openUrl(url);
    } else {
      platform_impl.PlatformServiceMobile.openUrl(url);
    }
  }
}