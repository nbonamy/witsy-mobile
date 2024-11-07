import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:witsy/models/chunk.dart';
import 'package:witsy/models/message.dart';

class LlmClient {
  Future<void> prompt(
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
      "messages":
          messages.map((m) => {"role": m.role, "content": m.content}).toList(),
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
    var requestBody = {
      "engine": "openai",
      "model": "gpt-4o",
      "messages":
          messages.map((e) => {"role": e.role, "content": e.content}).toList(),
    };

    http.Response response = await http.post(
      Uri.parse('http://localhost:3000/llm/title'),
      headers: {'Content-Type': 'application/json', 'API_KEY': 'YOUR_API_KEY'},
      body: jsonEncode(requestBody),
    );
    var result = jsonDecode(response.body);
    return result['title'];
  }
}
