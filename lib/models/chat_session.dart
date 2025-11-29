import 'package:docai/models/chat_message.dart';

class ChatSession {
  final String id;
  final List<ChatMessage> messages;
  final String model;
  final String preset;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? title;

  ChatSession({
    required this.id,
    required this.messages,
    required this.model,
    required this.preset,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.title,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  ChatSession copyWith({
    List<ChatMessage>? messages,
    String? model,
    String? preset,
    String? title,
  }) {
    return ChatSession(
      id: id,
      messages: messages ?? this.messages,
      model: model ?? this.model,
      preset: preset ?? this.preset,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'messages': messages.map((m) => m.toJson()).toList(),
    'model': model,
    'preset': preset,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'title': title,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    messages: (json['messages'] as List)
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList(),
    model: json['model'] as String,
    preset: json['preset'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    title: json['title'] as String?,
  );
}
