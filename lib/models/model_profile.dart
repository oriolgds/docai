import 'package:flutter/material.dart';

enum BrandName { doky }

enum ModelProvider { openrouter, byok, huggingface }

String brandDisplayName(BrandName b) {
  switch (b) {
    case BrandName.doky:
      return 'Doky 1.0';
  }
}

Color brandColor(BrandName b) {
  switch (b) {
    case BrandName.doky:
      return Colors.indigo;
  }
}

class ModelProfile {
  final String id; // e.g., 'doky'
  final BrandName brand;
  final String tier; // Ya no se usa pero se mantiene para compatibilidad
  final String displayName; // e.g., 'Doky 1'
  final String modelId; // OpenRouter model string or HF endpoint
  final String description;
  final bool reasoning;
  final String color1; // Color primario del degradado
  final String color2; // Color secundario del degradado
  final bool disabled; // Si el modelo está deshabilitado
  final ModelProvider provider; // Provider del modelo

  const ModelProfile({
    required this.id,
    required this.brand,
    required this.tier,
    required this.displayName,
    required this.modelId,
    required this.description,
    this.reasoning = false,
    this.color1 = '#3F51B5',
    this.color2 = '#2196F3',
    this.disabled = false,
    this.provider = ModelProvider.openrouter,
  });
  
  Color get primaryColor => Color(int.parse(color1.replaceFirst('#', '0xFF')));
  Color get secondaryColor => Color(int.parse(color2.replaceFirst('#', '0xFF')));

  static List<ModelProfile> defaults() => const [
        // Solo Doky 1, sin subcategorías
        ModelProfile(
          id: 'doky',
          brand: BrandName.doky,
          tier: '', // Sin tier/subcategoría
          displayName: 'Doky 1.0',
          modelId: 'x-ai/grok-4-fast:free',
          description: 'Asistente médico inteligente con razonamiento opcional.',
          color1: '#3F51B5',
          color2: '#2196F3',
        ),
      ];

  static Map<BrandName, List<ModelProfile>> groupedByBrand() {
    final map = <BrandName, List<ModelProfile>>{};
    for (final p in defaults()) {
      map.putIfAbsent(p.brand, () => []).add(p);
    }
    return map;
  }

  static ModelProfile get defaultProfile =>
      defaults().firstWhere((p) => p.id == 'doky', orElse: () => defaults().first);
}
