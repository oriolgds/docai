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
    print('[DEBUG] ModelService.getModelById: Searching for model with id = $id');
    final models = await getAvailableModels();
    print('[DEBUG] ModelService.getModelById: Available models count = ${models.length}');
    try {
      final model = models.firstWhere((model) => model.id == id);
      print('[DEBUG] ModelService.getModelById: Found model = ${model.displayName}');
      return model;
    } catch (e) {
      print('[DEBUG] ModelService.getModelById: Model with id $id not found');
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