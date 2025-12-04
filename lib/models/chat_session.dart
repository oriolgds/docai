import 'package:docai/models/chat_message.dart';

class ChatSession {
  final String id;
  final List<ChatMessage> messages;
  final bool isLongResponse; // Response length preference
  final String preset;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? title;
  List<String>? followUpSuggestions; // AI-generated follow-up suggestions

  ChatSession({
    required this.id,
    required this.messages,
    this.isLongResponse = false,
    required this.preset,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.title,
    this.followUpSuggestions,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  ChatSession copyWith({
    List<ChatMessage>? messages,
    bool? isLongResponse,
    String? preset,
    String? title,
    List<String>? followUpSuggestions,
  }) {
    return ChatSession(
      id: id,
      messages: messages ?? this.messages,
      isLongResponse: isLongResponse ?? this.isLongResponse,
      preset: preset ?? this.preset,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      title: title ?? this.title,
      followUpSuggestions: followUpSuggestions ?? this.followUpSuggestions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'messages': messages.map((m) => m.toJson()).toList(),
    'isLongResponse': isLongResponse,
    'preset': preset,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'title': title,
    'followUpSuggestions': followUpSuggestions,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    messages: (json['messages'] as List)
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList(),
    isLongResponse: json['isLongResponse'] as bool? ?? false,
    preset: json['preset'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    title: json['title'] as String?,
    followUpSuggestions: (json['followUpSuggestions'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
  );
}
