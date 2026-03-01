import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'package:fuck_your_todos/feature/notes/widgets/create_note_view.dart';

void showTaskOptions(
  BuildContext context,
  WidgetRef ref,
  int id,
  bool isCompleted,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildOptionTile(
              context: context,
              icon: isCompleted
                  ? Icons.undo_rounded
                  : Icons.check_circle_outline,
              label: isCompleted ? 'Mark as Undone' : 'Mark as Done',
              color: isCompleted
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.primary,
              onTap: () {
                ref
                    .read(noteViewModelProvider.notifier)
                    .toggleNoteCompletion(id);
                Navigator.pop(context);
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Icons.edit_outlined,
              label: 'Edit Task',
              color: Theme.of(context).colorScheme.secondary,
              onTap: () {
                final taskState = ref.read(noteViewModelProvider);
                final actualNote = taskState.notes.firstWhere(
                  (t) => t.id == id,
                );

                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  enableDrag: false,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CreateNoteView(noteToEdit: actualNote),
                );
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Icons.delete_outline,
              label: 'Delete Task',
              color: Theme.of(context).colorScheme.error,
              onTap: () {
                ref.read(noteViewModelProvider.notifier).deleteNote(id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Task deleted',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildOptionTile({
  required BuildContext context,
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    ),
    title: Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
