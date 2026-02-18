import 'package:drift/drift.dart';
import 'package:journal_app/data/db/app_database.dart';
import 'package:journal_app/data/db/tables/note_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_dao.g.dart';

@riverpod
NoteDao noteDaoProvider(Ref ref) {
  final db = ref.watch(appDatabaseProviderProvider);
  return NoteDao(db);
}

@DriftAccessor(tables: [NoteTable])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(super.attachedDatabase);

  // Return all notes from the db
  Future<List<NoteTableData>> getAllNotes() {
    return (select(noteTable).get());
  }

  // Return all notes from the db in a stream
  Stream<List<NoteTableData>> watchAllNotes() {
    return (select(noteTable)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  // insert a new note
  Future<int> insertNote(NoteTableCompanion note) {
    return (into(noteTable).insert(note));
  }

  // get a note by id
  Future<NoteTableData> getNoteById(int id) {
    return (select(noteTable)..where((t) => t.id.equals(id))).getSingle();
  }

  // update a note
  Future<bool> updateNote(NoteTableCompanion note) {
    return (update(noteTable).replace(note));
  }

  // delete a note
  Future<int> deleteNote(int id) {
    return (delete(noteTable)..where((t) => t.id.equals(id))).go();
  }

  // delete all notes
  Future<int> deleteAllNotes() {
    return (delete(noteTable)).go();
  }

  // search notes by text
  Stream<List<NoteTableData>> searchByText(String query) {
    final searchTerm = query.toLowerCase();

    return (select(noteTable)
          ..where(
            (t) =>
                t.title.like('%$searchTerm%') |
                t.description.like('%$searchTerm%'),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }
}
