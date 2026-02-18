import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal_app/data/repository/note_repository.dart';
import 'package:journal_app/ui/view_models/state/note_state.dart';

final noteViewModelProvider = NotifierProvider<NoteViewModel, NoteState>(
  () => NoteViewModel(),
);

class NoteViewModel extends Notifier<NoteState> {
  @override
  NoteState build() {
    // Load notes when the provider is first read
    Future.microtask(() => getAllNotes());
    return NoteState();
  }

  Future<void> getAllNotes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notes = await ref.read(noteRepositoryProvider).getAllNotes();
      state = state.copyWith(isLoading: false, notes: notes, error: null);
    } catch (e, s) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notes: $e\n$s',
      );
    }
  }

  Future<void> getNoteById(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final note = await ref.read(noteRepositoryProvider).getNoteById(id);
      state = state.copyWith(isLoading: false, notes: [note], error: null);
    } catch (e, s) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load note: $e\n$s',
      );
    }
  }

  Future<void> insertNote(
    String title,
    String? description,
    String? dueDate,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref
          .read(noteRepositoryProvider)
          .insertNote(title, description, dueDate);
      await getAllNotes();
    } catch (e, s) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to insert note: $e\n$s',
      );
    }
  }

  Future<void> updateNote(
    int id,
    String title,
    String? description,
    String? dueDate,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref
          .read(noteRepositoryProvider)
          .updateNote(id, title, description, dueDate);
      await getAllNotes();
    } catch (e, s) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update note: $e\n$s',
      );
    }
  }

  Future<void> deleteNote(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(noteRepositoryProvider).deleteNote(id);
      await getAllNotes();
    } catch (e, s) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete note: $e\n$s',
      );
    }
  }

  Future<void> deleteAllNotes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(noteRepositoryProvider).deleteAllNotes();
      await getAllNotes();
    } catch (e, s) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete all notes: $e\n$s',
      );
    }
  }

  // Future<void> searchByText(String query) async {
  //   state = state.copyWith(isLoading: true, error: null);

  //   try {
  //     final notes = ref.read(noteRepositoryProvider).searchByText(query);
  //     state = state.copyWith(isLoading: false, notes: notes, error: null);
  //   } catch (e, s) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: 'Failed to search notes: $e\n$s',
  //     );
  //   }
  // }
}
