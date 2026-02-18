import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal_app/.2/theme/app_theme.dart';
import 'package:journal_app/.2/theme/theme_provider.dart';
import 'package:journal_app/ui/view_models/note_view_model.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final noteViewModel = ref.watch(noteViewModelProvider);

    final notes = noteViewModel.notes;

    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: Scaffold(
        appBar: AppBar(title: Row(
          children: [
            IconButton(onPressed: (){
              ref.read(noteViewModelProvider.notifier).insertNote(
                "hi",
                "hello",
                "2026-02-18",
              );
            }, icon: const Icon(Icons.add)),
            Text("Journal App")
          ],
        )),
        body: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(notes[index].title));
          },
        ),
      ),
    );
  }
}
