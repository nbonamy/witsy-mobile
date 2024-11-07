import 'package:uuid/uuid.dart';
import 'package:witsy/models/message.dart';

class Conversation {
  late String id;
  late String title;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String? engineId;
  late String? modelId;
  late final List<Message> messages;

  static const String defaultTitle = 'New Chat';

  Conversation() {
    id = const Uuid().v4();
    title = defaultTitle;
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
    engineId = null;
    modelId = null;
    messages = [];
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final conversation = Conversation();
    conversation.id = json['id'];
    conversation.title = json['title'];
    conversation.createdAt = DateTime.parse(json['createdAt']);
    conversation.updatedAt = DateTime.parse(json['updatedAt']);
    conversation.engineId = json['engineId'];
    conversation.modelId = json['modelId'];
    conversation.messages.addAll(
      (json['messages'] as List).map((e) => Message.fromJson(e)).toList(),
    );
    return conversation;
  }

  bool hasTitle() {
    return title != defaultTitle;
  }

  bool hasContent() {
    return hasTitle() || messages.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'engineId': engineId,
      'modelId': modelId,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}
