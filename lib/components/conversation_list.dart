import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witsy/models/conversation.dart';
import 'package:witsy/models/history.dart';

typedef ConversationTapCallback = void Function(Conversation conversation);
typedef ConversationConfirmDeleteCallback = Future<bool?> Function(
  Conversation conversation,
);

class ConversationList extends StatelessWidget {
  final ConversationTapCallback onConversationTap;
  final ConversationConfirmDeleteCallback confirmConversationDelete;
  const ConversationList({
    super.key,
    required this.onConversationTap,
    required this.confirmConversationDelete,
  });

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<History>(context);
    final conversations = history.conversations.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];

        final text = Text(
          conversation.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        );

        final wrapped = GestureDetector(
          onTap: () => onConversationTap(conversation),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: text,
          ),
        );

        return Dismissible(
          key: Key(conversation.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) {
            return confirmConversationDelete(conversation);
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(
              CupertinoIcons.delete,
              color: Colors.white,
            ),
          ),
          child: wrapped,
        );
      },
    );
  }
}
