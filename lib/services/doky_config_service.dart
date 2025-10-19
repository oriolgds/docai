import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import '../models/doky_model_config.dart';

class DokyConfigService {
  static DokyConfigService? _instance;
  final FirebaseRemoteConfig _remoteConfig;
  List<DokyModelConfig>? _cachedModels;

  DokyConfigService._(this._remoteConfig);

  static Future<DokyConfigService> getInstance() async {
    if (_instance != null) return _instance!;

    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 5),
    ));

    await remoteConfig.setDefaults({
      'doky_models': jsonEncode([
        {
          'id': 'doky',
          'brand': 'doky',
          'displayName': 'Doky 1.0',
          'modelId': 'doky-opus',
          'description': 'Modelo médico principal',
          'reasoning': false,
          'color1': '#3F51B5',
          'color2': '#2196F3',
          'disabled': false,
          'provider': 'doky',
          'gradioUrl': 'https://oriolgds-doky-opus.hf.space',
        }
      ])
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error fetching remote config: $e');
    }

    _instance = DokyConfigService._(remoteConfig);
    return _instance!;
  }

  List<DokyModelConfig> getModels() {
    if (_cachedModels != null) return _cachedModels!;

    try {
      final jsonString = _remoteConfig.getString('doky_models');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedModels = jsonList
          .map((json) => DokyModelConfig.fromJson(json))
          .where((model) => !model.disabled)
          .toList();
      return _cachedModels!;
    } catch (e) {
      debugPrint('Error parsing doky_models: $e');
      return [];
    }
  }

  DokyModelConfig? getModelById(String id) {
    return getModels().where((m) => m.id == id).firstOrNull;
  }

  DokyModelConfig getDefaultModel() {
    final models = getModels();
    return models.isNotEmpty ? models.first : _fallbackModel();
  }

  DokyModelConfig _fallbackModel() {
    return DokyModelConfig(
      id: 'doky',
      brand: 'doky',
      displayName: 'Doky 1.0',
      modelId: 'doky-opus',
      description: 'Modelo médico principal',
      color1: '#3F51B5',
      color2: '#2196F3',
      provider: 'doky',
      gradioUrl: 'https://oriolgds-doky-opus.hf.space',
    );
  }

  Future<void> refresh() async {
    _cachedModels = null;
    await _remoteConfig.fetchAndActivate();
  }
}
