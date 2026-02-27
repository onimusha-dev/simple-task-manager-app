import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/app_database.dart';

final taskCategoryViewModelProvider =
    NotifierProvider<
      TaskCategoryViewModel,
      AsyncValue<List<TaskCategoriesTableData>>
    >(() => TaskCategoryViewModel());

class TaskCategoryViewModel
    extends Notifier<AsyncValue<List<TaskCategoriesTableData>>> {
  @override
  AsyncValue<List<TaskCategoriesTableData>> build() {
    _loadCategories();
    return const AsyncValue.loading();
  }

  Future<void> _loadCategories() async {
    try {
      final db = ref.read(appDatabaseProviderProvider);
      final categories = await db.taskCategoryDao.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(String name, String icon) async {
    final db = ref.read(appDatabaseProviderProvider);
    await db.taskCategoryDao.insertCategory(
      TaskCategoriesTableCompanion.insert(name: name, icon: icon),
    );
    _loadCategories();
  }

  Future<void> updateCategory(TaskCategoriesTableData category) async {
    final db = ref.read(appDatabaseProviderProvider);
    await db.taskCategoryDao.updateCategory(category);
    _loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    final db = ref.read(appDatabaseProviderProvider);
    await db.taskCategoryDao.deleteCategory(id);
    _loadCategories();
  }
}
