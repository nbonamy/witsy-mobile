import 'package:witsy/models/conversation.dart';

class History {
  List<Conversation> conversations;

  History({required this.conversations});

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      conversations: (json['conversations'] as List)
          .map((e) => Conversation.fromJson(e))
          .toList(),
    );
  }

  Conversation newConversation() {
    final conversation = Conversation();
    conversations.add(conversation);
    return conversation;
  }
}
