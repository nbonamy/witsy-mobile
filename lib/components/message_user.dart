import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:witsy/components/message_base.dart';

class UserMessage extends StatelessWidget with MessageMixin {
  const UserMessage({
    super.key,
    required this.message,
  });

  final TextMessage message;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(
        top: 32,
        bottom: 16,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: MarkdownBody(
        data: message.text,
        styleSheet: getMarkdownStyleSheet(context, true),
      ),
    );
  }
}
