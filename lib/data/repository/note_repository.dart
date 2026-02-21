import 'package:drift/drift.dart';
import 'package:fuck_your_todos/core/utils/input_formatter.dart';
import 'package:fuck_your_todos/data/db/dao/note_dao.dart';
import 'package:fuck_your_todos/data/db/app_database.dart';
import 'package:fuck_your_todos/data/db/tables/note_table.dart';
import 'package:fuck_your_todos/domain/models/note_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_repository.g.dart';

@riverpod
NoteRepository noteRepository(Ref ref) {
  final noteDao = ref.watch(noteDaoProviderProvider);

  return NoteRepository(noteDao);
}

class NoteRepository {
  final NoteDao noteDao;

  NoteRepository(this.noteDao);

  // Return all notes from the db
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final notes = await noteDao.getAllNotes();
      return notes.map((note) => NoteModel.fromEntity(note)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  // Return all notes from the db in a stream
  Stream<List<NoteModel>> watchAllNotes() {
    try {
      return noteDao.watchAllNotes().map(
        (data) => data.map((e) => NoteModel.fromEntity(e)).toList(),
      );
    } catch (e) {
      return Stream.error(Exception(e));
    }
  }

  // insert a new note
  Future<int> insertNote(
    String title,
    String? description,
    String? dueDate,
    Priority? priority,
  ) async {
    try {
      final note = NoteTableCompanion(
        title: Value(getSubString(title, 50)),
        description: description != null
            ? Value(getSubString(description, 200))
            : const Value.absent(),
        dueDate: dueDate != null
            ? Value(DateTime.parse(dueDate))
            : const Value.absent(),
        priority: priority != null ? Value(priority) : const Value.absent(),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      final noteId = await noteDao.insertNote(note);
      return noteId;
    } catch (e) {
      throw Exception(e);
    }
  }

  // get a note by id
  Future<NoteModel> getNoteById(int id) async {
    try {
      final note = await noteDao.getNoteById(id);
      return NoteModel.fromEntity(note);
    } catch (e) {
      throw Exception(e);
    }
  }

  // update a note
  Future<int> updateNote(
    int id,
    String? title,
    String? description,
    String? dueDate,
  ) async {
    try {
      if (title == null && description == null && dueDate == null) {
        throw Exception('No fields to update');
      }
      final note = NoteTableCompanion(
        id: Value(id),
        title: title != null
            ? Value(getSubString(title, 50))
            : const Value.absent(),
        description: description != null
            ? Value(getSubString(description, 200))
            : const Value.absent(),
        dueDate: dueDate != null
            ? Value(DateTime.parse(dueDate))
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );
      final noteId = await noteDao.updateNote(note);
      return noteId;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<int> toggleCompletion(int id) async {
    try {
      final note = await noteDao.getNoteById(id);
      final isUpdated = await noteDao.updateNote(
        NoteTableCompanion(
          id: Value(id),
          isCompleted: Value(!note.isCompleted),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return isUpdated;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<int> updateNotePriority(int id, Priority priority) async {
    try {
      final noteId = await noteDao.updateNote(
        NoteTableCompanion(
          id: Value(id),
          priority: Value(priority),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return noteId;
    } catch (e) {
      throw Exception(e);
    }
  }

  // delete a note
  Future<int> deleteNote(int id) async {
    try {
      final noteId = await noteDao.deleteNote(id);
      return noteId;
    } catch (e) {
      throw Exception(e);
    }
  }

  // delete all notes
  Future<int> deleteAllNotes() async {
    try {
      final noteId = await noteDao.deleteAllNotes();
      return noteId;
    } catch (e) {
      throw Exception(e);
    }
  }

  // search notes by text
  Stream<List<NoteModel>> searchByText(String query) {
    try {
      final searchTerm = query.toLowerCase();
      final notes = noteDao.searchByText(searchTerm);
      return notes.map(
        (data) => data.map((e) => NoteModel.fromEntity(e)).toList(),
      );
    } catch (e) {
      return Stream.error(Exception(e));
    }
  }
}
