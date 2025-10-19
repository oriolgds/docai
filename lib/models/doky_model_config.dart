class DokyModelConfig {
  final String id;
  final String brand;
  final String displayName;
  final String modelId;
  final String description;
  final bool reasoning;
  final String color1;
  final String color2;
  final bool disabled;
  final String provider;
  final String? gradioUrl;

  DokyModelConfig({
    required this.id,
    required this.brand,
    required this.displayName,
    required this.modelId,
    required this.description,
    this.reasoning = false,
    required this.color1,
    required this.color2,
    this.disabled = false,
    required this.provider,
    this.gradioUrl,
  });

  factory DokyModelConfig.fromJson(Map<String, dynamic> json) {
    return DokyModelConfig(
      id: json['id'] as String,
      brand: json['brand'] as String,
      displayName: json['displayName'] as String,
      modelId: json['modelId'] as String,
      description: json['description'] as String,
      reasoning: json['reasoning'] as bool? ?? false,
      color1: json['color1'] as String,
      color2: json['color2'] as String,
      disabled: json['disabled'] as bool? ?? false,
      provider: json['provider'] as String,
      gradioUrl: json['gradioUrl'] as String?,
    );
  }
}
