import 'package:flutter/material.dart';

class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final bool listening;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const ChatComposer({
    super.key,
    required this.controller,
    required this.sending,
    required this.listening,
    required this.onSend,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2020),
          border: Border.all(color: const Color(0xFF405149), width: 1.2),
          borderRadius: BorderRadius.circular(42),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: listening ? 'Stop voice input' : 'Voice input',
              onPressed: onMic,
              icon: Icon(
                listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: listening
                    ? const Color(0xFF13C88B)
                    : const Color(0xFFBEC7C1),
                size: 29,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(
                  color: Color(0xFFE7E9E7),
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  filled: false,
                  hintText: 'Message AI...',
                  hintStyle: TextStyle(
                    color: Color(0xFF69706D),
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            SizedBox(
              width: 58,
              height: 58,
              child: FilledButton(
                onPressed: sending ? null : onSend,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  backgroundColor: const Color(0xFF13C88B),
                  disabledBackgroundColor: const Color(0xFF245947),
                  foregroundColor: const Color(0xFF073D30),
                ),
                child: sending
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Icon(Icons.send_rounded, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
