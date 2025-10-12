import '../models/model_profile.dart';
import '../models/chat_message.dart';
import 'remote_config_service.dart';
import 'openrouter_service.dart';
import 'doky_service.dart';

class ModelService {
  static OpenRouterService? _openRouterService;
  static DokyService? _dokyService;

  static OpenRouterService get _openRouter => _openRouterService ??= OpenRouterService();
  static DokyService get _doky => _dokyService ??= DokyService();

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
    // Priorizar modelo Doky
    final dokyModels = models.where((m) => m.provider == ModelProvider.doky && m.brand == BrandName.doky);
    if (dokyModels.isNotEmpty) {
      return dokyModels.first;
    }
    return models.first;
  }

  static Future<String> chatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
    bool useReasoning = false,
  }) async {
    switch (profile.provider) {
      case ModelProvider.openrouter:
      case ModelProvider.byok:
        return _openRouter.chatCompletion(
          messages: messages,
          profile: profile,
          systemPromptOverride: systemPromptOverride,
          temperature: temperature,
          useReasoning: useReasoning,
        );
      case ModelProvider.doky:
        return _doky.chatCompletion(
          messages: messages,
          profile: profile,
          systemPromptOverride: systemPromptOverride,
          temperature: temperature,
          useReasoning: useReasoning,
        );
    }
  }

  static Stream<String> streamChatCompletion({
    required List<ChatMessage> messages,
    required ModelProfile profile,
    String? systemPromptOverride,
    double temperature = 0.3,
    bool useReasoning = false,
  }) async* {
    switch (profile.provider) {
      case ModelProvider.openrouter:
      case ModelProvider.byok:
        yield* _openRouter.streamChatCompletion(
          messages: messages,
          profile: profile,
          systemPromptOverride: systemPromptOverride,
          temperature: temperature,
          useReasoning: useReasoning,
        );
        break;
      case ModelProvider.doky:
        yield* _doky.streamChatCompletion(
          messages: messages,
          profile: profile,
          systemPromptOverride: systemPromptOverride,
          temperature: temperature,
          useReasoning: useReasoning,
        );
        break;
    }
  }

  static Future<void> cancelCurrentStream(ModelProfile profile) async {
    switch (profile.provider) {
      case ModelProvider.openrouter:
      case ModelProvider.byok:
        await _openRouter.cancelCurrentStream();
        break;
      case ModelProvider.doky:
        await _doky.cancelCurrentStream();
        break;
    }
  }

  static bool isStreaming(ModelProfile profile) {
    switch (profile.provider) {
      case ModelProvider.openrouter:
      case ModelProvider.byok:
        return _openRouter.isStreaming;
      case ModelProvider.doky:
        return _doky.isStreaming;
    }
  }

  static void clearCache() {
    // No hay cache que limpiar
  }

  static Future<bool> isModelAvailable(String modelId) async {
    final models = await getAvailableModels();
    return models.any((model) => model.modelId == modelId);
  }

  static void dispose() {
    _openRouterService?.dispose();
    _dokyService?.dispose();
    _openRouterService = null;
    _dokyService = null;
  }
}