import 'package:flutter/material.dart';

enum BrandName { doky }

String brandDisplayName(BrandName b) {
  switch (b) {
    case BrandName.doky:
      return 'Doky 1';
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
  final String modelId; // OpenRouter model string
  final String description;
  final bool reasoning;

  const ModelProfile({
    required this.id,
    required this.brand,
    required this.tier,
    required this.displayName,
    required this.modelId,
    required this.description,
    this.reasoning = false,
  });

  static List<ModelProfile> defaults() => const [
        // Solo Doky 1, sin subcategorías
        ModelProfile(
          id: 'doky',
          brand: BrandName.doky,
          tier: '', // Sin tier/subcategoría
          displayName: 'Doky 1',
          modelId: 'x-ai/grok-4-fast:free',
          description: 'Asistente médico inteligente con razonamiento opcional.',
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
