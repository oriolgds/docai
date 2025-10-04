import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../models/model_profile.dart';

class RemoteConfigService {
  static FirebaseRemoteConfig? _remoteConfig;
  static DateTime? _lastFetch;
  static const Duration _cacheDuration = Duration(minutes: 5);
  
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
            'displayName': 'Doky 1.0',
            'modelId': 'deepseek/deepseek-chat-v3.1:free',
            'description': 'Asistente médico inteligente con razonamiento opcional.',
            'reasoning': false,
            'color1': '#3F51B5',
            'color2': '#2196F3',
            'disabled': false
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
    await _fetchAndActivate();

    if (_remoteConfig == null) {
      print('[DEBUG] RemoteConfigService: _remoteConfig is null');
      return [];
    }

    try {
      final modelsJson = _remoteConfig!.getString('available_models');
      print('[DEBUG] RemoteConfigService: modelsJson = $modelsJson');
      if (modelsJson.isEmpty) {
        print('[DEBUG] RemoteConfigService: modelsJson is empty');
        return [];
      }

      final List<dynamic> modelsList = jsonDecode(modelsJson);
      print('[DEBUG] RemoteConfigService: modelsList length = ${modelsList.length}');
      final models = modelsList.map((json) => _parseModelFromJson(json)).toList();
      // Filter out disabled models and non-free models
      final enabledModels = models.where((model) => !model.disabled && model.modelId.endsWith(':free')).toList();
      print('[DEBUG] RemoteConfigService: parsed models count = ${models.length}, enabled models count = ${enabledModels.length}');
      return enabledModels.isEmpty ? [] : enabledModels;
    } catch (e) {
      print('[DEBUG] RemoteConfigService: Error getting available models: $e');
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
    );
  }
  
  static Future<List<String>> getTitleGenerationModels() async {
    await _fetchAndActivate();

    if (_remoteConfig == null) {
      print('[DEBUG] RemoteConfigService: _remoteConfig is null, using defaults');
      return ['openai/gpt-3.5-turbo', 'openai/gpt-4o-mini', 'x-ai/grok-2-1212'];
    }

    try {
      final modelsStr = _remoteConfig!.getString('title_generation_models');
      print('[DEBUG] RemoteConfigService: title_generation_models = $modelsStr');

      // Check if title generation is disabled
      if (modelsStr.trim().toLowerCase() == 'disabled') {
        print('[DEBUG] RemoteConfigService: title generation is disabled');
        return []; // Return empty list to disable AI title generation
      }

      if (modelsStr.isEmpty) {
        print('[DEBUG] RemoteConfigService: title_generation_models is empty, using defaults');
        return ['openai/gpt-3.5-turbo', 'openai/gpt-4o-mini', 'x-ai/grok-2-1212'];
      }

      final models = modelsStr.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList();
      print('[DEBUG] RemoteConfigService: parsed title generation models = $models');
      return models.isEmpty ? ['openai/gpt-3.5-turbo', 'openai/gpt-4o-mini', 'x-ai/grok-2-1212'] : models;
    } catch (e) {
      print('[DEBUG] RemoteConfigService: Error getting title generation models: $e');
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
}