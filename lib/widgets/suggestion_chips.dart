import 'package:flutter/material.dart';

class SuggestionChips extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const SuggestionChips({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      'Explain local LLMs',
      'What is the weather in Kolkata?',
      'Write a Python function',
    ];

    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final text = suggestions[index];
          return ActionChip(
            label: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFBEC7C1),
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFF1C2020),
            side: const BorderSide(color: Color(0xFF405149)),
            shape: const StadiumBorder(),
            onPressed: () => onSelected(text),
          );
        },
      ),
    );
  }
}
