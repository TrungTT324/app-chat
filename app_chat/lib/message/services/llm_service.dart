import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:com_mock/mock_utils.dart' as mock;

class LLMService {
  LLMService._();
  static final LLMService instance = LLMService._();

  // Provide key via --dart-define=LLM_API_KEY=xxxxx
  static const _apiKey = String.fromEnvironment(
    'LLM_API_KEY',
    defaultValue: '',
  );

  Future<String> chatReply(String prompt) async {
    if (_apiKey.isEmpty) {
      // fallback to mock
      await Future.delayed(const Duration(milliseconds: 400));
      return mock.randomMessage();
    }

    try {
      // Example using OpenAI Chat Completions (update endpoint/model as needed)
      final uri = Uri.https('api.openai.com', '/v1/chat/completions');
      final body = jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 150,
      });
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: body,
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;
        return text ?? '...';
      }
      return 'LLM error: ${resp.statusCode}';
    } catch (e) {
      debugPrint('LLM error: $e');
      return 'LLM failure';
    }
  }
}
