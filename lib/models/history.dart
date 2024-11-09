import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:witsy/models/conversation.dart';
import 'package:path_provider/path_provider.dart';

class History extends ChangeNotifier {
  late List<Conversation> conversations;

  History() {
    conversations = [];
  }

  void add(Conversation conversation) {
    if (!conversations.any((c) => c.id == conversation.id)) {
      conversations.add(conversation);
      notifyListeners();
      save();
    }
  }

  void delete(Conversation conversation) {
    conversations.removeWhere((c) => c.id == conversation.id);
    notifyListeners();
    save();
  }

  save() async {
    final file = File(await _getFilePath());
    final json = jsonEncode({
      'conversations': conversations
          .where((c) => c.hasContent())
          .map((e) => e.toJson())
          .toList()
    });
    await file.writeAsString(json);
    notifyListeners();
  }

  load() async {
    final filePath = await _getFilePath();
    // ignore: avoid_print
    print('Loading history from $filePath');
    final file = File(filePath);
    if (file.existsSync()) {
      final json = await file.readAsString();
      conversations = (jsonDecode(json)['conversations'] as List)
          .map((e) => Conversation.fromJson(e))
          .toList();
    } else {
      conversations = [];
    }
  }

  // Get the application documents directory
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/history.json').path;
  }
}
