import 'dart:async';

import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:witsy/models/conversation.dart';
import 'package:witsy/models/message.dart' as cm;

class ConversationController extends ChatController {
  final _operationsController = StreamController<ChatOperation>.broadcast();
  List<Message> _messages = [];
  Conversation conversation;

  ConversationController({required this.conversation});

  void setConversation(Conversation conversation) {
    _messages.clear();
    this.conversation = conversation;
    _messages.addAll(
      conversation.messages.map(
        (c) => TextMessage(
          id: c.id,
          author: User(id: c.role),
          createdAt: c.createdAt,
          text: c.content ?? '',
          metadata: {
            'transient': c.transient,
            'toolCall': c.toolCall,
          },
        ),
      ),
    );
    _operationsController.add(ChatOperation.set());
  }

  @override
  void dispose() {
    _operationsController.close();
  }

  @override
  Stream<ChatOperation> get operationsStream => _operationsController.stream;

  @override
  List<Message> get messages => _messages;

  @override
  Future<void> set(List<Message> messages) async {
    conversation.messages.clear();
    for (var message in messages) {
      if (message is TextMessage) {
        conversation.messages.add(_convert(message));
      }
    }
    _messages = messages;
    _operationsController.add(ChatOperation.set());
  }

  @override
  Future<void> insert(Message message, {int? index}) async {
    // check we don't already have
    final existingIndex =
        conversation.messages.indexWhere((element) => element.id == message.id);
    if (existingIndex != -1) return;

    // we only support TextMessage
    if (message is TextMessage) {
      if (index == null) {
        _messages.add(message);
        conversation.messages.add(_convert(message));
        conversation.updatedAt = DateTime.now();
        _operationsController.add(ChatOperation.insert(
          message,
          conversation.messages.length - 1,
        ));
      } else {
        _messages.insert(index, message);
        conversation.messages.insert(index, _convert(message));
        conversation.updatedAt = DateTime.now();
        _operationsController.add(ChatOperation.insert(message, index));
      }
    } else {
      throw Exception('Unsupported message type');
    }
  }

  @override
  Future<void> update(Message oldMessage, Message newMessage) async {
    if (oldMessage == newMessage) return;
    if (newMessage is TextMessage) {
      final index = conversation.messages
          .indexWhere((element) => element.id == oldMessage.id);
      if (index != -1) {
        _messages[index] = newMessage;
        conversation.messages[index] = _convert(newMessage);
        conversation.updatedAt = DateTime.now();
        _operationsController.add(ChatOperation.update(oldMessage, newMessage));
      } else {
        throw Exception('Message not found');
      }
    } else {
      throw Exception('Unsupported message type');
    }
  }

  @override
  Future<void> remove(Message message) async {
    final index =
        conversation.messages.indexWhere((element) => element.id == message.id);
    if (index > -1) {
      _messages.removeAt(index);
      conversation.messages.removeAt(index);
      conversation.updatedAt = DateTime.now();
      _operationsController.add(ChatOperation.remove(message, index));
    }
  }

  // convert from TextMessage to Message
  cm.Message _convert(TextMessage message) {
    return cm.Message(
      id: message.id,
      role: message.author.id,
      createdAt: message.createdAt,
      content: message.text,
      transient: message.metadata?['transient'] ?? false,
      toolCall: message.metadata?['toolCall'],
    );
  }
}
