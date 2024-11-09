import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:witsy/components/message_base.dart';
import 'package:witsy/components/pulsing_icon.dart';

extension ListSpaceBetweenExtension on List<Widget> {
  List<Widget> withSpaceBetween({
    double? width,
    double? height,
  }) =>
      [
        for (int i = 0; i < length; i++) ...[
          if (i > 0) SizedBox(width: width, height: height),
          this[i],
        ],
      ];
}

class AssistantMessage extends StatelessWidget with MessageMixin {
  const AssistantMessage({super.key, required this.message});

  final TextMessage message;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(CupertinoIcons.person, color: theme.colorScheme.onSurface),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.text.isNotEmpty)
                MarkdownBody(
                  data: message.text,
                  selectable: true,
                  styleSheet: getMarkdownStyleSheet(context, false),
                  extensionSet: md.ExtensionSet.gitHubWeb,
                  onTapLink: (text, href, title) => {
                    if (href != null)
                      {
                        launchUrl(
                          Uri.parse(href),
                          mode: LaunchMode.externalApplication,
                        )
                      }
                  },
                ),
              if (message.metadata?['transient'] == true)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      child: const PulsingIcon(
                        child: Icon(
                          CupertinoIcons.circle_fill,
                          size: 12,
                        ),
                      ),
                    ),
                    if (message.metadata?['tool'] != null &&
                        message.metadata?['tool'].status != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        message.metadata?['tool'].status,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
            ].withSpaceBetween(height: 12),
          ),
        ),
      ],
    );
  }
}
