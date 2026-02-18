import 'dart:math';
import 'package:flutter/material.dart';
import 'package:journal_app/core/constants/constants.dart';

class NoTaskPlaceholder extends StatelessWidget {
  const NoTaskPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final quote = MotivationConstants
        .quotes[random.nextInt(MotivationConstants.quotes.length)];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_rounded, size: 100, color: colorScheme.primary),
            const SizedBox(height: 40),
            Text(
              'No Tasks for Today',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Motivational quote
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.format_quote,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      quote,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.format_quote,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Call to action
            Text(
              'Tap + to create a new task',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
