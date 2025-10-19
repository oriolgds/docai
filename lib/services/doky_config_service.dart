import '../models/doky_model_config.dart';

class DokyConfigService {
  static DokyConfigService? _instance;
  static final DokyModelConfig _defaultModel = DokyModelConfig(
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

  DokyConfigService._();

  static Future<DokyConfigService> getInstance() async {
    _instance ??= DokyConfigService._();
    return _instance!;
  }

  List<DokyModelConfig> getModels() => [_defaultModel];

  DokyModelConfig? getModelById(String id) => id == 'doky' ? _defaultModel : null;

  DokyModelConfig getDefaultModel() => _defaultModel;
}
