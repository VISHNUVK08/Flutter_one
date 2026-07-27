import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';
import '../providers/task_provider.dart';
import 'task_detail_dialog.dart';

class TasksScreen extends StatelessWidget {
  final TaskProvider provider;

  const TasksScreen({super.key, required this.provider});

  void _openAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => TaskDetailDialog(provider: provider),
    );
  }

  void _openEditTaskDialog(BuildContext context, TodoItem task) {
    showDialog(
      context: context,
      builder: (_) => TaskDetailDialog(initialTask: task, provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = provider.filteredTasks;
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'clear_completed') {
                provider.clearCompletedTasks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cleared completed tasks!')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_completed',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Clear Completed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // Live Search Bar
                TextField(
                  onChanged: (query) => provider.setSearchQuery(query),
                  decoration: InputDecoration(
                    hintText: 'Search tasks, notes, #tags...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => provider.setSearchQuery(''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter & Sort Controls Row
                Row(
                  children: [
                    // Sort Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SortOption>(
                            value: provider.sortOption,
                            isExpanded: true,
                            icon: const Icon(Icons.sort_rounded, size: 20),
                            items: const [
                              DropdownMenuItem(
                                value: SortOption.dueDate,
                                child: Text('Sort: Due Date', style: TextStyle(fontSize: 13)),
                              ),
                              DropdownMenuItem(
                                value: SortOption.priority,
                                child: Text('Sort: Priority', style: TextStyle(fontSize: 13)),
                              ),
                              DropdownMenuItem(
                                value: SortOption.title,
                                child: Text('Sort: Title (A-Z)', style: TextStyle(fontSize: 13)),
                              ),
                              DropdownMenuItem(
                                value: SortOption.createdAt,
                                child: Text('Sort: Created', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) provider.setSortOption(val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Category Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: provider.selectedCategoryFilter,
                            isExpanded: true,
                            hint: const Text('Category: All', style: TextStyle(fontSize: 13)),
                            icon: const Icon(Icons.category_rounded, size: 18),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Category: All', style: TextStyle(fontSize: 13)),
                              ),
                              ...categories.map((c) {
                                return DropdownMenuItem<String?>(
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Icon(c.icon, size: 14, color: c.color),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              provider.setSelectedCategoryFilter(val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Filter Status Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Active', 'Completed', 'Starred', 'Overdue'].map((filter) {
                      final isSelected = provider.activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              provider.setActiveFilter(filter);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 72,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.searchQuery.isNotEmpty
                              ? 'No tasks matching "${provider.searchQuery}"'
                              : 'No ${provider.activeFilter.toLowerCase()} tasks found.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openAddTaskDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Task'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _buildTaskCard(context, task);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TodoItem task) {
    final category = provider.getCategoryById(task.categoryId);

    return Dismissible(
      key: Key(task.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.green,
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          provider.toggleTaskCompletion(task.id);
          return false;
        } else {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Task?'),
              content: Text('Are you sure you want to delete "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      },
      onDismissed: (direction) {
        provider.deleteTask(task.id);
      },
      child: Card(
        child: ListTile(
          onTap: () => _openEditTaskDialog(context, task),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (_) => provider.toggleTaskCompletion(task.id),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    color: task.isCompleted
                        ? Colors.grey
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (task.isStarred)
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.notes,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, size: 12, color: category.color),
                        const SizedBox(width: 4),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: category.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Priority Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: task.priority.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.priority.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: task.priority.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Due Date Tag
                  if (task.dueDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.event_rounded,
                          size: 12,
                          color: task.isOverdue ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          DateFormat('MMM d, h:mm a').format(task.dueDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: task.isOverdue ? Colors.red : Colors.grey,
                            fontWeight: task.isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Tags wrap
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: task.tags.map((t) {
                    return Text(
                      '#$t',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _openEditTaskDialog(context, task),
          ),
        ),
      ),
    );
  }
}
