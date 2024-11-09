import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

mixin MessageMixin {
  MarkdownStyleSheet getMarkdownStyleSheet(BuildContext context, bool inverse) {
    final theme = Theme.of(context);
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      a: const TextStyle(color: CupertinoColors.activeBlue),
      p: theme.textTheme.bodyMedium?.copyWith(
        color: inverse
            ? theme.colorScheme.onInverseSurface
            : theme.colorScheme.onSurface,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: inverse
                ? theme.colorScheme.onInverseSurface
                : theme.colorScheme.onSurface,
            width: 1,
          ),
        ),
      ),
    );
  }
}
