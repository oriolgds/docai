import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../models/model_profile.dart';
import '../models/prompt_preset.dart';

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
      
      // Valores por defecto - Nueva estructura simplificada
      // Eliminados campos redundantes: id, brand
      // El brand se deriva automáticamente del provider
      await _remoteConfig!.setDefaults({
        'available_models': jsonEncode([
          {
            'modelId': 'doky-llama',
            'displayName': 'Doky 1.0',
            'description': 'Asistente médico inteligente especializado.',
            'provider': 'doky',
            'color1': '#3F51B5',
            'color2': '#2196F3',
            'reasoning': false,
            'disabled': false,
            'default': true
          }
        ]),
        'maintenance': false,
        'system_prompt': '',
        'modal_daily_limit': 5,
        'prompt_presets': jsonEncode([
          {
            'id': 'general',
            'name': 'General',
            'systemPrompt': 'Eres DocAI, un asistente médico general.',
            'icon': '🏥'
          },
          {
            'id': 'medico',
            'name': 'Médico',
            'systemPrompt': 'Eres DocAI, un médico especialista que proporciona información médica detallada.',
            'icon': '👨⚕️'
          },
          {
            'id': 'psicologo',
            'name': 'Psicólogo',
            'systemPrompt': 'Eres DocAI, un psicólogo especializado en salud mental y bienestar emocional.',
            'icon': '🧠'
          }
        ])
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
      // Filter out disabled models and non-free models (except Doky and Modal models)
      final enabledModels = models.where((model) => !model.disabled && (model.modelId.endsWith(':free') || model.provider == ModelProvider.doky || model.provider == ModelProvider.modal || model.provider == ModelProvider.openrouter)).toList();
      return enabledModels.isEmpty ? [] : enabledModels;
    } catch (e) {
      return [];
    }
  }
  
  static ModelProfile _parseModelFromJson(Map<String, dynamic> json) {
    // Nueva estructura simplificada - campos requeridos:
    // - modelId: identificador único del modelo
    // - displayName: nombre para mostrar
    // - provider: tipo de provider (doky, byok, openrouter, modal)
    // - description, color1, color2, reasoning, disabled, default: opcionales

    // Compatibilidad con JSON viejo: también acepta 'id' como fallback de modelId
    // y 'type' como fallback de provider
    final modelId = json['modelId'] ?? json['id'] ?? 'unknown';
    final provider = _parseProvider(json['provider'] ?? json['type']);

    // Derivar brand del provider para compatibilidad con UI
    final brand = _deriveBrandFromProvider(provider);

    return ModelProfile(
      id: modelId,
      brand: brand,
      tier: json['tier'] ?? '',
      displayName: json['displayName'] ?? 'Modelo desconocido',
      modelId: modelId,
      description: json['description'] ?? '',
      reasoning: json['reasoning'] ?? false,
      color1: json['color1'] ?? '#3F51B5',
      color2: json['color2'] ?? '#2196F3',
      disabled: json['disabled'] ?? false,
      provider: provider,
      isDefault: json['default'] == 'true' || json['default'] == true,
    );
  }
  
  static Future<List<String>> getTitleGenerationModels() async {
    // ❌ ELIMINADO: Sistema de generación de títulos con OpenRouter
    // ✅ AHORA: Se usa TitleGeneratorService con HuggingFace Space automáticamente
    return [];
  }

  static BrandName _deriveBrandFromProvider(ModelProvider provider) {
    switch (provider) {
      case ModelProvider.doky:
        return BrandName.doky;
      case ModelProvider.byok:
      case ModelProvider.openrouter:
        return BrandName.byok;
      case ModelProvider.modal:
        return BrandName.doky; // Modal models also use doky brand for now
    }
  }

  static ModelProvider _parseProvider(String? providerStr) {
    switch (providerStr?.toLowerCase()) {
      case 'byok':
        return ModelProvider.byok;
      case 'doky':
        return ModelProvider.doky;
      case 'modal':
        return ModelProvider.modal;
      case 'openrouter':
      default:
        return ModelProvider.openrouter;
    }
  }

  static Future<bool> isMaintenanceMode() async {
    await _fetchAndActivate();
    if (_remoteConfig == null) return false;
    try {
      return _remoteConfig!.getBool('maintenance');
    } catch (e) {
      return false;
    }
  }

  static Future<String> getSystemPrompt() async {
    await _fetchAndActivate();
    if (_remoteConfig == null) return '';
    try {
      return _remoteConfig!.getString('system_prompt');
    } catch (e) {
      return '';
    }
  }

  static Future<int> getModalDailyLimit() async {
    await _fetchAndActivate();
    if (_remoteConfig == null) return 5;
    try {
      return _remoteConfig!.getInt('modal_daily_limit');
    } catch (e) {
      return 5;
    }
  }

  static Future<List<PromptPreset>> getPromptPresets() async {
    await _fetchAndActivate();
    if (_remoteConfig == null) {
      return [PromptPreset.general, PromptPreset.medico, PromptPreset.psicologo];
    }
    try {
      final presetsJson = _remoteConfig!.getString('prompt_presets');
      if (presetsJson.isEmpty) {
        return [PromptPreset.general, PromptPreset.medico, PromptPreset.psicologo];
      }
      final List<dynamic> presetsList = jsonDecode(presetsJson);
      return presetsList.map((json) => PromptPreset.fromJson(json)).toList();
    } catch (e) {
      return [PromptPreset.general, PromptPreset.medico, PromptPreset.psicologo];
    }
  }
}