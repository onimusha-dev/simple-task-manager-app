import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal_app/core/theme/app_theme.dart';
import 'package:journal_app/core/theme/theme_provider.dart';
import 'package:journal_app/data/db/tables/note_table.dart';
import 'package:journal_app/feature/home_screen/home_screen.dart';
import 'package:journal_app/feature/notes/view_models/note_view_model.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: Scaffold(
        appBar: AppBar(title: const Text("Journal App")),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ref
                .read(noteViewModelProvider.notifier)
                .insertNote(
                  "Demo Note",
                  "This is a demo description",
                  null,
                  Priority.low,
                );
          },
          child: const Icon(Icons.add),
        ),
        body: HomeScreen(),
      ),
    );
  }
}
