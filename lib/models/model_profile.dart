import 'package:flutter/material.dart';

enum BrandName { gaia }

String brandDisplayName(BrandName b) {
  switch (b) {
    case BrandName.gaia:
      return 'Gaia';
  }
}

Color brandColor(BrandName b) {
  switch (b) {
    case BrandName.gaia:
      return Colors.indigo;
  }
}

class ModelProfile {
  final String id; // e.g., 'gaia'
  final BrandName brand;
  final String tier; // Ya no se usa pero se mantiene para compatibilidad
  final String displayName; // e.g., 'Gaia'
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
        // Solo Gaia, sin subcategorías
        ModelProfile(
          id: 'gaia',
          brand: BrandName.gaia,
          tier: '', // Sin tier/subcategoría
          displayName: 'Gaia',
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
      defaults().firstWhere((p) => p.id == 'gaia', orElse: () => defaults().first);
}
