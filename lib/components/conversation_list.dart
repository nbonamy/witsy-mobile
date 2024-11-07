import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witsy/models/conversation.dart';
import 'package:witsy/models/history.dart';

typedef ConversationTapCallback = void Function(Conversation conversation);

class ConversationList extends StatelessWidget {
  final ConversationTapCallback onConversationTap;
  const ConversationList({super.key, required this.onConversationTap});

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<History>(context);
    final conversations = history.conversations.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return ListView.builder(
      shrinkWrap: true,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ListTile(
          splashColor: Colors.transparent,
          title: Text(
            conversation.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            onConversationTap(conversation);
          },
        );
      },
    );
  }
}
