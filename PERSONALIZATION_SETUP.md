# Configuración de Personalización DocAI

## Configuración de la Base de Datos

Para activar la funcionalidad de personalización, ejecuta el siguiente comando SQL en tu consola de Supabase:

```sql
-- Tabla para preferencias de personalización del usuario
CREATE TABLE public.user_preferences (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  allergies text[], -- Array de alergias
  medicine_preference text NOT NULL DEFAULT 'both' CHECK (medicine_preference IN ('natural', 'conventional', 'both')),
  chronic_conditions text[], -- Array de condiciones crónicas
  current_medications text[], -- Array de medicamentos actuales
  age_range text CHECK (age_range IN ('0-17', '18-35', '36-55', '56-75', '75+')),
  gender text CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  additional_notes text,
  is_first_time boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_preferences_user_id_key UNIQUE (user_id)
) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON public.user_preferences USING btree (user_id) TABLESPACE pg_default;

-- RLS policies para user_preferences
ALTER TABLE public.user_preferences ENABLE row level security;

CREATE POLICY "Users can view own preferences" ON public.user_preferences
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences" ON public.user_preferences
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences" ON public.user_preferences
  FOR UPDATE USING (auth.uid() = user_id);
```

## Funcionalidades Implementadas

### 1. **Pantalla de Personalización**
- Accesible desde el perfil del usuario
- Configuración de información básica (edad, género)
- Preferencias médicas (medicina natural, convencional, o ambas)
- Información médica (alergias, condiciones crónicas, medicamentos actuales)
- Notas adicionales

### 2. **Advertencia de Primera Vez**
- Se muestra automáticamente en el chat para usuarios nuevos
- Invita a personalizar la experiencia
- Se puede cerrar o acceder directamente a personalización
- No vuelve a aparecer después de ser cerrada

### 3. **Integración con Supabase**
- Almacenamiento seguro de preferencias
- Row Level Security (RLS) activado
- Métodos CRUD completos en SupabaseService

### 4. **Modelo de Datos**
```dart
// Campos principales de UserPreferences:
- allergies: List<String>
- medicine_preference: MedicinePreference (natural/conventional/both)
- chronic_conditions: List<String>
- current_medications: List<String>
- age_range: AgeRange
- gender: Gender
- additional_notes: String?
- is_first_time: bool
```

## Archivos Modificados/Creados

### Nuevos archivos:
- `lib/models/user_preferences.dart` - Modelo de datos
- `lib/screens/home/personalization_screen.dart` - Pantalla de personalización
- `PERSONALIZATION_SETUP.md` - Este archivo de configuración

### Archivos modificados:
- `lib/services/supabase_service.dart` - Añadidos métodos para preferencias
- `lib/screens/home/profile_screen.dart` - Añadido botón de personalización
- `lib/screens/home/chat_screen.dart` - Añadida advertencia de primera vez
- `supabase/table structure.txt` - Añadida estructura de tabla

## Próximos Pasos

1. **Ejecutar el SQL** en la consola de Supabase
2. **Probar la funcionalidad**:
   - Nuevo usuario debería ver la advertencia en el chat
   - Acceso a personalización desde el perfil
   - Guardado y carga de preferencias
3. **Usar las preferencias** en el contexto de la IA (próxima implementación)

## Uso de las Preferencias

Las preferencias del usuario pueden ser recuperadas en cualquier momento con:

```dart
final preferences = await SupabaseService.getUserPreferences();
```

Esto permite personalizar las respuestas de la IA basándose en:
- Alergias conocidas
- Preferencias de medicina
- Condiciones médicas existentes
- Medicamentos actuales
- Información demográfica