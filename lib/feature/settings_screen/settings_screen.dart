import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/utils/date_formatter.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/appearance_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: [
          _buildSettingsTile(
            context: context,
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Change the look and feel of the app',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearanceScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: () {},
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.info_outline,
            title: 'Others',
            subtitle: 'Version 1.0.0',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  duration: Duration(seconds: 3),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
