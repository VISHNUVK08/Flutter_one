import 'package:flutter/material.dart';

class TaskCategory {
  final String id;
  final String name;
  final int colorValue;
  final int iconCodePoint;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
  });

  Color get color => Color(colorValue);

  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
    };
  }

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int,
      iconCodePoint: json['iconCodePoint'] as int,
    );
  }

  // Pre-configured default categories
  static List<TaskCategory> defaultCategories = [
    TaskCategory(
      id: 'personal',
      name: 'Personal',
      colorValue: 0xFF9C27B0,
      iconCodePoint: Icons.person_rounded.codePoint,
    ),
    TaskCategory(
      id: 'work',
      name: 'Work',
      colorValue: 0xFF2196F3,
      iconCodePoint: Icons.work_rounded.codePoint,
    ),
    TaskCategory(
      id: 'shopping',
      name: 'Shopping',
      colorValue: 0xFFFF9800,
      iconCodePoint: Icons.shopping_cart_rounded.codePoint,
    ),
    TaskCategory(
      id: 'health',
      name: 'Health & Fitness',
      colorValue: 0xFF4CAF50,
      iconCodePoint: Icons.favorite_rounded.codePoint,
    ),
    TaskCategory(
      id: 'learning',
      name: 'Learning',
      colorValue: 0xFF009688,
      iconCodePoint: Icons.school_rounded.codePoint,
    ),
    TaskCategory(
      id: 'finance',
      name: 'Finance',
      colorValue: 0xFFFFC107,
      iconCodePoint: Icons.attach_money_rounded.codePoint,
    ),
  ];
}
