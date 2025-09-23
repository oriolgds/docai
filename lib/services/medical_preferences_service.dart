import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_medical_preferences.dart';

class MedicalPreferencesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene las preferencias médicas del usuario actual
  Future<UserMedicalPreferences?> getUserMedicalPreferences() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('user_medical_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      
      return UserMedicalPreferences.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener preferencias médicas: $e');
    }
  }

  /// Guarda o actualiza las preferencias médicas del usuario
  Future<UserMedicalPreferences> saveMedicalPreferences(
    UserMedicalPreferences preferences,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Verificar si ya existen preferencias
      final existing = await getUserMedicalPreferences();
      
      final data = preferences.copyWith(userId: userId).toJson();
      data.remove('id'); // No incluir ID en la inserción/actualización
      data.remove('created_at'); // Será manejado por la base de datos
      data.remove('updated_at'); // Será manejado por el trigger

      Map<String, dynamic> response;
      
      if (existing != null) {
        // Actualizar preferencias existentes
        response = await _supabase
            .from('user_medical_preferences')
            .update(data)
            .eq('user_id', userId)
            .select()
            .single();
      } else {
        // Crear nuevas preferencias
        response = await _supabase
            .from('user_medical_preferences')
            .insert(data)
            .select()
            .single();
      }

      return UserMedicalPreferences.fromJson(response);
    } catch (e) {
      throw Exception('Error al guardar preferencias médicas: $e');
    }
  }

  /// Elimina las preferencias médicas del usuario
  Future<void> deleteMedicalPreferences() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase
          .from('user_medical_preferences')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error al eliminar preferencias médicas: $e');
    }
  }

  /// Obtiene el contexto médico personalizado para el chat
  Future<String> getMedicalContext() async {
    try {
      final preferences = await getUserMedicalPreferences();
      if (preferences == null) {
        return "IMPORTANTE: DocAI no sustituye el consejo médico profesional. "
               "La información proporcionada tiene fines educativos. "
               "Para diagnósticos, tratamientos o emergencias acude a un profesional de la salud.";
      }
      
      return preferences.generateMedicalContext();
    } catch (e) {
      return "Error al cargar el contexto médico. "
             "IMPORTANTE: DocAI no sustituye el consejo médico profesional.";
    }
  }
}
