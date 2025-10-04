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
            'modelId': 'x-ai/grok-4-fast:free',
            'description': 'Asistente médico inteligente con razonamiento opcional.',
            'reasoning': false,
            'color1': '#3F51B5',
            'color2': '#2196F3'
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
      print('[DEBUG] RemoteConfigService: parsed models count = ${models.length}');
      return models.isEmpty ? [] : models;
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
    );
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