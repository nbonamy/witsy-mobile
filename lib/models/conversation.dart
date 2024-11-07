import 'package:uuid/uuid.dart';
import 'package:witsy/models/message.dart';

class Conversation {
  late final String id;
  late String? title;
  late final DateTime createdAt;
  late DateTime updatedAt;
  late String? engineId;
  late String? modelId;
  late final List<Message> messages;

  Conversation() {
    id = const Uuid().v4();
    title = null;
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
}
