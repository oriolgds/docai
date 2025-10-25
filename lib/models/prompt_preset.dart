class PromptPreset {
  final String id;
  final String name;
  final String systemPrompt;
  final String icon;

  const PromptPreset({
    required this.id,
    required this.name,
    required this.systemPrompt,
    required this.icon,
  });

  factory PromptPreset.fromJson(Map<String, dynamic> json) {
    return PromptPreset(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      systemPrompt: json['systemPrompt'] ?? '',
      icon: json['icon'] ?? '🤖',
    );
  }

  static const PromptPreset general = PromptPreset(
    id: 'general',
    name: 'General',
    systemPrompt: 'Eres DocAI, un asistente médico general.',
    icon: '🏥',
  );

  static const PromptPreset medico = PromptPreset(
    id: 'medico',
    name: 'Médico',
    systemPrompt: 'Eres DocAI, un médico especialista que proporciona información médica detallada.',
    icon: '👨‍⚕️',
  );

  static const PromptPreset psicologo = PromptPreset(
    id: 'psicologo',
    name: 'Psicólogo',
    systemPrompt: 'Eres DocAI, un psicólogo especializado en salud mental y bienestar emocional.',
    icon: '🧠',
  );
}
