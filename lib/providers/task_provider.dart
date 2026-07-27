import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../models/subtask.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

enum SortOption {
  dueDate,
  priority,
  title,
  createdAt,
}

class TaskProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<TodoItem> _tasks = [];
  List<TaskCategory> _categories = [];
  
  String _searchQuery = '';
  String _activeFilter = 'All'; // 'All', 'Active', 'Completed', 'Starred', 'Overdue'
  String? _selectedCategoryFilter;
  SortOption _sortOption = SortOption.dueDate;
  ThemeMode _themeMode = ThemeMode.system;

  bool _isLoading = true;

  TaskProvider(this._storageService) {
    _initData();
  }

  // Getters
  bool get isLoading => _isLoading;
  List<TodoItem> get allTasks => _tasks;
  List<TaskCategory> get categories => _categories;
  String get searchQuery => _searchQuery;
  String get activeFilter => _activeFilter;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  SortOption get sortOption => _sortOption;
  ThemeMode get themeMode => _themeMode;

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    _categories = _storageService.loadCategories();
    _tasks = _storageService.loadTasks();
    
    final themeIndex = _storageService.loadThemeModeIndex();
    _themeMode = ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1)];

    final sortIndex = _storageService.loadSortModeIndex();
    _sortOption = SortOption.values[sortIndex.clamp(0, SortOption.values.length - 1)];

    // Seed sample tasks if empty on first launch
    if (_tasks.isEmpty) {
      _seedSampleData();
      await _storageService.saveTasks(_tasks);
    }

    _isLoading = false;
    notifyListeners();
  }

  void _seedSampleData() {
    final now = DateTime.now();
    _tasks = [
      TodoItem(
        id: '1',
        title: 'Design TaskMaster UI Concept 🎨',
        notes: 'Create vibrant Material 3 themes, dark mode palette, and card components.',
        isCompleted: true,
        priority: TaskPriority.high,
        categoryId: 'work',
        dueDate: now.subtract(const Duration(hours: 4)),
        isStarred: true,
        subtasks: [
          SubTask(id: 's1', title: 'Color System setup', isCompleted: true),
          SubTask(id: 's2', title: 'Typography selection', isCompleted: true),
        ],
        tags: ['design', 'ui', 'flutter'],
        createdAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(hours: 2)),
      ),
      TodoItem(
        id: '2',
        title: 'Weekly Grocery Shopping 🛒',
        notes: 'Buy fresh produce, oat milk, and organic eggs.',
        isCompleted: false,
        priority: TaskPriority.medium,
        categoryId: 'shopping',
        dueDate: now.add(const Duration(hours: 5)),
        isStarred: false,
        subtasks: [
          SubTask(id: 's3', title: 'Spinach & Avocados', isCompleted: true),
          SubTask(id: 's4', title: 'Almond milk & Greek yogurt', isCompleted: false),
          SubTask(id: 's5', title: 'Whole grain bread', isCompleted: false),
        ],
        tags: ['home', 'grocery'],
        createdAt: now,
      ),
      TodoItem(
        id: '3',
        title: 'Complete Flutter State Refactoring ⚡',
        notes: 'Implement reactive TaskProvider, persistence layer, and analytics view.',
        isCompleted: false,
        priority: TaskPriority.urgent,
        categoryId: 'work',
        dueDate: now.add(const Duration(days: 1)),
        isStarred: true,
        subtasks: [
          SubTask(id: 's6', title: 'StorageService local JSON', isCompleted: true),
          SubTask(id: 's7', title: 'Category CRUD operations', isCompleted: false),
          SubTask(id: 's8', title: 'Export & Import feature', isCompleted: false),
        ],
        tags: ['code', 'dev'],
        createdAt: now,
      ),
      TodoItem(
        id: '4',
        title: '30-Minute Cardio Session 🏃‍♂️',
        notes: 'Interval running at the local park or treadmill.',
        isCompleted: false,
        priority: TaskPriority.low,
        categoryId: 'health',
        dueDate: now.add(const Duration(days: 2)),
        isStarred: false,
        tags: ['fitness', 'health'],
        createdAt: now,
      ),
    ];
  }

  // Set Search Query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set Filter
  void setActiveFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  // Set Category Filter
  void setSelectedCategoryFilter(String? categoryId) {
    _selectedCategoryFilter = categoryId;
    notifyListeners();
  }

  // Set Sort Option
  void setSortOption(SortOption option) {
    _sortOption = option;
    _storageService.saveSortModeIndex(option.index);
    notifyListeners();
  }

  // Set Theme Mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _storageService.saveThemeModeIndex(mode.index);
    notifyListeners();
  }

  // Filtered and Sorted Task List
  List<TodoItem> get filteredTasks {
    List<TodoItem> list = List.from(_tasks);

    // Apply category filter
    if (_selectedCategoryFilter != null && _selectedCategoryFilter!.isNotEmpty) {
      list = list.where((t) => t.categoryId == _selectedCategoryFilter).toList();
    }

    // Apply status filter
    if (_activeFilter == 'Active') {
      list = list.where((t) => !t.isCompleted).toList();
    } else if (_activeFilter == 'Completed') {
      list = list.where((t) => t.isCompleted).toList();
    } else if (_activeFilter == 'Starred') {
      list = list.where((t) => t.isStarred).toList();
    } else if (_activeFilter == 'Overdue') {
      list = list.where((t) => t.isOverdue).toList();
    }

    // Apply search query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((t) {
        final titleMatch = t.title.toLowerCase().contains(query);
        final notesMatch = t.notes.toLowerCase().contains(query);
        final tagMatch = t.tags.any((tag) => tag.toLowerCase().contains(query));
        return titleMatch || notesMatch || tagMatch;
      }).toList();
    }

    // Apply sorting
    list.sort((a, b) {
      // Starred tasks first option
      if (a.isStarred != b.isStarred) {
        return a.isStarred ? -1 : 1;
      }

      switch (_sortOption) {
        case SortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case SortOption.priority:
          return b.priority.index.compareTo(a.priority.index);
        case SortOption.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortOption.createdAt:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return list;
  }

  // Tasks due Today
  List<TodoItem> get todayTasks {
    return _tasks.where((t) => t.isDueToday || t.isOverdue).toList();
  }

  // Task Mutations
  Future<void> addTask(TodoItem item) async {
    _tasks.insert(0, item);
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(TodoItem updatedItem) async {
    final index = _tasks.indexWhere((t) => t.id == updatedItem.id);
    if (index != -1) {
      _tasks[index] = updatedItem;
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final current = _tasks[index];
      final newStatus = !current.isCompleted;
      
      // If task complete, toggle all subtasks complete too
      final updatedSubtasks = current.subtasks.map((st) {
        return st.copyWith(isCompleted: newStatus);
      }).toList();

      _tasks[index] = current.copyWith(
        isCompleted: newStatus,
        completedAt: newStatus ? DateTime.now() : null,
        subtasks: updatedSubtasks,
      );
      
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> toggleTaskStar(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isStarred: !_tasks[index].isStarred,
      );
      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedSubtasks = task.subtasks.map((st) {
        if (st.id == subtaskId) {
          return st.copyWith(isCompleted: !st.isCompleted);
        }
        return st;
      }).toList();

      final allSubtasksDone = updatedSubtasks.isNotEmpty &&
          updatedSubtasks.every((st) => st.isCompleted);

      _tasks[taskIndex] = task.copyWith(
        subtasks: updatedSubtasks,
        isCompleted: allSubtasksDone ? true : task.isCompleted,
        completedAt: allSubtasksDone ? DateTime.now() : task.completedAt,
      );

      await _storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((t) => t.isCompleted);
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  // Category Mutations
  Future<void> addCategory(TaskCategory category) async {
    _categories.add(category);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  TaskCategory getCategoryById(String id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => TaskCategory(
        id: 'general',
        name: 'General',
        colorValue: Colors.grey.value,
        iconCodePoint: Icons.category_rounded.codePoint,
      ),
    );
  }

  // Data Reset & Restore
  Future<void> resetToSampleData() async {
    _seedSampleData();
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> importJsonData(List<TodoItem> importedTasks, List<TaskCategory> importedCategories) async {
    _tasks = importedTasks;
    _categories = importedCategories;
    await _storageService.saveTasks(_tasks);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  String exportJsonData() {
    return _storageService.exportAllData(_tasks, _categories);
  }

  // Metrics & Statistics Calculations
  int get totalTaskCount => _tasks.length;
  int get completedTaskCount => _tasks.where((t) => t.isCompleted).length;
  int get activeTaskCount => _tasks.where((t) => !t.isCompleted).length;
  int get overdueTaskCount => _tasks.where((t) => t.isOverdue).length;
  int get starredTaskCount => _tasks.where((t) => t.isStarred).length;

  double get overallCompletionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTaskCount / _tasks.length;
  }
}
