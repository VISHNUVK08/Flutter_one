import 'package:flutter/material.dart';
import '../models/category.dart';
import '../providers/task_provider.dart';

class CategoriesScreen extends StatelessWidget {
  final TaskProvider provider;

  const CategoriesScreen({super.key, required this.provider});

  void _showAddCategoryDialog(BuildContext context) {
    final titleController = TextEditingController();
    int selectedColorValue = 0xFF3F51B5;
    int selectedIconCodePoint = Icons.folder_rounded.codePoint;

    final colors = [
      0xFF3F51B5, // Indigo
      0xFF9C27B0, // Purple
      0xFF2196F3, // Blue
      0xFF009688, // Teal
      0xFF4CAF50, // Green
      0xFFFFC107, // Amber
      0xFFFF9800, // Orange
      0xFFF44336, // Red
      0xFFE91E63, // Pink
    ];

    final icons = [
      Icons.folder_rounded,
      Icons.star_rounded,
      Icons.bookmark_rounded,
      Icons.fitness_center_rounded,
      Icons.code_rounded,
      Icons.book_rounded,
      Icons.sports_esports_rounded,
      Icons.flight_rounded,
      Icons.home_rounded,
      Icons.work_rounded,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colors.map((colorVal) {
                      final isSelected = selectedColorValue == colorVal;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorValue = colorVal;
                          });
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(colorVal),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((iconData) {
                      final isSelected = selectedIconCodePoint == iconData.codePoint;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIconCodePoint = iconData.codePoint;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(selectedColorValue).withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Color(selectedColorValue), width: 2)
                                : null,
                          ),
                          child: Icon(iconData, color: Color(selectedColorValue), size: 24),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = titleController.text.trim();
                    if (name.isNotEmpty) {
                      final newCat = TaskCategory(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        colorValue: selectedColorValue,
                        iconCodePoint: selectedIconCodePoint,
                      );
                      provider.addCategory(newCat);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories & Projects'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.25,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final taskCount = provider.allTasks.where((t) => t.categoryId == cat.id).length;
          final completedCount = provider.allTasks
              .where((t) => t.categoryId == cat.id && t.isCompleted)
              .length;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                provider.setSelectedCategoryFilter(cat.id);
                provider.setActiveFilter('All');
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 24),
                        ),
                        if (!TaskCategory.defaultCategories.any((dc) => dc.id == cat.id))
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            color: Colors.redAccent,
                            onPressed: () => provider.deleteCategory(cat.id),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount / $taskCount tasks',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
      ),
    );
  }
}
