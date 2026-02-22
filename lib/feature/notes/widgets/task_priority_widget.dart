import 'package:flutter/material.dart';
import 'package:fuck_your_todos/data/db/tables/note_table.dart';

class PriorityWidget extends StatelessWidget {
  const PriorityWidget({super.key, required this.priority});
  final Priority priority;
  Color _getColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (priority) {
      case Priority.high:
        return theme.colorScheme.error;
      case Priority.medium:
        return theme.colorScheme.tertiary;
      case Priority.low:
        return theme.colorScheme.primary;
      case Priority.none:
        return theme.disabledColor;
    }
  }

  String _getPriorityName() {
    switch (priority) {
      case Priority.high:
        return 'high';
      case Priority.medium:
        return 'mid';
      case Priority.low:
        return 'low';
      case Priority.none:
        return 'none';
    }
  }

  @override
  Widget build(BuildContext context) {
    return priority == Priority.none
        ? SizedBox.shrink()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getColor(context).withValues(alpha: 0.4),
                width: 1,
              ),
              color: _getColor(context).withValues(alpha: 0.2),
            ),
            child: Text(
              _getPriorityName(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _getColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
  }
}
