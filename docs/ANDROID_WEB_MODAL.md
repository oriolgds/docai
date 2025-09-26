# Modal de Redirección Android Web

Esta implementación fuerza a los usuarios que accedan a la versión web de DocAI desde dispositivos Android a descargar la aplicación nativa desde Google Play Store.

## Archivos Implementados

### `lib/services/platform_service.dart`
Servicio que detecta la plataforma del usuario:
- `isAndroidOnWeb()`: Detecta si el usuario accede desde Android en web
- `isMobileOnWeb()`: Detecta dispositivos móviles en general
- `openUrl()`: Abre URLs en la misma ventana/pestaña

### `lib/widgets/android_download_modal.dart`
Contiene dos componentes principales:

#### `AndroidDownloadModal`
- Modal no cancelable que muestra información sobre la descarga
- Incluye icono de Android, mensaje informativo y botón de descarga
- Redirige directamente a: `https://play.google.com/store/apps/details?id=com.oriolgds.doky`

#### `AndroidDownloadWrapper`
- Widget que envuelve la aplicación
- Detecta automáticamente si es Android en web
- Muestra el modal de descarga si es necesario

### `lib/main.dart`
Modificaciones:
- Importa `android_download_modal.dart`
- Envuelve la pantalla inicial con `AndroidDownloadWrapper`
- El modal se muestra automáticamente al detectar Android

## Funcionamiento

1. **Detección**: Cuando la app web se carga, `PlatformService` verifica el user agent
2. **Activación**: Si detecta Android, `AndroidDownloadWrapper` muestra el modal
3. **Modal**: Se presenta un modal no cancelable con:
   - Título llamativo
   - Descripción clara
   - Botón de descarga prominente
   - Información adicional
4. **Redirección**: Al hacer clic, abre Google Play Store en la misma ventana

## Características

- ✅ **No cancelable**: El usuario no puede cerrar el modal
- ✅ **Detección precisa**: Identifica específicamente Android
- ✅ **UX atractiva**: Diseño moderno con gradientes y iconos
- ✅ **Redirección directa**: Abre Play Store inmediatamente
- ✅ **Responsive**: Se adapta a diferentes tamaños de pantalla
- ✅ **Multiidioma ready**: Preparado para futuras traducciones

## Personalización

Para modificar la URL de destino, cambiar la constante `playStoreUrl` en `AndroidDownloadModal`:

```dart
static const String playStoreUrl = 
    'https://play.google.com/store/apps/details?id=tu.nuevo.id';
```

## Consideraciones Técnicas

- Usa `dart:html` solo en entorno web
- Compatible con Flutter 3.9.0+
- No requiere dependencias adicionales
- Funciona con el sistema de navegación actual de la app

## Testing

Para probar la funcionalidad:
1. Compila la app para web: `flutter build web`
2. Sirve la app localmente
3. Abre las herramientas de desarrollador del navegador
4. Simula un dispositivo Android en la pestaña de dispositivos
5. Recarga la página para ver el modal
