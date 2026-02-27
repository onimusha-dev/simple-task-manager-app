// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_category_dao.dart';

// ignore_for_file: type=lint
mixin _$TaskCategoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $TaskCategoriesTableTable get taskCategoriesTable =>
      attachedDatabase.taskCategoriesTable;
  TaskCategoryDaoManager get managers => TaskCategoryDaoManager(this);
}

class TaskCategoryDaoManager {
  final _$TaskCategoryDaoMixin _db;
  TaskCategoryDaoManager(this._db);
  $$TaskCategoriesTableTableTableManager get taskCategoriesTable =>
      $$TaskCategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.taskCategoriesTable,
      );
}
