enum MessageRole {
  user,
  assistant,
  system;

  String toJson() => name;

  static MessageRole fromJson(String json) {
    return MessageRole.values.firstWhere((e) => e.name == json);
  }
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.toJson(),
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    role: MessageRole.fromJson(json['role'] as String),
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  /// Convert to Pollinations API format
  Map<String, String> toApiFormat() => {'role': role.name, 'content': content};
}
