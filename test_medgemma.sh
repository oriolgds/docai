#!/bin/bash

echo "=== Probando API MedGemma ==="
echo

# Función para hacer la llamada inicial
call_medgemma() {
    local text="$1"
    local files="$2"
    
    echo "📤 Enviando petición..."
    echo "Texto: $text"
    
    local response=$(curl -s -X POST https://warshanks-medgemma-27b-it.hf.space/gradio_api/call/chat \
        -H "Content-Type: application/json" \
        -d "{
            \"data\": [
                {
                    \"text\": \"$text\",
                    \"files\": $files
                },
                [],
                \"You are a helpful medical expert. Analyze medical images and provide detailed, accurate information. Always remind users to consult healthcare professionals for diagnosis and treatment.\",
                2048
            ]
        }")
    
    echo "📥 Respuesta inicial: $response"
    
    # Extraer event_id
    local event_id=$(echo $response | grep -o '"event_id":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$event_id" ]; then
        echo "❌ Error: No se pudo obtener event_id"
        return 1
    fi
    
    echo "🔄 Event ID: $event_id"
    echo "📡 Obteniendo respuesta streaming..."
    echo
    
    # Obtener respuesta streaming
    curl -N "https://warshanks-medgemma-27b-it.hf.space/gradio_api/call/chat/$event_id" 2>/dev/null | while IFS= read -r line; do
        if [[ $line == data:* ]]; then
            # Extraer solo el contenido después de "data: "
            content=$(echo "$line" | sed 's/^data: //')
            if [ "$content" != "null" ] && [ -n "$content" ]; then
                echo "📝 $content"
            fi
        elif [[ $line == event:* ]]; then
            event=$(echo "$line" | sed 's/^event: //')
            echo "🔔 Evento: $event"
        fi
    done
}

# Test 1: Solo con texto (esto puede fallar)
echo "=== TEST 1: Solo texto ==="
call_medgemma "¿Cuáles son los síntomas de la diabetes?" "[]"
echo
echo "================================"
echo

# Test 2: Con imagen (este debería funcionar)
echo "=== TEST 2: Con imagen ==="
IMAGE_FILE='[{
    "path": "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png",
    "url": "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png",
    "orig_name": "bus.png",
    "size": null,
    "mime_type": "image/png",
    "is_stream": false,
    "meta": {"_type": "gradio.FileData"}
}]'

call_medgemma "Describe esta imagen desde un punto de vista médico" "$IMAGE_FILE"
echo

echo "=== Fin de las pruebas ==="