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
        .where((t) => isToday(t.dueDate ?? t.createdAt) && !t.isCompleted)
        .toList();

    todayTasks.sort(
      (a, b) => (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt),
    );

    final todayCompletedTasks = tasksState.notes
        .where((t) => isToday(t.dueDate ?? t.createdAt) && t.isCompleted)
        .toList();

    todayCompletedTasks.sort(
      (a, b) => (b.dueDate ?? b.createdAt).compareTo(a.dueDate ?? a.createdAt),
    );

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
        padding: const EdgeInsets.only(top: 12, bottom: 100),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // ───────────────── Today header ─────────────────
          if (index == 0) {
            final totalTodayTasks =
                todayTasks.length + todayCompletedTasks.length;
            final progress = totalTodayTasks == 0
                ? 0.0
                : todayCompletedTasks.length / totalTodayTasks;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(
                              Theme.of(context).colorScheme.primary,
                              Colors.black,
                              0.15,
                            ) ??
                            Theme.of(context).colorScheme.primary,
                        Color.lerp(
                              Theme.of(context).colorScheme.tertiary,
                              Colors.black,
                              0.15,
                            ) ??
                            Theme.of(context).colorScheme.tertiary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Overview",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                totalTodayTasks == 0
                                    ? "No tasks today"
                                    : "${todayCompletedTasks.length} / $totalTodayTasks Tasks done",
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.pending_actions_rounded,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${todayTasks.length} Left",
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    "Today's Tasks",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
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
              dueTime: task.dueDate ?? task.createdAt,
              priority: task.priority,
              tags: [],
              isCompleted: task.isCompleted,
              taskType: task.taskType,
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
            dueTime: completedTask.dueDate ?? completedTask.createdAt,
            priority: completedTask.priority,
            tags: [],
            isCompleted: completedTask.isCompleted,
            taskType: completedTask.taskType,
          );
        },
      ),
    );
  }
}
