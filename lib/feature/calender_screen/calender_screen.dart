import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/calender_screen/provider/calendar_date_provider.dart';
import 'package:fuck_your_todos/feature/calender_screen/widgets/shownotes.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'widgets/week_carousel_widget.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    // Reset to today so notes created from other tabs always default to today.
    ref.read(selectedCalendarDateProvider.notifier).setDate(DateTime.now());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTasksForDate = ref.watch(noteViewModelProvider).notes.where((
      note,
    ) {
      // Use dueDate if set, otherwise fall back to createdAt
      final dateToMatch = (note.dueDate ?? note.createdAt).toLocal();
      return dateToMatch.year == _selectedDate.year &&
          dateToMatch.month == _selectedDate.month &&
          dateToMatch.day == _selectedDate.day;
    }).toList();

    final incompleteTasks = allTasksForDate
        .where((t) => !t.isCompleted)
        .toList();
    final completedTasks = allTasksForDate.where((t) => t.isCompleted).toList();

    incompleteTasks.sort(
      (a, b) => (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt),
    );
    completedTasks.sort(
      (a, b) => (b.dueDate ?? b.createdAt).compareTo(a.dueDate ?? a.createdAt),
    );

    final selectedTasks = [...incompleteTasks, ...completedTasks];

    return Column(
      children: [
        WeekCarouselWidget(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() => _selectedDate = date);
            // Keep shared provider in sync so CreateNoteView can read it
            ref.read(selectedCalendarDateProvider.notifier).setDate(date);
          },
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount:
                selectedTasks.length + (selectedTasks.isNotEmpty ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == selectedTasks.length) {
                final lastTask = selectedTasks.last;
                final lastTime = (lastTask.dueDate ?? lastTask.createdAt);
                // Just add 1 hour or something for the footer timestamp
                final footerTime = lastTime.add(const Duration(hours: 1));
                return TimelineFooter(time: footerTime);
              }
              final task = selectedTasks[index];
              return Shownotes(
                id: task.id,
                title: task.title,
                description: task.description ?? '',
                dueTime: task.dueDate ?? task.createdAt,
                priority: task.priority,
                tags: const [],
                isCompleted: task.isCompleted,
                taskType: task.taskType,
              );
            },
          ),
        ),
      ],
    );
  }
}
