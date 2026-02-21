import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/utils/date_formatter.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: [
          Text('profile ${tasksState.notes.length}'),
          Text('profile ${tasksState.notes.length}'),
        ],
      ),
    );
  }
}
