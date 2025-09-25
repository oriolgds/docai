enum ChatRole { user, assistant, system }

extension ChatRoleX on ChatRole {
  String get apiName {
    switch (this) {
      case ChatRole.user:
        return 'user';
      case ChatRole.assistant:
        return 'assistant';
      case ChatRole.system:
        return 'system';
    }
  }
}

class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? content,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toOpenRouterMessage() => {
        'role': role.apiName,
        'content': content,
      };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: ChatRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => ChatRole.user,
      ),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Para Supabase
  Map<String, dynamic> toSupabaseJson(String conversationId) {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role.name,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromSupabaseJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: ChatRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => ChatRole.user,
      ),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static ChatMessage user(String text) => ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: ChatRole.user,
        content: text,
      );

  static ChatMessage assistant(String text) => ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: ChatRole.assistant,
        content: text,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}