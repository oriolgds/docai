import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../models/model_profile.dart';

class RemoteConfigService {
  static FirebaseRemoteConfig? _remoteConfig;
  static DateTime? _lastFetch;
  static const Duration _cacheDuration = Duration(minutes: 5);
  static Future<List<ModelProfile>>? _cachedModelsFuture;
  
  static Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));
      
      // Valores por defecto
      await _remoteConfig!.setDefaults({
        'available_models': jsonEncode([
          {
            'id': 'doky',
            'brand': 'doky',
            'displayName': 'Doky',
            'modelId': 'doky-llama',
            'description': 'Asistente médico inteligente especializado.',
            'reasoning': false,
            'color1': '#3F51B5',
            'color2': '#2196F3',
            'disabled': false,
            'provider': 'doky'
          }
        ]),
        'title_generation_models': 'deepseek/deepseek-chat-v3.1:free'
      });
      
      await _fetchAndActivate();
    } catch (e) {
      // Si falla la inicialización, usar valores por defecto
    }
  }
  
  static Future<void> _fetchAndActivate() async {
    if (_remoteConfig == null) return;
    
    try {
      await _remoteConfig!.fetchAndActivate();
      _lastFetch = DateTime.now();
    } catch (e) {
      // Si falla el fetch, usar cache local
    }
  }
  
  static Future<List<ModelProfile>> getAvailableModels() async {
    if (_cachedModelsFuture != null) return _cachedModelsFuture!;
    _cachedModelsFuture = _doGetAvailableModels();
    return _cachedModelsFuture!;
  }

  static Future<List<ModelProfile>> _doGetAvailableModels() async {
    await _fetchAndActivate();

    if (_remoteConfig == null) {
      return [];
    }

    try {
      final modelsJson = _remoteConfig!.getString('available_models');
      if (modelsJson.isEmpty) {
        return [];
      }

      final List<dynamic> modelsList = jsonDecode(modelsJson);
      final models = modelsList.map((json) => _parseModelFromJson(json)).toList();
      // Filter out disabled models and non-free models (except Doky models)
      final enabledModels = models.where((model) => !model.disabled && (model.modelId.endsWith(':free') || model.provider == ModelProvider.doky)).toList();
      return enabledModels.isEmpty ? [] : enabledModels;
    } catch (e) {
      return [];
    }
  }
  
  static ModelProfile _parseModelFromJson(Map<String, dynamic> json) {
    return ModelProfile(
      id: json['id'] ?? 'unknown',
      brand: _parseBrand(json['brand']),
      tier: json['tier'] ?? '',
      displayName: json['displayName'] ?? 'Modelo desconocido',
      modelId: json['modelId'] ?? '',
      description: json['description'] ?? '',
      reasoning: json['reasoning'] ?? false,
      color1: json['color1'] ?? '#3F51B5',
      color2: json['color2'] ?? '#2196F3',
      disabled: json['disabled'] ?? false,
      provider: _parseProvider(json['provider']),
    );
  }
  
  static Future<List<String>> getTitleGenerationModels() async {
    await _fetchAndActivate();

    if (_remoteConfig == null) {
      return ['openai/gpt-3.5-turbo', 'openai/gpt-4o-mini', 'x-ai/grok-2-1212'];
    }

    try {
      final modelsStr = _remoteConfig!.getString('title_generation_models');

      // Check if title generation is disabled
      if (modelsStr.trim().toLowerCase() == 'disabled') {
        return []; // Return empty list to disable AI title generation
      }

      if (modelsStr.isEmpty) {
        return ['openai/gpt-3.5-turbo', 'openai/gpt-4o-mini', 'x-ai/grok-2-1212'];
      }

      final models = modelsStr.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList();
      return models.isEmpty ? ['openai/gpt-3.5-turbo', 'openai/gpt-4o-mini', 'x-ai/grok-2-1212'] : models;
    } catch (e) {
      return ['openai/gpt-3.5-turbo', 'openai/gpt-4o-mini', 'x-ai/grok-2-1212'];
    }
  }

  static BrandName _parseBrand(String? brandStr) {
    switch (brandStr?.toLowerCase()) {
      case 'doky':
        return BrandName.doky;
      default:
        return BrandName.doky;
    }
  }

  static ModelProvider _parseProvider(String? providerStr) {
    switch (providerStr?.toLowerCase()) {
      case 'byok':
        return ModelProvider.byok;
      case 'doky':
        return ModelProvider.doky;
      case 'openrouter':
      default:
        return ModelProvider.openrouter;
    }
  }
}