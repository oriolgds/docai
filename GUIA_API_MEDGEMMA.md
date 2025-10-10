# Guía API MedGemma 27B IT

## Información Básica

**URL**: `https://warshanks-medgemma-27b-it.hf.space`
**API**: `https://warshanks-medgemma-27b-it.hf.space/gradio_api/call/chat`
**Tipo**: Gradio v5.31.0 (2 pasos: POST + GET streaming)

## Patrón de Peticiones

### 1. POST Inicial (obtiene event_id)
```bash
curl -X POST https://warshanks-medgemma-27b-it.hf.space/gradio_api/call/chat \
  -H "Content-Type: application/json" \
  -d '{
    "data": [
      {
        "text": "Describe esta imagen médica",
        "files": [{
          "path": "https://ejemplo.com/imagen.jpg",
          "url": "https://ejemplo.com/imagen.jpg",
          "orig_name": "imagen.jpg", 
          "size": null,
          "mime_type": "image/jpeg",
          "is_stream": false,
          "meta": {"_type": "gradio.FileData"}
        }]
      },
      [],
      "You are a helpful medical expert.",
      2048
    ]
  }'
```

**Respuesta**: `{"event_id":"abc123..."}`

### 2. GET Streaming (usa event_id)
```bash
curl -N https://warshanks-medgemma-27b-it.hf.space/gradio_api/call/chat/{EVENT_ID}
```

## Parámetros de la API

La API requiere exactamente 3 parámetros en `data`:

1. **Multimodal Input**:
   - `text`: Pregunta del usuario
   - `files`: Array de archivos (o vacío `[]`)

2. **System Prompt**: String con instrucciones del sistema

3. **Max Tokens**: Número entero (ej: 2048)

## Formatos Soportados

### ✅ Con Imagen (Recomendado)
```json
{
  "text": "¿Qué ves en esta radiografía?",
  "files": [{
    "path": "https://url-publica.com/rayos-x.jpg",
    "url": "https://url-publica.com/rayos-x.jpg",
    "orig_name": "rayos-x.jpg",
    "size": null,
    "mime_type": "image/jpeg", 
    "is_stream": false,
    "meta": {"_type": "gradio.FileData"}
  }]
}
```

### ⚠️ Solo Texto (Limitado)
```json
{
  "text": "Explica los síntomas de diabetes",
  "files": []
}
```

## Errores Comunes

### ❌ Error JSON: NO usar `handle_file()`
```bash
# MAL - Como aparece en documentación oficial
"files":[handle_file('url')]  # ❌ No válido en curl

# BIEN - Formato JSON correcto  
"files":[{"path":"url","url":"url",...}]  # ✅ Funciona
```

### ❌ Session not found / event: error
**Causas**:
- Event_id expirado
- Imagen no accesible públicamente
- Space sobrecargado

**Solución**: Nueva petición POST

## Script Completo de Ejemplo

```bash
#!/bin/bash
medgemma_call() {
    local question="$1"
    local image_url="$2"
    
    echo "🔄 Enviando petición..."
    
    # Preparar archivos JSON
    if [ -n "$image_url" ]; then
        files_json='[{
            "path": "'$image_url'",
            "url": "'$image_url'", 
            "orig_name": "image.jpg",
            "size": null,
            "mime_type": "image/jpeg",
            "is_stream": false,
            "meta": {"_type": "gradio.FileData"}
        }]'
    else
        files_json='[]'
    fi
    
    # POST inicial
    response=$(curl -s -X POST https://warshanks-medgemma-27b-it.hf.space/gradio_api/call/chat \
        -H "Content-Type: application/json" \
        -d '{
            "data": [
                {"text": "'$question'", "files": '$files_json'},
                [],
                "You are a helpful medical expert.",
                2048
            ]
        }')
    
    # Extraer event_id
    event_id=$(echo $response | grep -o '"event_id":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$event_id" ]; then
        echo "❌ Error: $response"
        return 1
    fi
    
    echo "✅ Event ID: $event_id"
    echo "📡 Streaming..."
    
    # GET streaming
    timeout 30s curl -N -s "https://warshanks-medgemma-27b-it.hf.space/gradio_api/call/chat/$event_id" | \
    while read -r line; do
        if [[ $line == data:* ]]; then
            content=$(echo "$line" | sed 's/^data: //')
            [ "$content" != "null" ] && echo "💬 $content"
        elif [[ $line == event:* ]]; then
            event=$(echo "$line" | sed 's/^event: //')
            echo "🔔 $event"
        fi
    done
}

# Uso
medgemma_call "Describe esta imagen" "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png"
```

## Para Flutter/Dart

```dart
class MedGemmaService {
  static const baseUrl = 'https://warshanks-medgemma-27b-it.hf.space/gradio_api';
  
  Future<String> analyzeImage(String question, String imageUrl) async {
    // 1. POST
    final postResponse = await http.post(
      Uri.parse('$baseUrl/call/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': [
          {
            'text': question,
            'files': imageUrl.isNotEmpty ? [{
              'path': imageUrl,
              'url': imageUrl,
              'orig_name': 'image.jpg',
              'size': null,
              'mime_type': 'image/jpeg',
              'is_stream': false,
              'meta': {'_type': 'gradio.FileData'}
            }] : []
          },
          [],
          'You are a helpful medical expert.',
          2048
        ]
      })
    );
    
    final eventId = jsonDecode(postResponse.body)['event_id'];
    
    // 2. GET streaming
    final streamResponse = await http.get(
      Uri.parse('$baseUrl/call/chat/$eventId')
    );
    
    // Procesar respuesta SSE
    final lines = streamResponse.body.split('\n');
    for (final line in lines) {
      if (line.startsWith('data: ') && line != 'data: null') {
        return line.substring(6); // Remover "data: "
      }
    }
    
    return '';
  }
}
```

## Limitaciones Importantes

### 🚫 No Soportado
- Archivos locales (solo URLs públicas)
- CORS directo desde navegadores 
- Sesiones persistentes

### ✅ Recomendaciones
- Usar siempre imágenes cuando sea posible
- Implementar reintentos con backoff exponencial
- Considerar proxy para aplicaciones web
- Timeout en streaming (30-60s)

## Prompts Médicos Sugeridos

```
"You are a helpful medical expert specializing in image analysis. Analyze medical images with precision and always remind users to consult healthcare professionals for diagnosis and treatment."

"Eres un asistente médico experto en análisis de imágenes. Proporciona información precisa pero siempre recuerda que los usuarios deben consultar con profesionales de la salud."
```

## Manejo de Errores

```bash
# Con reintentos
for i in {1..3}; do
    if medgemma_call "$question" "$image"; then
        break
    else
        echo "Intento $i falló, reintentando en $((i*2))s..."
        sleep $((i*2))
    fi
done
```

## Respuesta Streaming Format

```
event: generating
data: ["Partial response...", null]

event: generating  
data: ["More complete response...", null]

event: complete
data: ["Final complete response", null]

# O en caso de error:
event: error
data: null
```

## Conclusión

MedGemma requiere:
1. **POST** con JSON correcto → event_id
2. **GET** streaming con event_id → respuesta
3. **URLs públicas** para imágenes  
4. **Manejo robusto** de errores

La clave es NO usar `handle_file()` sino el formato JSON completo de FileData.