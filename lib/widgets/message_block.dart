import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBlock extends StatelessWidget {
  final ChatMessage message;

  const MessageBlock({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    const userColor = Color(0xFFE7E9E7);
    const assistantColor = Color(0xFFBEC7C1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Semantics(
        label: message.isUser ? 'You said' : 'AI Assistant said',
        child: SelectableText(
          message.content,
          style: TextStyle(
            color: message.isUser ? userColor : assistantColor,
            fontSize: 20,
            height: 1.52,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
