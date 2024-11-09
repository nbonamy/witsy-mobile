import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witsy/models/model.dart';
import 'package:witsy/models/engine.dart';

class Preferences extends ChangeNotifier {
  Engine defaultEngine = Engine(id: 'openai', name: 'OpenAI');
  Model defaultModel = Model(id: 'gpt-4o', name: 'GPT-4o');

  late final SharedPreferences _prefs;

  Preferences();

  load() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Engine get engine => Engine.fromJson(
      jsonDecode(_prefs.getString('engine') ?? jsonEncode(defaultEngine)));

  Model get model => Model.fromJson(
      jsonDecode(_prefs.getString('model') ?? jsonEncode(defaultModel)));

  void setEngine(Engine engine) async {
    _prefs.setString('engine', jsonEncode(engine.toJson()));
    notifyListeners();
  }

  void setModel(Model model) {
    _prefs.setString('model', jsonEncode(model.toJson()));
    notifyListeners();
  }
}
