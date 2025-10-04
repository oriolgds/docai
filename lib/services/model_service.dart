import '../models/model_profile.dart';
import 'remote_config_service.dart';

class ModelService {
  static Future<List<ModelProfile>> getAvailableModels() async {
    try {
      final models = await RemoteConfigService.getAvailableModels();
      return models;
    } catch (e) {
      // Si falla, retornar lista vacía
      return [];
    }
  }
  
  static Future<ModelProfile?> getModelById(String id) async {
    final models = await getAvailableModels();
    try {
      return models.firstWhere((model) => model.id == id);
    } catch (e) {
      return null;
    }
  }
  
  static Future<ModelProfile?> getDefaultModel() async {
    final models = await getAvailableModels();
    if (models.isEmpty) {
      return null;
    }
    return models.first;
  }
  
  static void clearCache() {
    // No hay cache que limpiar
  }
  
  static Future<bool> isModelAvailable(String modelId) async {
    final models = await getAvailableModels();
    return models.any((model) => model.modelId == modelId);
  }
}