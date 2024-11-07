import 'dart:convert';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:http/http.dart' as http;
import 'package:witsy/models/chunk.dart';

class LlmClient {
  void prompt(
    List<Message> messages,
    String prompt,
    void Function(LLmChunk) callback,
  ) async {
    http.Request request = http.Request(
      'POST',
      Uri.parse('http://localhost:3000/llm/chat'),
    );

    var requestBody = {
      "engine": "openai",
      "model": "gpt-4o",
      "messages": messages
          .whereType<TextMessage>()
          .map((e) => {"role": e.author.id, "content": e.text})
          .toList(),
      "prompt": prompt
    };

    request.body = jsonEncode(requestBody);
    request.headers.addAll(
      {'Content-Type': 'application/json', 'API_KEY': 'YOUR_API_KEY'},
    );
    http.StreamedResponse response = await http.Client().send(request);
    var res = response.stream.listen((value) {
      String output = utf8.decode(value);
      callback(LLmChunk.fromJson(jsonDecode(output)));
    });
    await res.asFuture();
    res.cancel();
  }

  Future<String> title(
    List<Message> messages,
  ) async {
    http.Request request = http.Request(
      'POST',
      Uri.parse('http://localhost:3000/llm/title'),
    );

    var requestBody = {
      "engine": "openai",
      "model": "gpt-4o",
      "messages": messages
          .whereType<TextMessage>()
          .map((e) => {"role": e.author.id, "content": e.text})
          .toList(),
      "prompt": prompt
    };

    request.body = jsonEncode(requestBody);
    request.headers.addAll(
      {'Content-Type': 'application/json', 'API_KEY': 'YOUR_API_KEY'},
    );

    http.Response response = await http.Client().post(
        Uri.parse('http://localhost:3000/llm/title'),
        headers: {'Content-Type': 'application/json'});
    var result = jsonDecode(response.body);
    return result['title'];
  }
}
