import 'package:flutter/material.dart';

// Predefined sexy categories the user requested
const List<Map<String, String>> predefinedCategories = [
  {'name': 'Study', 'icon': '📚'},
  {'name': 'Gym', 'icon': '💪'},
  {'name': 'Work', 'icon': '💼'},
  {'name': 'Personal', 'icon': '👤'},
  {'name': 'Meeting', 'icon': '🤝'},
  {'name': 'Shopping', 'icon': '🛒'},
  {'name': 'Health', 'icon': '❤️'},
  {'name': 'Finance', 'icon': '💰'},
  {'name': 'Travel', 'icon': '✈️'},
  {'name': 'Ideas', 'icon': '💡'},
  {'name': 'Event', 'icon': '🎉'},
  {'name': 'Urgent', 'icon': '🔥'},
  {'name': 'Food', 'icon': '🍔'},
  {'name': 'Home', 'icon': '🏠'},
  {'name': 'Gaming', 'icon': '🎮'},
  {'name': 'Hobby', 'icon': '🎨'},
  {'name': 'Sports', 'icon': '⚽'},
  {'name': 'Music', 'icon': '🎵'},
];

// Predefined set of beautiful icons for the custom picker
const List<String> premiumIcons = [
  '📚',
  '💪',
  '💼',
  '👤',
  '🤝',
  '🛒',
  '❤️',
  '💰',
  '✈️',
  '💡',
  '🎉',
  '🔥',
  '🍔',
  '🏠',
  '🎮',
  '🎨',
  '⚽',
  '🎵',
  '📝',
  '⚡',
  '🌟',
  '🚀',
  '🎯',
  '💎',
  '🌈',
  '✨',
  '💻',
  '📱',
  '🎧',
  '📸',
  '☕',
  '🍷',
  '🍕',
  '🍰',
  '🍿',
  '🎁',
  '🎈',
  '🎃',
  '🎄',
  '🎆',
  '🎇',
  '🎪',
  '🎢',
  '🎨',
  '🎬',
  '🎤',
  '🎫',
  '🏆',
];

class CustomEmojiPicker extends StatelessWidget {
  final String selectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  const CustomEmojiPicker({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: premiumIcons.length,
        itemBuilder: (context, index) {
          final emoji = premiumIcons[index];
          final isSelected = emoji == selectedEmoji;

          return InkWell(
            onTap: () => onEmojiSelected(emoji),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 24,
                  // Scale up slightly if selected
                  height: isSelected ? 1.1 : 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
