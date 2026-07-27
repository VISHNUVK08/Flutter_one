import 'package:flutter/material.dart';
import 'subtask.dart';

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.blue;
      case TaskPriority.medium:
        return Colors.amber.shade700;
      case TaskPriority.high:
        return Colors.orange.shade800;
      case TaskPriority.urgent:
        return Colors.red.shade700;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
      case TaskPriority.urgent:
        return Icons.warning_amber_rounded;
    }
  }
}

class TodoItem {
  final String id;
  String title;
  String notes;
  bool isCompleted;
  TaskPriority priority;
  String categoryId;
  DateTime? dueDate;
  List<SubTask> subtasks;
  bool isStarred;
  List<String> tags;
  DateTime createdAt;
  DateTime? completedAt;

  TodoItem({
    required this.id,
    required this.title,
    this.notes = '',
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.categoryId = 'personal',
    this.dueDate,
    List<SubTask>? subtasks,
    this.isStarred = false,
    List<String>? tags,
    DateTime? createdAt,
    this.completedAt,
  })  : subtasks = subtasks ?? [],
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();

  int get completedSubtaskCount =>
      subtasks.where((subtask) => subtask.isCompleted).length;

  double get completionProgress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    return completedSubtaskCount / subtasks.length;
  }

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'categoryId': categoryId,
      'dueDate': dueDate?.toIso8601String(),
      'subtasks': subtasks.map((st) => st.toJson()).toList(),
      'isStarred': isStarred,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values[
          (json['priority'] as int? ?? TaskPriority.medium.index)
              .clamp(0, TaskPriority.values.length - 1)],
      categoryId: json['categoryId'] as String? ?? 'personal',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((st) => SubTask.fromJson(st as Map<String, dynamic>))
              .toList() ??
          [],
      isStarred: json['isStarred'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  TodoItem copyWith({
    String? id,
    String? title,
    String? notes,
    bool? isCompleted,
    TaskPriority? priority,
    String? categoryId,
    DateTime? dueDate,
    List<SubTask>? subtasks,
    bool? isStarred,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      subtasks: subtasks ?? List.from(this.subtasks),
      isStarred: isStarred ?? this.isStarred,
      tags: tags ?? List.from(this.tags),
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
