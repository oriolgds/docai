import 'package:flutter/material.dart';

enum BrandName { feya, gaia, heynos }

String brandDisplayName(BrandName b) {
  switch (b) {
    case BrandName.feya:
      return 'Feya';
    case BrandName.gaia:
      return 'Gaia';
    case BrandName.heynos:
      return 'Heynos';
  }
}

Color brandColor(BrandName b) {
  switch (b) {
    case BrandName.feya:
      return Colors.teal;
    case BrandName.gaia:
      return Colors.indigo;
    case BrandName.heynos:
      return Colors.deepPurple;
  }
}

class ModelProfile {
  final String id; // e.g., 'gaia_balanced'
  final BrandName brand;
  final String tier; // e.g., 'Balanced', 'Reasoning', 'Pro'
  final String displayName; // e.g., 'Gaia • Balanced'
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
        // Feya (sencillo)
        ModelProfile(
          id: 'feya_instant',
          brand: BrandName.feya,
          tier: 'Instant',
          displayName: 'Feya • Instant',
          modelId: 'google/gemini-2.0-flash-exp:free',
          description: 'Respuestas rápidas y concisas para dudas cotidianas.',
        ),
        ModelProfile(
          id: 'feya_balanced',
          brand: BrandName.feya,
          tier: 'Balanced',
          displayName: 'Feya • Balanced',
          modelId: 'meta-llama/llama-4-maverick:free',
          description: 'Equilibrio entre velocidad y calidad.',
        ),

        // Gaia (normal)
        ModelProfile(
          id: 'gaia_balanced',
          brand: BrandName.gaia,
          tier: 'Balanced',
          displayName: 'Gaia • Balanced',
          modelId: 'deepseek/deepseek-chat-v3.1:free',
          description: 'Calidad consistente para consultas de salud generales.',
        ),
        ModelProfile(
          id: 'gaia_reasoning',
          brand: BrandName.gaia,
          tier: 'Reasoning',
          displayName: 'Gaia • Reasoning',
          modelId: 'deepseek/deepseek-r1-distill-llama-70b:free',
          description: 'Mejor capacidad de razonamiento para casos complejos.',
          reasoning: true,
        ),

        // Heynos (pro)
        ModelProfile(
          id: 'heynos_fast',
          brand: BrandName.heynos,
          tier: 'Fast',
          displayName: 'Heynos • Fast',
          modelId: 'x-ai/grok-4-fast:free',
          description: 'Velocidad pro con buena calidad.',
        ),
        ModelProfile(
          id: 'heynos_pro',
          brand: BrandName.heynos,
          tier: 'Pro',
          displayName: 'Heynos • Pro',
          modelId: 'deepseek/deepseek-r1-distill-llama-70b:free',
          description: 'Razonamiento avanzado para consultas exigentes.',
          reasoning: true,
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
      defaults().firstWhere((p) => p.id == 'gaia_balanced', orElse: () => defaults().first);
}
