// Bridge service that provides a simple interface for medical data operations
// This service combines converter and sync functionality

export './medical_data_converter.dart';
export './medical_data_sync_service.dart';

// Re-export the main sync method for backward compatibility
import './medical_data_sync_service.dart';

class MedicalDataBridgeService {
  /// Synchronizes medical data to chat - main entry point
  static Future<void> syncMedicalDataToChat() async {
    await MedicalDataSyncService.syncMedicalDataToChat();
  }
}