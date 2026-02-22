import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/utils/date_formatter.dart';
import 'package:fuck_your_todos/feature/home_screen/widgets/no_task_placeholder.dart';
import 'package:fuck_your_todos/feature/home_screen/widgets/no_task_remaining_widget.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'package:fuck_your_todos/feature/notes/widgets/tasks_cards.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(noteViewModelProvider);

    final todayTasks = tasksState.notes
        .where((t) => isToday(t.createdAt) && !t.isCompleted)
        .toList();

    todayTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final todayCompletedTasks = tasksState.notes
        .where((t) => isToday(t.createdAt) && t.isCompleted)
        .toList();

    todayCompletedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (todayTasks.isEmpty && todayCompletedTasks.isEmpty) {
      return const NoTaskPlaceholder();
    }

    final hasCompleted = todayCompletedTasks.isNotEmpty;

    final todaySectionLength = todayTasks.isEmpty ? 1 : todayTasks.length;

    final itemCount =
        1 + // Today header
        todaySectionLength +
        (hasCompleted ? 1 + todayCompletedTasks.length : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // ───────────────── Today header ─────────────────
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "${todayTasks.length} tasks remaining",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          // ───────────────── Today tasks / Placeholder ─────────────────
          if (index <= todaySectionLength) {
            if (todayTasks.isEmpty) {
              return const NoTaskRemainingWidget();
            }
            final task = todayTasks[index - 1];
            return TaskCard(
              id: task.id,
              title: task.title,
              description: task.description ?? '',
              dueTime: task.createdAt,
              priority: task.priority,
              tags: [],
              isCompleted: task.isCompleted,
            );
          }

          // ───────────────── Completed header ─────────────────
          if (hasCompleted && index == todaySectionLength + 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Completed",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "${todayCompletedTasks.length} tasks completed",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          // ───────────────── Completed tasks ─────────────────
          final completedIndex = index - todaySectionLength - 2;

          final completedTask = todayCompletedTasks[completedIndex];

          return TaskCard(
            id: completedTask.id,
            title: completedTask.title,
            description: completedTask.description ?? '',
            dueTime: completedTask.createdAt,
            priority: completedTask.priority,
            tags: [],
            isCompleted: completedTask.isCompleted,
          );
        },
      ),
    );
  }
}
