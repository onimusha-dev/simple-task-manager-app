import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/core/constants/constants.dart';
import 'package:fuck_your_todos/core/utils/date_formatter.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/account_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/appearance_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/data_and_privacy_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/categories_screen/categories_screen.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/about_screen.dart';

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
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              _buildSettingsTile(
                context: context,
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Theme, Language',
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
                icon: Icons.shield_outlined,
                title: 'Data & Privacy',
                subtitle: 'Protect the app, Backup and restore, Data deletion',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataAndPrivacyScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                context: context,
                icon: Icons.category_outlined,
                title: 'Categories',
                subtitle: 'Manage task categories',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                context: context,
                icon: Icons.account_circle_outlined,
                title: 'Account',
                subtitle: 'Cloud sync, Online data, Premium',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                context: context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version ${AppConstants.appVersion}',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
    );
  }
}
