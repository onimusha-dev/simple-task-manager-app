import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/calender_screen/calendar_date_provider.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';

import 'package:fuck_your_todos/feature/notes/widgets/tasks_cards.dart';
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
        SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: selectedTasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  id: selectedTasks[index].id,
                  title: selectedTasks[index].title,
                  description: selectedTasks[index].description ?? '',
                  dueTime:
                      selectedTasks[index].dueDate ??
                      selectedTasks[index].createdAt,
                  priority: selectedTasks[index].priority,
                  tags: [],
                  isCompleted: selectedTasks[index].isCompleted,
                  taskType: selectedTasks[index].taskType,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
