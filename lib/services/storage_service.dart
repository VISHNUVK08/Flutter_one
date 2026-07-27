import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';
import '../models/category.dart';

class StorageService {
  static const String _tasksKey = 'taskmaster_todos_v1';
  static const String _categoriesKey = 'taskmaster_categories_v1';
  static const String _themeKey = 'taskmaster_theme_v1';
  static const String _sortKey = 'taskmaster_sort_v1';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Load tasks
  List<TodoItem> loadTasks() {
    final jsonString = _prefs.getString(_tasksKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => TodoItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save tasks
  Future<bool> saveTasks(List<TodoItem> tasks) async {
    final jsonList = tasks.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    return await _prefs.setString(_tasksKey, jsonString);
  }

  // Load custom categories
  List<TaskCategory> loadCategories() {
    final jsonString = _prefs.getString(_categoriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return TaskCategory.defaultCategories;
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => TaskCategory.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return TaskCategory.defaultCategories;
    }
  }

  // Save custom categories
  Future<bool> saveCategories(List<TaskCategory> categories) async {
    final jsonList = categories.map((c) => c.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    return await _prefs.setString(_categoriesKey, jsonString);
  }

  // Load theme mode index (0: system, 1: light, 2: dark)
  int loadThemeModeIndex() {
    return _prefs.getInt(_themeKey) ?? 0;
  }

  // Save theme mode index
  Future<bool> saveThemeModeIndex(int index) async {
    return await _prefs.setInt(_themeKey, index);
  }

  // Load sort mode index
  int loadSortModeIndex() {
    return _prefs.getInt(_sortKey) ?? 0;
  }

  // Save sort mode index
  Future<bool> saveSortModeIndex(int index) async {
    return await _prefs.setInt(_sortKey, index);
  }

  // Export data string
  String exportAllData(List<TodoItem> tasks, List<TaskCategory> categories) {
    final map = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };
    return jsonEncode(map);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.remove(_tasksKey);
    await _prefs.remove(_categoriesKey);
  }
}
