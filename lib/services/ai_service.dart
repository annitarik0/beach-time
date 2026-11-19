import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Where the open-source model runs. Every option speaks the
/// OpenAI-compatible `/chat/completions` protocol, so one client fits all.
class AiConfig {
  const AiConfig({
    required this.baseUrl,
    required this.model,
    this.apiKey = '',
  });

  final String baseUrl;
  final String model;
  final String apiKey;

  bool get isConfigured => baseUrl.isNotEmpty && model.isNotEmpty;

  /// Presets for popular ways to run open-weight models.
  static const presets = <String, AiConfig>{
    'Ollama (local, free)': AiConfig(
        baseUrl: 'http://localhost:11434/v1', model: 'llama3.2'),
    'Groq (Llama, free tier)': AiConfig(
        baseUrl: 'https://api.groq.com/openai/v1',
        model: 'llama-3.3-70b-versatile'),
    'OpenRouter (Qwen / Llama)': AiConfig(
        baseUrl: 'https://openrouter.ai/api/v1',
        model: 'meta-llama/llama-3.3-70b-instruct:free'),
    'Hugging Face router': AiConfig(
        baseUrl: 'https://router.huggingface.co/v1',
        model: 'Qwen/Qwen2.5-72B-Instruct'),
  };

  Map<String, dynamic> toJson() =>
      {'baseUrl': baseUrl, 'model': model, 'apiKey': apiKey};

  factory AiConfig.fromJson(Map<String, dynamic> j) => AiConfig(
        baseUrl: j['baseUrl'] as String? ?? '',
        model: j['model'] as String? ?? '',
        apiKey: j['apiKey'] as String? ?? '',
      );
}

class AiMessage {
  const AiMessage(this.role, this.content);
  final String role; // system | user | assistant
  final String content;
  Map<String, String> toJson() => {'role': role, 'content': content};
}

class AiException implements Exception {
  AiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// "Beach Buddy": an open-source LLM that reads today's real conditions
/// and answers questions or writes a short day plan.
class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static const systemPrompt =
      'You are Beach Buddy, a friendly lifeguard-meets-travel-guide inside the '
      'Beach Time app. You get real forecast data as context. Answer in a warm, '
      'concise way (max ~120 words unless asked for more), plain text with no '
      'emojis and no markdown headings, give concrete times, and always put safety first: never encourage '
      'swimming in thunderstorms, red-flag surf or strong offshore wind. '
      'If data is missing, say so instead of guessing.';

  Future<String> chat(AiConfig config, List<AiMessage> messages) async {
    if (!config.isConfigured) {
      throw AiException('Set up an AI model in Settings first.');
    }
    final base = config.baseUrl.endsWith('/')
        ? config.baseUrl.substring(0, config.baseUrl.length - 1)
        : config.baseUrl;
    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$base/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              if (config.apiKey.isNotEmpty)
                'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode({
              'model': config.model,
              'temperature': 0.7,
              'max_tokens': 450,
              'messages': [
                const AiMessage('system', systemPrompt).toJson(),
                ...messages.map((m) => m.toJson()),
              ],
            }),
          )
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      throw AiException('The AI model took too long to answer.');
    } catch (_) {
      throw AiException(
          'Could not reach the AI model at ${config.baseUrl}. Is it running?');
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw AiException('The AI provider rejected the API key.');
    }
    if (res.statusCode != 200) {
      throw AiException('AI error ${res.statusCode}.');
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final choices = json['choices'] as List?;
    final content = (choices?.isNotEmpty ?? false)
        ? (choices!.first['message']?['content'] as String?)
        : null;
    if (content == null || content.trim().isEmpty) {
      throw AiException('The AI model returned an empty answer.');
    }
    return content.trim();
  }
}
