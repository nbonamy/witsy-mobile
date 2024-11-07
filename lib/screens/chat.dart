import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:witsy/components/chat_input.dart' as wci;
import 'package:witsy/components/message_assistant.dart';
import 'package:witsy/components/message_user.dart';
import 'package:witsy/controllers/conversation_controller.dart';
import 'package:witsy/http/llm.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:uuid/uuid.dart';
import 'package:witsy/models/conversation.dart';
import 'package:witsy/models/history.dart';

import '../models/chunk.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.title,
    required this.history,
  });

  final String title;
  final History history;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ConversationController _chatController;
  //final _scrollController = ScrollController();
  final _user = const User(id: 'user');
  final _assistant = const User(id: 'assistant');
  bool drawerOpened = false;
  String output = '';

  @override
  void initState() {
    super.initState();
    _chatController = ConversationController(
      conversation: widget.history.newConversation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainBgColor = drawerOpened
        ? theme.colorScheme.surfaceContainerLow
        : theme.colorScheme.surface;
    final chatTheme = ChatTheme.fromThemeData(theme);

    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: _appBar(mainBgColor, theme),
      drawer: _drawer(theme),
      onDrawerChanged: (isOpened) {
        setState(() {
          drawerOpened = isOpened;
        });
      },
      body: SafeArea(
        child: Container(
          color: mainBgColor,
          child: Chat(
            builders: Builders(
              inputBuilder: (context) => const wci.ChatInput(),
              textMessageBuilder: _textMessageBuilder,
              imageMessageBuilder: (context, message) =>
                  FlyerChatImageMessage(message: message),
            ),
            chatController: _chatController,
            //scrollController: _scrollController,
            user: _user,
            onMessageSend: _addItem,
            theme: chatTheme.copyWith(
              backgroundColor: mainBgColor,
            ),
            darkTheme: chatTheme.copyWith(
              backgroundColor: mainBgColor,
            ),
          ),
        ),
      ),
    );
  }

  void _prompt(String prompt, String responseId) async {
    if (prompt.isEmpty) {
      return;
    }

    // reset output
    output = '';

    LlmClient().prompt(
      _chatController.messages,
      prompt,
      (chunk) => _onResponse(responseId, chunk),
    );
  }

  void _addMessage(TextMessage message) async {
    await _chatController.insert(message);
  }

  void _addItem(String? message) {
    if (message == null) {
      return;
    }

    // add the user message
    final userMessage = TextMessage(
      author: _user,
      createdAt: DateTime.now().toUtc(),
      id: const Uuid().v4(),
      text: message,
    );

    _addMessage(userMessage);

    // add the response
    final assistantMessage = TextMessage(
        author: _assistant,
        createdAt: DateTime.now().toUtc(),
        id: const Uuid().v4(),
        metadata: {'transient': true},
        text: '');

    _addMessage(assistantMessage);

    // now prompt
    _prompt(message, assistantMessage.id);
  }

  void _resetConversation() {
    setState(() {
      Conversation conversation = widget.history.newConversation();
      _chatController.setConversation(conversation);
    });
  }

  void _onResponse(
    String responseId,
    LLmChunk chunk,
  ) async {
    // process chunk
    if (chunk.type == 'content') {
      output += chunk.text;
    }

    // find message to update
    final possiblyUpdatedMessage = _chatController.messages.firstWhere(
      (element) => element.id == responseId,
    ) as TextMessage;

    // updat it
    await _chatController.update(
      possiblyUpdatedMessage,
      possiblyUpdatedMessage.copyWith(text: output, metadata: {
        'transient': chunk.type != 'content' || !chunk.done,
        'tool': chunk.type == 'tool' ? chunk : null,
      }),
    );
  }

  AppBar _appBar(Color mainBgColor, ThemeData theme) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: mainBgColor,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            CupertinoIcons.line_horizontal_3,
            color: theme.appBarTheme.foregroundColor,
            weight: 2.0,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.appBarTheme.foregroundColor,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            CupertinoIcons.create,
            color: theme.appBarTheme.foregroundColor,
            weight: 2.0,
          ),
          onPressed: _resetConversation,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Drawer _drawer(ThemeData theme) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Image.asset('assets/icon.png', height: 100),
                const Text(
                  'Witsy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }

  Widget _textMessageBuilder(BuildContext context, TextMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: message.author == _user
          ? UserMessage(message: message)
          : AssistantMessage(message: message),
    );
  }
}
