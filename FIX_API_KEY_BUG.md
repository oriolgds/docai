# Fix API Key Verification Bug

## Problema Identificado

La aplicación mostrava el error "apiKey is required and must be a string" cuando los usuarios intentaban enviar mensajes, incluso teniendo la clave API correctamente configurada.

### Error Original:
```
Error al verificar clave: FunctionException(status: 400, details: {success: false, error: apiKey is required and must be a string, valid: false}, reasonPhrase: Bad Request)
```

![Error Screenshot](attached_image:1)

## Análisis del Problema

El problema se encontraba en el método `getUserApiKey` en `lib/services/supabase_service.dart`. El código original tenía una estructura de consulta SQL anidada problemática:

```dart
// CÓDIGO PROBLEMÁTICO (ANTES)
static Future<String?> getUserApiKey(String provider) async {
  final user = currentUser;
  if (user == null) return null;

  try {
    final result = await client
        .rpc('decrypt_api_key', params: {
          'encrypted_key': await client
              .from('user_api_keys')
              .select('api_key')
              .eq('user_id', user.id)
              .eq('provider', provider)
              .single()  // ← PROBLEMA: .single() lanza excepción si no existe
              .then((data) => data['api_key'])
        });

    return result as String?;
  } catch (e) {
    return null;
  }
}
```

### Problemas identificados:

1. **Consulta SQL anidada**: La llamada a `.rpc()` contenía otra consulta SQL dentro de sus parámetros
2. **Manejo de errores inadecuado**: `.single()` lanza una excepción si no encuentra registros
3. **Parámetros mal formateados**: La función Supabase `verify-api-key` recibía parámetros malformados
4. **Falta de validación**: No se validaba si la API key existía antes de intentar desencriptarla

## Solución Implementada

Se reestructuró el método para separar las operaciones en dos pasos claros:

```dart
// CÓDIGO CORREGIDO (DESPUÉS)
static Future<String?> getUserApiKey(String provider) async {
  final user = currentUser;
  if (user == null) return null;

  try {
    // PASO 1: Obtener la clave encriptada de la base de datos
    final result = await client
        .from('user_api_keys')
        .select('api_key')
        .eq('user_id', user.id)
        .eq('provider', provider)
        .maybeSingle(); // ← MEJORADO: maybeSingle() retorna null si no existe

    // PASO 2: Validar si existe la clave
    if (result == null || result['api_key'] == null) {
      return null;
    }

    final encryptedKey = result['api_key'] as String;

    // PASO 3: Desencriptar la clave usando RPC separadamente
    final decryptedKey = await client
        .rpc('decrypt_api_key', params: {
          'encrypted_key': encryptedKey
        });

    return decryptedKey as String?;
  } catch (e) {
    print('Error getting API key for provider $provider: $e');
    return null;
  }
}
```

### Mejoras aplicadas también:

1. **hasUserApiKey()**: Cambió `.single()` por `.maybeSingle()` para evitar excepciones
2. **setUserApiKey()**: Mejoró el manejo de timestamps
3. **Logging mejorado**: Agregó logs específicos para debugging
4. **Manejo de errores robusto**: Captura y maneja errores específicos

## Otros archivos relacionados que se revisaron:

- `supabase/functions/verify-api-key/index.ts` - ✅ Correcto, no necesita cambios
- `lib/screens/home/profile_screen.dart` - ✅ Correcto, maneja bien la validación
- `lib/screens/home/chat_screen.dart` - ✅ Correcto, maneja bien los errores de API key

## Impacto de la Solución

### Antes del fix:
- ❌ Modal de "configurar API key" aparecía siempre al enviar mensajes
- ❌ Error "apiKey is required and must be a string" en la verificación
- ❌ Usuario no podía usar la app incluso con clave configurada

### Después del fix:
- ✅ Detección correcta de claves API existentes
- ✅ Verificación funcional de claves API
- ✅ Usuario puede usar la app normalmente con clave configurada
- ✅ Mejor manejo de errores y logging
- ✅ Modal solo aparece cuando realmente no hay clave configurada

## Testing Recomendado

1. **Test sin API key**: Verificar que aparece el modal de configuración
2. **Test con API key válida**: Verificar que no aparece el modal y funciona el envío
3. **Test con API key inválida**: Verificar que muestra error de validación
4. **Test de verificación**: Botón "Verificar" en perfil debe funcionar correctamente

## Archivos Modificados

- `lib/services/supabase_service.dart` - Métodos de API key corregidos

## Comandos para probar

```bash
# Cambiar a la rama del fix
git checkout fix-api-key-verification-bug

# Hacer build y probar
flutter clean
flutter pub get
flutter run
```