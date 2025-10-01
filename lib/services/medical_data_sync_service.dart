import './medical_preferences_service.dart';
import './supabase_service.dart';
import './medical_data_converter.dart';
import '../models/user_medical_preferences.dart';

/// Service to synchronize comprehensive medical data with chat preferences
/// Ensures that the extensive medical data collected in UserMedicalPreferences
/// is properly available to the chat system which uses UserPreferences
class MedicalDataSyncService {
  static final MedicalPreferencesService _medicalService = MedicalPreferencesService();

  /// Synchronizes medical preferences with user preferences for chat compatibility
  /// This ensures that the comprehensive medical data is available to the AI chat
  static Future<void> syncMedicalDataToChat() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return;

      // Get comprehensive medical preferences
      final medicalPrefs = await _medicalService.getUserMedicalPreferences();
      if (medicalPrefs == null) return;

      // Convert to user preferences format
      final userPrefs = MedicalDataConverter.convertToUserPreferences(medicalPrefs, userId: user.id);

      // Update user preferences in the database
      await SupabaseService.upsertUserPreferences(userPrefs);
    } catch (e) {
      print('Error syncing medical data to chat: $e');
      // Don't throw error, just log it - this is a background sync
    }
  }

  /// Gets medical preferences and ensures they are synced to chat format
  static Future<UserMedicalPreferences?> getMedicalPreferencesAndSync() async {
    try {
      final medicalPrefs = await _medicalService.getUserMedicalPreferences();
      if (medicalPrefs != null) {
        // Sync to chat format in the background
        syncMedicalDataToChat();
      }
      return medicalPrefs;
    } catch (e) {
      print('Error getting medical preferences: $e');
      return null;
    }
  }

  /// Saves medical preferences and syncs to chat format
  static Future<void> saveMedicalPreferencesAndSync(UserMedicalPreferences preferences) async {
    // Save the comprehensive medical preferences
    await _medicalService.saveMedicalPreferences(preferences);
    
    // Sync to chat format
    await syncMedicalDataToChat();
  }
}