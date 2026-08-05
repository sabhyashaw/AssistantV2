import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';
import '../widgets/chat_composer.dart';
import '../widgets/suggestion_chips.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _api = ApiService();
  final _settingsService = SettingsService();
  final _speech = stt.SpeechToText();
  final _tts = FlutterTts();
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  // ============================================================
  // MESSAGE COLORS
  // Change these four values to customize the chat.
  // ============================================================

  static const Color _userBubbleColor = Color(0xFF2563EB);
  static const Color _userTextColor = Colors.white;

  static const Color _aiBubbleColor = Color(0xFF242725);
  static const Color _aiTextColor = Color(0xFFE8ECEA);

  final List<ChatMessage> _messages = [
    ChatMessage(
      role: 'assistant',
      content: 'Hello. I am Jarvis. Master Shaggy made me.',
    ),
  ];

  ServerSettings _settings = const ServerSettings(
    serverUrl: 'http://192.168.1.10:8000',
    token: '',
    speakReplies: false,
  );

  bool _sending = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.load();

    if (mounted) {
      setState(() => _settings = settings);
    }
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push<ServerSettings>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          initial: _settings,
        ),
      ),
    );

    if (result != null) {
      await _settingsService.save(result);

      if (mounted) {
        setState(() => _settings = result);
      }
    }
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();

    if (text.isEmpty || _sending) return;

    final history = List<ChatMessage>.from(_messages);

    setState(() {
      _messages.add(
        ChatMessage(
          role: 'user',
          content: text,
        ),
      );

      _controller.clear();
      _sending = true;
    });

    _scrollToBottom();

    try {
      final reply = await _api.sendMessage(
        serverUrl: _settings.serverUrl,
        token: _settings.token,
        message: text,
        history: history,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            role: 'assistant',
            content: reply,
          ),
        );
      });

      if (_settings.speakReplies) {
        await _tts.stop();
        await _tts.speak(reply);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            role: 'assistant',
            content: 'AI: $e',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });

        _scrollToBottom();
      }
    }
  }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await _speech.stop();

      if (mounted) {
        setState(() {
          _listening = false;
        });
      }

      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _listening = false;
            });
          }
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            _listening = false;
          });
        }
      },
    );

    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Speech recognition is unavailable.',
            ),
          ),
        );
      }

      return;
    }

    setState(() {
      _listening = true;
    });

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _controller.text = result.recognizedWords;

            _controller.selection = TextSelection.collapsed(
              offset: _controller.text.length,
            );
          });
        }
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 260,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(
          ChatMessage(
            role: 'assistant',
            content: 'New conversation started. What are we building?',
          ),
        );
    });
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessage(ChatMessage message) {
    final bool isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 700,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? _userBubbleColor
                    : _aiBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(
                    isUser ? 18 : 5,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? 5 : 18,
                  ),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser
                      ? _userTextColor
                      : _aiTextColor,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _speech.stop();
    _tts.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        title: const Text(
          'Jarvis',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                _openSettings();
              }

              if (value == 'clear') {
                _clearChat();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'settings',
                child: Text(
                  'Server settings',
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text(
                  'New chat',
                ),
              ),
            ],
          ),
        ],

        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFF405149),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,

                padding: const EdgeInsets.fromLTRB(
                  28,
                  30,
                  28,
                  12,
                ),

                itemCount:
                _messages.length + (_sending ? 1 : 0),

                itemBuilder: (_, index) {
                  if (index == _messages.length) {
                    return const Padding(
                      padding: EdgeInsets.only(
                        bottom: 26,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            'Thinking…',
                            style: TextStyle(
                              color: Color(
                                0xFFBEC7C1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildMessage(
                    _messages[index],
                  );
                },
              ),
            ),

            SuggestionChips(
              onSelected: _send,
            ),

            ChatComposer(
              controller: _controller,
              sending: _sending,
              listening: _listening,
              onSend: _send,
              onMic: _toggleVoice,
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                13,
                20,
                15,
              ),
              child: Text(
                'AI can make mistakes. Verify important information.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(
                    0xFF515A56,
                  ),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}