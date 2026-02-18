import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal_app/data/db/tables/note_table.dart';
import 'package:journal_app/domain/models/note_model.dart';
import 'package:journal_app/feature/notes/view_models/note_view_model.dart';
import 'package:journal_app/feature/notes/widgets/task_priority_widget.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.dueTime,
    required this.priority,
    required this.tags,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final String description;
  final DateTime dueTime;
  final bool isCompleted;
  final Priority priority;
  final List<String> tags;

  // this function is used to show the task options
  void _showTaskOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                context: context,
                icon: isCompleted
                    ? Icons.undo_rounded
                    : Icons.check_circle_outline,
                label: isCompleted ? 'Mark as Undone' : 'Mark as Done',
                color: isCompleted
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.primary,
                onTap: () {
                  ref
                      .read(noteViewModelProvider.notifier)
                      .toggleNoteCompletion(id);
                  Navigator.pop(context);
                },
              ),
              _buildOptionTile(
                context: context,
                icon: Icons.edit_outlined,
                label: 'Edit Task',
                color: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  // Get the actual task from provider to preserve all original data
                  // final taskState = ref.read(taskProvider);
                  // final actualTask = taskState.tasks.firstWhere(
                  //   (t) => t.id == id,
                  // );

                  Navigator.pop(context);
                  // Open edit task bottom sheet with actual task data
                  // showModalBottomSheet(
                  //   context: context,
                  //   isScrollControlled: true,
                  //   useSafeArea: true,
                  //   backgroundColor: Colors.transparent,
                  // builder: (context) => AddTasks(taskToEdit: actualTask),
                  // );
                },
              ),
              _buildOptionTile(
                context: context,
                icon: Icons.delete_outline,
                label: 'Delete Task',
                color: Theme.of(context).colorScheme.error,
                onTap: () {
                  ref.read(noteViewModelProvider.notifier).deleteNote(id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  this is the option tile widget
  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showTaskOptions(context, ref),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6)
                          : Theme.of(context).colorScheme.onSurface,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        formatDateAndTimeDifference(dueTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const Spacer(),
                      // TaskLableWidget(labels: tags),
                      const SizedBox(width: 4),
                      PriorityWidget(priority: priority),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
