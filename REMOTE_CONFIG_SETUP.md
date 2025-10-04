# Configuración de Remote Config para Modelos Dinámicos

Este documento explica cómo configurar Firebase Remote Config para gestionar los modelos de OpenRouter dinámicamente.

## 🎯 Características Implementadas

- ✅ **Modelos dinámicos** desde Firebase Remote Config
- ✅ **Cache de 5 minutos** para optimizar rendimiento
- ✅ **Colores personalizables** para cada modelo (degradado)
- ✅ **Pseudónimos configurables** (ej: "Doky Research", "Doky 1.0")
- ✅ **Soporte para reasoning** (modelos con razonamiento)
- ✅ **Manejo de errores amigable** cuando modelos no están disponibles
- ✅ **Fallback automático** a modelos por defecto si Remote Config falla

## 🔧 Configuración en Firebase Console

### 1. Acceder a Remote Config
1. Ve a Firebase Console → Tu proyecto → Remote Config
2. Crea un nuevo parámetro llamado `available_models`
3. Tipo: JSON

### 2. Configurar el JSON de modelos

```json
[
  {
    "id": "doky_instant",
    "brand": "doky",
    "displayName": "Doky Instant",
    "modelId": "google/gemini-2.0-flash-exp:free",
    "description": "Respuestas rápidas para consultas médicas básicas",
    "reasoning": false,
    "color1": "#4CAF50",
    "color2": "#8BC34A"
  },
  {
    "id": "doky_balanced",
    "brand": "doky", 
    "displayName": "Doky Balanced",
    "modelId": "deepseek/deepseek-chat-v3.1:free",
    "description": "Balance perfecto entre velocidad y precisión médica",
    "reasoning": false,
    "color1": "#2196F3",
    "color2": "#03DAC6"
  },
  {
    "id": "doky_reasoning",
    "brand": "doky",
    "displayName": "Doky Reasoning", 
    "modelId": "deepseek/deepseek-reasoner:free",
    "description": "Análisis médico profundo con razonamiento avanzado",
    "reasoning": true,
    "color1": "#9C27B0",
    "color2": "#E91E63"
  },
  {
    "id": "doky_pro",
    "brand": "doky",
    "displayName": "Doky Pro",
    "modelId": "x-ai/grok-4-fast:free", 
    "description": "Máxima precisión para casos médicos complejos",
    "reasoning": false,
    "color1": "#FF9800",
    "color2": "#FF5722"
  }
]
```

### 3. Publicar cambios
1. Haz clic en "Publish changes"
2. Los cambios se aplicarán automáticamente en la app

## 📱 Comportamiento en la App

### Cache y Actualización
- **Cache local**: 5 minutos
- **Fetch automático**: Cada vez que se abre el selector de modelos
- **Fallback**: Si Remote Config falla, usa modelos por defecto

### Manejo de Errores
- **Modelo no disponible**: Muestra mensaje amigable "El modelo no está disponible"
- **Sin modelos**: Muestra "No hay modelos disponibles"
- **Error de conexión**: Usa modelos por defecto localmente

### Colores Personalizados
- **color1**: Color primario del degradado
- **color2**: Color secundario del degradado
- Se aplican automáticamente en toda la UI

## 🔄 Actualización de Modelos

### Para agregar un nuevo modelo:
```json
{
  "id": "nuevo_modelo",
  "brand": "doky",
  "displayName": "Nuevo Modelo",
  "modelId": "proveedor/modelo:free",
  "description": "Descripción del modelo",
  "reasoning": false,
  "color1": "#HEXCOLOR1",
  "color2": "#HEXCOLOR2"
}
```

### Para modelos con reasoning:
- Establece `"reasoning": true`
- O usa un modelo específico de reasoning como `deepseek/deepseek-reasoner:free`

### Para deshabilitar un modelo:
- Simplemente elimínalo del JSON y publica los cambios

## 🎨 Personalización de Colores

Los colores deben estar en formato hexadecimal:
- `color1`: Color principal (usado en botones, iconos)
- `color2`: Color secundario (usado en degradados)

Ejemplos de combinaciones:
- Verde: `#4CAF50` + `#8BC34A`
- Azul: `#2196F3` + `#03DAC6`
- Morado: `#9C27B0` + `#E91E63`
- Naranja: `#FF9800` + `#FF5722`

## 🚀 Ventajas del Sistema

1. **Sin actualizaciones de app**: Cambios instantáneos
2. **Gestión centralizada**: Todo desde Firebase Console
3. **A/B Testing**: Posible con Remote Config
4. **Rollback rápido**: Revertir cambios al instante
5. **Segmentación**: Diferentes modelos por región/usuario

## 🔍 Monitoreo

- Los errores se registran en Firebase Crashlytics
- Cache hits/misses se pueden monitorear
- Uso de modelos se puede trackear con Analytics

## 📝 Notas Importantes

- Los modelos gratuitos de OpenRouter pueden cambiar disponibilidad
- El sistema maneja automáticamente modelos no disponibles
- Siempre mantén al menos un modelo funcional como fallback
- Los cambios en Remote Config pueden tardar hasta 12 horas en propagarse completamente