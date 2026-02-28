import 'package:flutter/material.dart';

class OnboardingPageWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLastPage;

  const OnboardingPageWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleColor = isLastPage
        ? Colors.white
        : theme.textTheme.headlineSmall?.color;
    final descriptionColor = isLastPage
        ? Colors.white70
        : theme.colorScheme.onSurfaceVariant;
    final iconColor = isLastPage ? Colors.white : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: iconColor),
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(color: descriptionColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
