import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witsy/components/bold_icon.dart';
import 'package:witsy/components/context_menu.dart' as cm;
import 'package:witsy/components/chat_input.dart' as wci;
import 'package:witsy/components/conversation_list.dart';
import 'package:witsy/components/message_assistant.dart';
import 'package:witsy/components/message_user.dart';
import 'package:witsy/controllers/conversation_controller.dart';
import 'package:witsy/http/llm.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:uuid/uuid.dart';
import 'package:witsy/models/chunk.dart';
import 'package:witsy/models/conversation.dart';
import 'package:witsy/models/history.dart';
import 'package:witsy/models/preferences.dart';
import 'package:witsy/screens/settings.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ConversationController? _chatController;
  final _scrollController = ScrollController();
  final _user = const User(id: 'user');
  final _assistant = const User(id: 'assistant');
  bool _menuVisible = false;
  bool _drawerOpened = false;
  String _output = '';

  Conversation? get conversation => _chatController?.conversation;

  @override
  void initState() {
    super.initState();
    _chatController = ConversationController(conversation: Conversation());
    initPreferences();
    initHistory();
  }

  void initPreferences() async {
    final prefs = Provider.of<Preferences>(context, listen: false);
    await prefs.load();
  }

  void initHistory() async {
    final history = Provider.of<History>(context, listen: false);
    await history.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainBgColor = _drawerOpened || _menuVisible
        ? theme.colorScheme.surfaceContainerLow
        : theme.colorScheme.surface;
    final chatTheme = ChatTheme.fromThemeData(theme);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: mainBgColor,
          appBar: _appBar(mainBgColor, theme),
          drawer: _drawer(theme),
          onDrawerChanged: (isOpened) {
            setState(() {
              _drawerOpened = isOpened;
            });
          },
          body: SafeArea(
            child: Container(
              color: mainBgColor,
              child: _chatController == null
                  ? Container()
                  : _chat(mainBgColor, chatTheme),
            ),
          ),
        ),
        if (_menuVisible)
          Container(
            margin: const EdgeInsets.only(top: 120),
            child: Material(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 100,
              child: _contextMenu(context),
            ),
          ),
      ],
    );
  }

  void _prompt(String prompt, String responseId) async {
    if (prompt.isEmpty) {
      return;
    }

    // reset output
    _output = '';

    // used to showcase an example where we stop scrolling to the bottom
    // as soon as message that is being generated reaches top of the viewport
    final initialMaxScrollExtent = _scrollController.position.maxScrollExtent;
    final viewportDimension = _scrollController.position.viewportDimension;

    // do it
    final prefs = Provider.of<Preferences>(context, listen: false);
    final history = Provider.of<History>(context, listen: false);
    final stream = LlmClient().prompt(
      prefs.engine.id,
      prefs.model.id,
      conversation!.messages.sublist(0, conversation!.messages.length - 2),
      prompt,
    );
    await for (var chunk in stream) {
      // process
      _onResponse(prefs, history, responseId, chunk);

      // used to showcase an example where we stop scrolling to the bottom
      // as soon as message that is being generated reaches top of the viewport
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients || !mounted) return;
        if ((_scrollController.position.maxScrollExtent -
                initialMaxScrollExtent) <
            viewportDimension) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.linearToEaseOut,
          );
        }
      });
    }
  }

  void _addMessage(TextMessage message) async {
    await _chatController!.insert(message);
  }

  void _sendMessage(String? message) {
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
    if (!conversation!.hasContent()) {
      return;
    }
    setState(() {
      _chatController!.setConversation(Conversation());
    });
  }

  void _onResponse(
    Preferences prefs,
    History history,
    String responseId,
    LLmChunk chunk,
  ) async {
    // process chunk
    if (chunk.type == 'content') {
      _output += chunk.text;
    }

    // find message to update
    final possiblyUpdatedMessage = _chatController!.messages.firstWhere(
      (element) => element.id == responseId,
    ) as TextMessage;

    // update it
    bool done = chunk.type == 'content' && chunk.done;
    await _chatController!.update(
      possiblyUpdatedMessage,
      possiblyUpdatedMessage.copyWith(text: _output, metadata: {
        'transient': !done,
        'tool': chunk.type == 'tool' ? chunk : null,
      }),
    );

    // if done, get a title
    if (done && !_chatController!.conversation.hasTitle()) {
      var title = await LlmClient().title(
        prefs.engine.id,
        prefs.model.id,
        conversation!.messages,
      );
      setState(() => _chatController!.conversation.title = title);
    }

    // save history
    if (done) {
      history.add(_chatController!.conversation);
      history.save();
    }
  }

  void _toggleMenu() {
    setState(() {
      _menuVisible = !_menuVisible;
    });
  }

  void _showSettings() {
    _toggleMenu();
    Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _deletChat() {
    _toggleMenu();
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
      title: GestureDetector(
        onTap: () => _toggleMenu(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Witsy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.appBarTheme.foregroundColor,
              ),
            ),
            const SizedBox(width: 12),
            BoldIcon(
              icon: CupertinoIcons.chevron_right,
              color: theme.appBarTheme.foregroundColor?.withOpacity(0.5),
              size: 14,
            ),
          ],
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
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.onInverseSurface,
                  width: 0.2,
                ),
              ),
            ),
            margin: const EdgeInsets.only(
              left: 24,
              right: 24,
            ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConversationList(
              onConversationTap: (conversation) {
                setState(() {
                  _chatController!.setConversation(conversation);
                  Navigator.pop(context);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _contextMenu(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = Provider.of<Preferences>(context);
    final faddedTextColor = theme.colorScheme.onSurface.withOpacity(0.6);
    return cm.CupertinoContextMenuSheet(
      actions: [
        if (_chatController != null)
          cm.CupertinoContextMenuAction(
            child: Text(
              _chatController!.conversation.title,
              style: TextStyle(
                color: faddedTextColor,
                fontSize: 16,
              ),
            ),
          ),
        cm.CupertinoContextMenuAction(
          onPressed: () => _showSettings(),
          trailingIcon: CupertinoIcons.settings,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings'),
              const SizedBox(height: 8),
              Text(
                '${prefs.engine.name}\n${prefs.model.name}',
                style: TextStyle(
                  color: faddedTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        cm.CupertinoContextMenuAction(
          onPressed: () => _deletChat(),
          trailingIcon: CupertinoIcons.delete,
          isDestructiveAction: true,
          child: const Text('Delete'),
        ),
      ],
      contextMenuLocation: cm.ContextMenuLocation.center,
      orientation: Orientation.portrait,
    );
  }

  Chat _chat(Color mainBgColor, ChatTheme chatTheme) {
    return Chat(
      chatController: _chatController!,
      scrollController: _scrollController,
      builders: Builders(
        inputBuilder: (context) => wci.ChatInput(
          backgroundColor: mainBgColor,
        ),
        textMessageBuilder: _textMessageBuilder,
        imageMessageBuilder: (context, message) =>
            FlyerChatImageMessage(message: message),
      ),
      user: _user,
      onMessageSend: _sendMessage,
      theme: chatTheme.copyWith(
        backgroundColor: mainBgColor,
      ),
      darkTheme: chatTheme.copyWith(
        backgroundColor: mainBgColor,
      ),
    );
  }

  Widget _textMessageBuilder(BuildContext context, TextMessage message) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: message.author == _user ? 12 : 8,
        right: message.author == _user ? 8 : 12,
      ),
      child: message.author == _user
          ? UserMessage(message: message)
          : AssistantMessage(message: message),
    );
  }
}
