# Estructura del JSON para Firebase Remote Config

## Parámetro: `available_models`
**Tipo:** JSON

### Estructura correcta:

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

### Para NO mostrar modelos (lista vacía):
```json
[]
```

### Campos obligatorios:
- `id`: Identificador único del modelo
- `brand`: Marca (actualmente solo "doky")
- `displayName`: Nombre que se muestra al usuario
- `modelId`: ID del modelo en OpenRouter
- `description`: Descripción del modelo
- `reasoning`: true/false si soporta razonamiento
- `color1`: Color primario en formato hex (#RRGGBB)
- `color2`: Color secundario en formato hex (#RRGGBB)

### Notas importantes:
1. **Array vacío `[]`** = "No hay modelos disponibles"
2. **String vacío `""`** = Usa modelos por defecto (fallback)
3. **JSON inválido** = Usa modelos por defecto (fallback)
4. Los colores deben incluir el `#` al inicio
5. El campo `reasoning` debe ser boolean, no string