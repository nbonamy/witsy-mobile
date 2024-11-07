import 'package:witsy/models/chunk.dart';

class Message {
  final String id;
  final String role;
  late DateTime createdAt;
  bool transient;
  String? content;
  LLmChunk? toolCall;

  Message({
    required this.id,
    required this.role,
    required this.createdAt,
    required this.content,
    required this.transient,
    required this.toolCall,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      content: json['content'],
      transient: json['transient'],
      toolCall:
          json['toolCall'] != null ? LLmChunk.fromJson(json['toolCall']) : null,
    );
  }

  void updateMessage(String content) {
    this.content = content;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
      'transient': transient,
      'toolCall': toolCall?.toJson(),
    };
  }
}
