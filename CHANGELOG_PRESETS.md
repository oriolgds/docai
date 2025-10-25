# Changelog - Sistema de Presets de System Prompt

## 📅 Fecha: 2024

## 🎯 Objetivo
Implementar un sistema de presets dinámicos que permitan modificar el system prompt según diferentes especialidades médicas (Psicólogo, Médico, General) para los modelos Doky, HuggingFace y Modal.

## ✨ Nuevas Funcionalidades

### 1. Modelo de Preset (`lib/models/prompt_preset.dart`)
- ✅ Clase `PromptPreset` con campos: `id`, `name`, `systemPrompt`, `icon`
- ✅ Factory method `fromJson` para deserialización
- ✅ Presets por defecto: General, Médico, Psicólogo

### 2. Servicio de Remote Config Actualizado (`lib/services/remote_config_service.dart`)
- ✅ Nuevo método `getPromptPresets()` para obtener presets desde Firebase
- ✅ Valores por defecto configurados en `setDefaults`
- ✅ Soporte para JSON de presets en Remote Config
- ✅ Fallback a presets por defecto si falla la carga

### 3. Servicio de System Prompt Actualizado (`lib/services/system_prompt_service.dart`)
- ✅ Soporte para presets en `getSystemPrompt()`
- ✅ Método `setPreset()` para cambiar el preset activo
- ✅ Método `getCurrentPreset()` para obtener el preset actual
- ✅ Método `getAvailablePresets()` para listar presets disponibles
- ✅ Integración con Remote Config

### 4. Integración en ChatInput (`lib/widgets/chat/chat_input.dart`)
- ✅ Chips de presets integrados en la misma fila del selector de modelos
- ✅ Scroll horizontal para múltiples presets
- ✅ Selección visual con colores y estados
- ✅ Iconos emoji para cada preset
- ✅ Propiedades: `presets`, `selectedPreset`, `onPresetChanged`

### 5. Actualización de Chat Screen (`lib/screens/home/chat_screen.dart`)
- ✅ Variables de estado: `_selectedPreset`, `_availablePresets`
- ✅ Método `_loadPresets()` para cargar presets al iniciar
- ✅ Integración del preset en `_buildPersonalizedSystemPrompt()`
- ✅ Presets pasados a ChatInput solo para providers compatibles:
  - Doky (`ModelProvider.doky`)
  - Modal (`ModelProvider.modal`)
  - HuggingFace (OpenRouter con `modelId` que contenga "huggingface")
- ✅ Actualización del estado al cambiar preset

## 📚 Documentación

### 1. Guía de Configuración (`PROMPT_PRESETS_CONFIG.md`)
- ✅ Descripción completa del sistema
- ✅ Estructura JSON de presets
- ✅ Ejemplos de presets adicionales (Nutricionista, Pediatra, Fisioterapeuta)
- ✅ Instrucciones paso a paso para Firebase Remote Config
- ✅ Mejores prácticas y recomendaciones
- ✅ Guía de pruebas

### 2. README Actualizado (`README.md`)
- ✅ Nueva sección "System Prompt Presets"
- ✅ Lista de presets disponibles
- ✅ Providers soportados
- ✅ Referencia a documentación detallada
- ✅ Troubleshooting actualizado

## 🔧 Configuración de Firebase Remote Config

### Parámetro Nuevo: `prompt_presets`
```json
[
  {
    "id": "general",
    "name": "General",
    "systemPrompt": "Eres DocAI, un asistente médico general...",
    "icon": "🏥"
  },
  {
    "id": "medico",
    "name": "Médico",
    "systemPrompt": "Eres DocAI, un médico especialista...",
    "icon": "👨⚕️"
  },
  {
    "id": "psicologo",
    "name": "Psicólogo",
    "systemPrompt": "Eres DocAI, un psicólogo especializado...",
    "icon": "🧠"
  }
]
```

## 🎨 Experiencia de Usuario

### Antes
- System prompt fijo para todos los modelos
- Sin personalización por especialidad
- Mismo tono para todas las consultas

### Después
- ✅ Presets integrados en la misma fila del selector de modelos
- ✅ Interfaz compacta y eficiente
- ✅ Cambio dinámico de especialidad sin reiniciar
- ✅ Iconos visuales para identificar cada preset
- ✅ Feedback visual del preset seleccionado
- ✅ Tono y enfoque adaptado a la especialidad elegida

## 🔄 Flujo de Funcionamiento

1. **Carga Inicial**
   - App inicia y carga presets desde Remote Config
   - Si falla, usa presets por defecto del código
   - Cache de 5 minutos para optimizar rendimiento

2. **Selección de Modelo**
   - Usuario selecciona un modelo Doky, Modal o HuggingFace
   - Presets aparecen automáticamente en la misma fila
   - Presets disponibles se muestran como chips con scroll horizontal

3. **Cambio de Preset**
   - Usuario toca un chip de preset
   - Estado se actualiza inmediatamente
   - Próximo mensaje usará el nuevo system prompt

4. **Envío de Mensaje**
   - System prompt se construye con el preset seleccionado
   - Se combina con preferencias médicas del usuario
   - Mensaje se envía al modelo con el prompt personalizado

## 🧪 Testing

### Casos de Prueba
1. ✅ Carga de presets desde Remote Config
2. ✅ Fallback a presets por defecto
3. ✅ Cambio de preset durante conversación
4. ✅ Persistencia del preset seleccionado
5. ✅ Visualización correcta de iconos
6. ✅ Integración con preferencias médicas
7. ✅ Compatibilidad con diferentes providers

## 📊 Impacto

### Beneficios
- ✨ **Personalización mejorada**: Usuarios pueden elegir el tono y enfoque del asistente
- 🎯 **Especialización**: Respuestas más relevantes según la especialidad
- 🔄 **Flexibilidad**: Cambios de configuración sin actualizar la app
- 📱 **UX mejorada**: Interfaz visual intuitiva con chips
- 🌐 **Escalabilidad**: Fácil agregar nuevos presets desde Remote Config

### Métricas Esperadas
- ↑ **Satisfacción del usuario**: Respuestas más relevantes
- ↑ **Engagement**: Mayor uso de diferentes especialidades
- ↓ **Confusión**: Claridad en el rol del asistente
- ↑ **Flexibilidad**: Adaptación a diferentes necesidades

## 🚀 Próximos Pasos

### Mejoras Futuras
1. **Analytics**: Tracking de uso de presets
2. **Presets Personalizados**: Permitir a usuarios crear sus propios presets
3. **Recomendaciones**: Sugerir preset según el tipo de consulta
4. **Historial**: Recordar último preset usado por usuario
5. **A/B Testing**: Probar diferentes system prompts

### Presets Adicionales Sugeridos
- 🥗 Nutricionista
- 👶 Pediatra
- 🏃 Fisioterapeuta
- 💊 Farmacéutico
- 🦷 Odontólogo
- 👁️ Oftalmólogo

## 📝 Notas Técnicas

### Dependencias
- Firebase Remote Config
- Flutter Material Design
- Existing model service architecture

### Compatibilidad
- ✅ Android
- ✅ iOS
- ✅ Web (si está habilitado)

### Performance
- Cache de 5 minutos en Remote Config
- Carga asíncrona de presets
- Sin impacto en tiempo de respuesta del chat

## 🔐 Seguridad

- ✅ Presets cargados de forma segura desde Firebase
- ✅ No se exponen system prompts al usuario final
- ✅ Validación de estructura JSON
- ✅ Fallback seguro en caso de error

---

**Desarrollado por**: Oriol Giner Díaz  
**Versión**: 1.0  
**Estado**: ✅ Completado
