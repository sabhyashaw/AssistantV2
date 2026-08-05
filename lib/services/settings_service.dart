import 'package:shared_preferences/shared_preferences.dart';

class ServerSettings {
  final String serverUrl;
  final String token;
  final bool speakReplies;

  const ServerSettings({
    required this.serverUrl,
    required this.token,
    required this.speakReplies,
  });
}

class SettingsService {
  static const _urlKey = 'server_url';
  static const _tokenKey = 'api_token';
  static const _speakKey = 'speak_replies';

  Future<ServerSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ServerSettings(
      serverUrl: prefs.getString(_urlKey) ?? 'http://192.168.1.10:8000',
      token: prefs.getString(_tokenKey) ?? '',
      speakReplies: prefs.getBool(_speakKey) ?? false,
    );
  }

  Future<void> save(ServerSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _urlKey,
      settings.serverUrl.replaceAll(RegExp(r'/$'), ''),
    );
    await prefs.setString(_tokenKey, settings.token);
    await prefs.setBool(_speakKey, settings.speakReplies);
  }
}
