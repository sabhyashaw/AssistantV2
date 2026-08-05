import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final ServerSettings initial;

  const SettingsScreen({super.key, required this.initial});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _api = ApiService();
  late final TextEditingController _url;
  late final TextEditingController _token;
  late bool _speak;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.initial.serverUrl);
    _token = TextEditingController(text: widget.initial.token);
    _speak = widget.initial.speakReplies;
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    try {
      await _api.health(serverUrl: _url.text, token: _token.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server is reachable.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  void _save() {
    final url = _url.text.trim().replaceAll(RegExp(r'/$'), '');
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a URL beginning with http:// or https://')),
      );
      return;
    }
    Navigator.pop(
      context,
      ServerSettings(
        serverUrl: url,
        token: _token.text.trim(),
        speakReplies: _speak,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Connect this phone to Jarvis running on your Server.',
            style: TextStyle(color: Color(0xFFBEC7C1), fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'PC server URL',
              hintText: 'http://192.168.1.10:8000',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _token,
            obscureText: true,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'API token',
              hintText: 'Same token configured on the Server',
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Speak AI replies'),
            subtitle: const Text('Use Android text-to-speech for responses.'),
            value: _speak,
            onChanged: (value) => setState(() => _speak = value),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _testing ? null : _test,
            icon: _testing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_tethering_rounded),
            label: const Text('Test connection'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _save,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text('Save'),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'LAN tip: use your PC IPv4 address, not localhost. If you are using the Android emulator, try http://10.0.2.2:8000.',
            style: TextStyle(color: Color(0xFF7E8984), height: 1.45),
          ),
        ],
      ),
    );
  }
}
