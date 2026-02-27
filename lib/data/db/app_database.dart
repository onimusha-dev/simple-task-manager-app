import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fuck_your_todos/data/db/dao/note_dao.dart';
import 'package:fuck_your_todos/data/db/dao/task_category_dao.dart';
import 'package:fuck_your_todos/data/db/tables/note_table.dart';
import 'package:fuck_your_todos/data/db/tables/task_categories_table.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

// this is the db provider
@Riverpod(keepAlive: true)
AppDatabase appDatabaseProvider(Ref ref) {
  final db = AppDatabase();

  ref.onDispose(() {
    db.close();
  });
  return db;
}

// this is the main db class
@DriftDatabase(
  tables: [NoteTable, TaskCategoriesTable],
  daos: [NoteDao, TaskCategoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  // migration strategy to add new columns to the db
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Add the priority column (intEnum, default 0 = Priority.none)
        await customStatement(
          'ALTER TABLE note_table ADD COLUMN priority INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (from < 3) {
        await migrator.createTable(taskCategoriesTable);
        await migrator.addColumn(noteTable, noteTable.taskType);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'journal_app_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
