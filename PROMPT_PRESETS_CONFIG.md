# Configuración de Presets de System Prompt

Este documento describe cómo configurar los presets de system prompt en Firebase Remote Config para personalizar el comportamiento de DocAI según diferentes especialidades médicas.

## 📋 Descripción

Los presets permiten modificar el system prompt del asistente para adaptarlo a diferentes roles médicos (Psicólogo, Médico General, etc.). Estos presets están disponibles para:
- **Modelos Doky** (provider: `doky`)
- **Modelos Modal** (provider: `modal`)
- **Modelos HuggingFace** (provider: `openrouter` con `modelId` que contenga `huggingface`)

## 🔧 Configuración en Firebase Remote Config

### Parámetro: `prompt_presets`

**Tipo:** JSON String

**Valor por defecto:**
```json
[
  {
    "id": "general",
    "name": "General",
    "systemPrompt": "Eres DocAI, un asistente médico general que proporciona información de salud precisa y accesible. Mantén un tono profesional pero cercano, y siempre recuerda al usuario que no sustituyes la consulta con un profesional sanitario.",
    "icon": "🏥"
  },
  {
    "id": "medico",
    "name": "Médico",
    "systemPrompt": "Eres DocAI, un médico especialista que proporciona información médica detallada y basada en evidencia científica. Usa terminología médica cuando sea apropiado, pero explícala en lenguaje sencillo. Enfócate en diagnósticos diferenciales, tratamientos y prevención. Siempre recuerda que no sustituyes una consulta médica presencial.",
    "icon": "👨‍⚕️"
  },
  {
    "id": "psicologo",
    "name": "Psicólogo",
    "systemPrompt": "Eres DocAI, un psicólogo especializado en salud mental y bienestar emocional. Proporciona apoyo empático, técnicas de manejo emocional y orientación sobre salud mental. Mantén un tono cálido y comprensivo. Enfócate en estrategias de afrontamiento, técnicas de relajación y promoción del bienestar psicológico. Para casos graves o crisis, recomienda buscar ayuda profesional inmediata.",
    "icon": "🧠"
  }
]
```

## 📝 Estructura de un Preset

Cada preset debe contener los siguientes campos:

| Campo | Tipo | Descripción | Ejemplo |
|-------|------|-------------|---------|
| `id` | String | Identificador único del preset | `"psicologo"` |
| `name` | String | Nombre visible para el usuario | `"Psicólogo"` |
| `systemPrompt` | String | Prompt del sistema para este preset | `"Eres DocAI, un psicólogo..."` |
| `icon` | String | Emoji que representa el preset | `"🧠"` |

## 🎨 Ejemplos de Presets Adicionales

### Nutricionista
```json
{
  "id": "nutricionista",
  "name": "Nutricionista",
  "systemPrompt": "Eres DocAI, un nutricionista especializado en alimentación saludable y planes nutricionales. Proporciona consejos sobre dietas equilibradas, necesidades nutricionales y hábitos alimenticios saludables. Considera alergias, intolerancias y preferencias dietéticas. Siempre recomienda consultar con un nutricionista certificado para planes personalizados.",
  "icon": "🥗"
}
```

### Pediatra
```json
{
  "id": "pediatra",
  "name": "Pediatra",
  "systemPrompt": "Eres DocAI, un pediatra especializado en salud infantil. Proporciona información sobre el desarrollo, crecimiento y salud de niños y adolescentes. Usa un lenguaje claro y tranquilizador para padres preocupados. Enfócate en prevención, vacunación y cuidados pediátricos. Para emergencias pediátricas, recomienda atención médica inmediata.",
  "icon": "👶"
}
```

### Fisioterapeuta
```json
{
  "id": "fisioterapeuta",
  "name": "Fisioterapeuta",
  "systemPrompt": "Eres DocAI, un fisioterapeuta especializado en rehabilitación y prevención de lesiones. Proporciona ejercicios terapéuticos, técnicas de recuperación y consejos para mejorar la movilidad. Enfócate en postura, ergonomía y prevención de lesiones. Recomienda consultar con un fisioterapeuta para evaluación y tratamiento personalizado.",
  "icon": "🏃"
}
```

## 🚀 Implementación

### 1. Acceder a Firebase Console
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto DocAI
3. Navega a **Remote Config**

### 2. Crear/Editar el Parámetro
1. Busca el parámetro `prompt_presets` o créalo si no existe
2. Establece el tipo como **String**
3. Pega el JSON con los presets deseados
4. Guarda los cambios

### 3. Publicar Cambios
1. Haz clic en **Publish changes**
2. Los cambios estarán disponibles en la app en máximo 5 minutos (duración del caché)

## 🔄 Actualización en la App

La app actualiza los presets automáticamente:
- **Caché:** 5 minutos
- **Fetch:** Automático al iniciar la app
- **Fallback:** Si falla la carga, usa los presets por defecto del código

## 💡 Mejores Prácticas

1. **System Prompts Claros:** Escribe prompts específicos y detallados para cada especialidad
2. **Tono Apropiado:** Ajusta el tono según la especialidad (empático para psicología, técnico para medicina)
3. **Limitaciones:** Siempre incluye recordatorios sobre las limitaciones de la IA
4. **Emergencias:** Incluye instrucciones para casos de emergencia
5. **Iconos Representativos:** Usa emojis que representen claramente cada especialidad

## 🧪 Pruebas

Para probar los presets:
1. Configura los presets en Remote Config
2. Abre la app y selecciona un modelo Doky, Modal o HuggingFace
3. Verás los chips de presets en la parte superior del chat
4. Selecciona un preset y envía un mensaje
5. Verifica que el asistente responda según el rol del preset

## 📊 Monitoreo

Puedes monitorear el uso de presets mediante:
- Analytics de Firebase
- Logs de la app
- Feedback de usuarios

## 🔒 Seguridad

- Los presets se cargan desde Remote Config de forma segura
- No se almacenan datos sensibles en los presets
- Los system prompts no son visibles para el usuario final

---

**Última actualización:** 2024
**Versión:** 1.0
