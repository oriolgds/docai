import 'package:flutter/foundation.dart';

// Conditional imports - solo importa js_interop para web
import 'platform_service_stub.dart'
    if (dart.library.js_interop) 'platform_service_web.dart' as platform;

class PlatformService {
  /// Detecta si estamos en Android desde un navegador web
  static bool isAndroidOnWeb() {
    return platform.isAndroidOnWeb();
  }

  /// Detecta si estamos en un dispositivo móvil desde web
  static bool isMobileOnWeb() {
    return platform.isMobileOnWeb();
  }

  /// Abre una URL en el navegador
  static void openUrl(String url) {
    platform.openUrl(url);
  }
}