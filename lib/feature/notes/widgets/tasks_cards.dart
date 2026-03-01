import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/tables/note_table.dart';
import 'package:fuck_your_todos/domain/models/note_model.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'package:fuck_your_todos/data/db/app_database.dart';
import 'package:fuck_your_todos/feature/notes/view_models/task_category_view_model.dart';
import 'package:fuck_your_todos/feature/notes/widgets/create_note_view.dart';
import 'package:fuck_your_todos/feature/notes/widgets/task_edit_options.dart';
import 'package:fuck_your_todos/feature/notes/widgets/task_priority_widget.dart';

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
    this.taskType,
  });

  final int id;
  final String title;
  final String description;
  final DateTime dueTime;
  final bool isCompleted;
  final Priority priority;
  final List<String> tags;
  final int? taskType;

  String _getCategoryIcon(WidgetRef ref) {
    if (taskType == null) return '';
    final categoriesState = ref.watch(taskCategoryViewModelProvider);
    return categoriesState.maybeWhen(
      data: (cats) {
        final match = cats.cast<TaskCategoriesTableData?>().firstWhere(
          (c) => c?.id == taskType,
          orElse: () => null,
        );
        return match?.icon ?? '';
      },
      orElse: () => '',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: () => showTaskOptions(context, ref, id, isCompleted),
        onTap: () => showTaskOptions(context, ref, id, isCompleted),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // this is the task logo
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Builder(
                  builder: (context) {
                    final iconStr = _getCategoryIcon(ref);
                    if (iconStr.isNotEmpty) {
                      return Center(
                        child: Text(
                          iconStr,
                          style: const TextStyle(fontSize: 24),
                        ),
                      );
                    } else {
                      return Icon(
                        Icons.more_horiz_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5)
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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

              // this is the check box
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(noteViewModelProvider.notifier)
                          .toggleNoteCompletion(id);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
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
                              Icons.check_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
