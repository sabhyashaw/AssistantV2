import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class JarvisApiException implements Exception {
  final String message;

  JarvisApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  Future<String> health({
    required String serverUrl,
    required String token,
  }) async {
    final url = _clean(serverUrl);

    if (url.isEmpty) {
      throw JarvisApiException(
        'Server URL is empty. Set it to http://10.0.2.2:8000',
      );
    }

    final headers = <String, String>{};

    if (token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    try {
      final uri = Uri.parse('$url/health');

      final response = await http
          .get(
        uri,
        headers: headers,
      )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw JarvisApiException(
          'Health check failed: HTTP ${response.statusCode}',
        );
      }

      return utf8.decode(response.bodyBytes);
    } catch (e) {
      if (e is JarvisApiException) rethrow;

      throw JarvisApiException(
        'Could not connect to the PC server: $e',
      );
    }
  }

  Future<String> sendMessage({
    required String serverUrl,
    required String token,
    required String message,
    required List<ChatMessage> history,
  }) async {
    final url = _clean(serverUrl);

    if (url.isEmpty) {
      throw JarvisApiException(
        'Server URL is empty. Set it to http://10.0.2.2:8000',
      );
    }

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    try {
      final uri = Uri.parse('$url/api/chat');

      final response = await http
          .post(
        uri,
        headers: headers,
        body: jsonEncode({
          'message': message,
          'history': history.map((m) => m.toJson()).toList(),
        }),
      )
          .timeout(const Duration(seconds: 190));

      if (response.statusCode != 200) {
        var detail = utf8.decode(response.bodyBytes);

        try {
          final decoded = jsonDecode(detail);
          detail = decoded['detail']?.toString() ?? detail;
        } catch (_) {}

        throw JarvisApiException(
          'Server returned HTTP ${response.statusCode}: $detail',
        );
      }

      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final reply = decoded['reply']?.toString().trim();

      if (reply == null || reply.isEmpty) {
        throw JarvisApiException(
          'The server returned an empty reply.',
        );
      }

      return reply;
    } catch (e) {
      if (e is JarvisApiException) rethrow;

      throw JarvisApiException(
        'Could not reach Jarvis on your PC.\n\n'
            'Server: $url\n'
            'Error: $e',
      );
    }
  }

  String _clean(String value) {
    return value.trim().replaceAll(RegExp(r'/+$'), '');
  }
}