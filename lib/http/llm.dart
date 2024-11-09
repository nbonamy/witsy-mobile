import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:witsy/models/chunk.dart';
import 'package:witsy/models/message.dart';
import 'package:witsy/models/model.dart';
import 'package:witsy/models/engine.dart';
import 'package:witsy/config.dart' as config;

class LlmClient {
  late final String _baseUrl;

  final String clientIdHeader = 'x-clientid';

  LlmClient() {
    _baseUrl = /*kDebugMode ? 'http://localhost:3000' :*/
        'https://api.witsyai.com';
  }

  Future<List<Engine>> engines() async {
    http.Response response = await http.get(
      Uri.parse('$_baseUrl/llm/engines'),
      headers: {clientIdHeader: config.clientId},
    );
    var result = jsonDecode(response.body);
    return (result as List).map((e) => Engine.fromJson(e)).toList();
  }

  Future<List<Model>> models(Engine provider) async {
    http.Response response = await http.get(
      Uri.parse('$_baseUrl/llm/models/${provider.id}'),
      headers: {clientIdHeader: config.clientId},
    );
    var result = jsonDecode(response.body);
    return (result['chat'] as List).map((e) => Model.fromJson(e)).toList();
  }

  Stream<LLmChunk> prompt(String engineId, String modelId,
      List<Message> messages, String prompt) async* {
    http.Request request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/llm/chat'),
    );

    var requestBody = {
      "engine": engineId,
      "model": modelId,
      "messages":
          messages.map((m) => {"role": m.role, "content": m.content}).toList(),
      "prompt": prompt
    };

    request.body = jsonEncode(requestBody);
    request.headers.addAll({
      'Content-Type': 'application/json',
      clientIdHeader: config.clientId,
    });

    // sometimes we need to concatenate chunks
    var jsonChunk = '';
    http.StreamedResponse response = await http.Client().send(request);
    await for (var value in response.stream.transform(utf8.decoder)) {
      try {
        var jsonResponse = jsonDecode(value);
        yield LLmChunk.fromJson(jsonResponse);
      } catch (e) {
        jsonChunk += value;
        try {
          var jsonResponse = jsonDecode(jsonChunk);
          yield LLmChunk.fromJson(jsonResponse);
          jsonChunk = '';
        } catch (e) {
          // do nothing: we need to concatenate more chunks
        }
      }
    }
  }

  Future<String> title(
    String engineId,
    String modelId,
    List<Message> messages,
  ) async {
    var requestBody = {
      "engine": engineId,
      "model": modelId,
      "messages":
          messages.map((e) => {"role": e.role, "content": e.content}).toList(),
    };

    http.Response response = await http.post(
      Uri.parse('$_baseUrl/llm/title'),
      headers: {
        'Content-Type': 'application/json',
        clientIdHeader: config.clientId,
      },
      body: jsonEncode(requestBody),
    );
    var result = jsonDecode(response.body);
    return result['title'];
  }
}
