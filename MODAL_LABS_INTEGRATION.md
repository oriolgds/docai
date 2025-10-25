# Modal Labs Integration

## Descripción

Modal Labs es un proveedor de modelos que permite ejecutar modelos de IA en la nube mediante endpoints SSE (Server-Sent Events). DocAI ahora soporta la integración con Modal Labs para usar modelos como Llama 3.2 3B.

## Características

- **Streaming SSE**: Respuestas en tiempo real mediante Server-Sent Events
- **Llama 3.2 3B**: Modelo ligero y rápido para consultas médicas
- **Sin API Key**: No requiere configuración de claves API
- **Cold Start**: El endpoint se activa automáticamente después de 60 segundos de inactividad
- **Límite diario**: Sistema de límite de queries configurable por usuario (default: 5 queries/día)

## Configuración

### 1. Configurar límite diario en Firebase Remote Config

Agrega el parámetro `modal_daily_limit` en Firebase Remote Config:

```json
{
  "modal_daily_limit": 10
}
```

Este valor determina cuántas queries puede hacer cada usuario por día. El valor por defecto es 5.

### 2. Agregar el modelo en Firebase Remote Config

En tu configuración de Firebase Remote Config, agrega el siguiente modelo al array `available_models`:

```json
{
  "id": "doky_modal",
  "brand": "doky",
  "displayName": "Doky Modal (Llama 3.2 3B)",
  "modelId": "https://oriolgds--llama32-sse-streaming-generate.modal.run",
  "description": "Modelo ligero y rápido basado en Llama 3.2 3B",
  "reasoning": false,
  "color1": "#FF6B35",
  "color2": "#F7931E",
  "disabled": false,
  "provider": "modal"
}
```

### 3. Ejecutar migración de base de datos

Ejecuta la migración SQL para crear la tabla `user_queries_limit`:

```bash
supabase migration up
```

O aplica manualmente el archivo `supabase/migrations/004_create_user_queries_limit.sql`

### 4. Parámetros del modelo

El servicio de Modal Labs acepta los siguientes parámetros:

- `prompt` (string, requerido): El prompt completo incluyendo historial
- `max_tokens` (int, opcional): Máximo de tokens a generar (default: 512)
- `temperature` (float, opcional): Temperatura para la generación (default: 0.7)
- `top_p` (float, opcional): Top-p sampling (default: 0.9)

### 5. Formato de respuesta SSE

El endpoint de Modal Labs responde con eventos SSE en el siguiente formato:

**Evento de conexión:**
```
data: {"status": "connected"}
```

**Eventos de tokens (contenido acumulado):**
```
data: {"token": "Hello"}
data: {"token": "Hello there"}
data: {"token": "Hello there, how"}
```

**Nota importante**: Modal Labs envía el contenido completo acumulado en cada evento, no tokens incrementales. El servicio extrae automáticamente solo el contenido nuevo.

**Evento de completado:**
```
data: {"status": "completed"}
```

**Evento de error:**
```
data: {"error": "error message"}
```

## Implementación técnica

### Servicio Modal

El servicio `ModalService` (`lib/services/modal_service.dart`) maneja:

1. **Construcción del prompt**: Combina el system prompt con el historial de mensajes
2. **Streaming SSE**: Procesa los eventos SSE del endpoint de Modal
3. **Extracción incremental**: Detecta y extrae solo el contenido nuevo de cada evento (Modal envía contenido acumulado)
4. **Manejo de errores**: Captura y reporta errores de conexión o del modelo
5. **Cancelación**: Permite cancelar streams en progreso

### Integración en ModelService

El `ModelService` ahora incluye soporte para Modal Labs:

```dart
case ModelProvider.modal:
  yield* _modal.streamChatCompletion(
    messages: messages,
    profile: profile,
    systemPromptOverride: systemPromptOverride,
    temperature: temperature,
    useReasoning: useReasoning,
  );
  break;
```

## Sistema de límite de queries

### Funcionamiento

1. **Límite diario**: Cada usuario tiene un límite de queries por día (configurable en Remote Config)
2. **Verificación automática**: Antes de cada query, se verifica si el usuario tiene queries disponibles
3. **Contador por día**: El límite se resetea automáticamente cada día
4. **Almacenamiento en Supabase**: Los límites se guardan en la tabla `user_queries_limit`

### Servicios involucrados

- **QueryLimitService**: Maneja la lógica de límites
  - `getRemainingQueries()`: Obtiene queries restantes del día
  - `canMakeQuery()`: Verifica si el usuario puede hacer una query
  - `decrementQuery()`: Decrementa el contador después de una query exitosa

- **RemoteConfigService**: Obtiene el límite configurado
  - `getModalDailyLimit()`: Retorna el límite diario desde Firebase

### Manejo de errores

Cuando un usuario alcanza el límite diario, se lanza una excepción:

```dart
Exception('Has alcanzado el límite diario de consultas para Modal Labs. Consultas restantes: 0')
```

## Ventajas de Modal Labs

1. **Sin costos de API**: No requiere claves API de terceros
2. **Rápido**: Modelo ligero optimizado para respuestas rápidas
3. **Escalable**: Modal Labs maneja el escalado automáticamente
4. **Streaming nativo**: Respuestas en tiempo real mediante SSE
5. **Control de uso**: Sistema de límites para gestionar el consumo

## Limitaciones

1. **Cold Start**: Primera petición después de inactividad puede tardar más
2. **Modelo específico**: Actualmente solo soporta Llama 3.2 3B
3. **Capacidades limitadas**: Modelo más pequeño que GPT-4 o Claude
4. **Límite diario**: Queries limitadas por día (configurable, default: 5)

## Ejemplo de uso

```dart
final modalProfile = ModelProfile(
  id: 'doky_modal',
  brand: BrandName.doky,
  tier: '',
  displayName: 'Doky Modal',
  modelId: 'https://oriolgds--llama32-sse-streaming-generate.modal.run',
  description: 'Modelo ligero y rápido',
  provider: ModelProvider.modal,
);

await for (final chunk in ModelService.streamChatCompletion(
  messages: messages,
  profile: modalProfile,
  systemPromptOverride: systemPrompt,
  temperature: 0.7,
)) {
  print(chunk);
}
```

## Troubleshooting

### Error: "Modal API error: 500"
- El endpoint puede estar en cold start. Espera unos segundos y reintenta.

### Error: "Error al consultar Modal Labs"
- Verifica que la URL del endpoint sea correcta
- Comprueba tu conexión a internet
- Revisa los logs para más detalles

### Respuestas lentas
- Primera petición después de inactividad puede tardar 10-15 segundos (cold start)
- Peticiones subsecuentes serán más rápidas

### Error: "Has alcanzado el límite diario de consultas"
- El usuario ha usado todas sus queries del día
- El límite se resetea automáticamente a medianoche UTC
- Puedes aumentar el límite en Firebase Remote Config (`modal_daily_limit`)

## Referencias

- [Modal Labs Documentation](https://modal.com/docs)
- [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- [Llama 3.2 Model Card](https://huggingface.co/meta-llama/Llama-3.2-3B)
