class PlatformServiceMobile {
  /// En plataformas móviles, Android no está en web
  static bool isAndroidOnWeb() {
    return false;
  }
  
  /// En plataformas móviles, no está en web
  static bool isMobileOnWeb() {
    return false;
  }
  
  /// En plataformas móviles, no se puede abrir URLs web directamente
  static void openUrl(String url) {
    // No-op en plataformas móviles
  }
}