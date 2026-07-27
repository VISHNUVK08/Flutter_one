import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';
import '../models/subtask.dart';
import '../providers/task_provider.dart';

class TaskDetailDialog extends StatefulWidget {
  final TodoItem? initialTask;
  final TaskProvider provider;

  const TaskDetailDialog({
    super.key,
    this.initialTask,
    required this.provider,
  });

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _subtaskInputController;
  late TextEditingController _tagInputController;

  late TaskPriority _priority;
  late String _selectedCategoryId;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  late bool _isStarred;
  late List<SubTask> _subtasks;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _notesController = TextEditingController(text: task?.notes ?? '');
    _subtaskInputController = TextEditingController();
    _tagInputController = TextEditingController();

    _priority = task?.priority ?? TaskPriority.medium;
    _selectedCategoryId = task?.categoryId ??
        (widget.provider.categories.isNotEmpty
            ? widget.provider.categories.first.id
            : 'personal');
    _dueDate = task?.dueDate;
    if (task?.dueDate != null) {
      _dueTime = TimeOfDay.fromDateTime(task!.dueDate!);
    }
    _isStarred = task?.isStarred ?? false;
    _subtasks = task != null ? List.from(task.subtasks) : [];
    _tags = task != null ? List.from(task.tags) : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _subtaskInputController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _dueTime?.hour ?? 12,
          _dueTime?.minute ?? 0,
        );
      });
    }
  }

  void _pickDueTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _dueTime = pickedTime;
        if (_dueDate != null) {
          _dueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          final now = DateTime.now();
          _dueDate = DateTime(
            now.year,
            now.month,
            now.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      });
    }
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(
          SubTask(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: text,
          ),
        );
        _subtaskInputController.clear();
      });
    }
  }

  void _addTag() {
    final text = _tagInputController.text.trim().replaceAll('#', '');
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagInputController.clear();
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      DateTime? finalDueDate = _dueDate;
      if (_dueDate != null && _dueTime != null) {
        finalDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime!.hour,
          _dueTime!.minute,
        );
      }

      if (widget.initialTask == null) {
        final newTask = TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          notes: _notesController.text.trim(),
          priority: _priority,
          categoryId: _selectedCategoryId,
          dueDate: finalDueDate,
          subtasks: _subtasks,
          isStarred: _isStarred,
          tags: _tags,
        );
        widget.provider.addTask(newTask);
      } else {
        final updatedTask = widget.initialTask!.copyWith(
          title: _titleController.text.trim(),
          notes: _notesController.text.trim(),
          priority: _priority,
          categoryId: _selectedCategoryId,
          dueDate: finalDueDate,
          subtasks: _subtasks,
          isStarred: _isStarred,
          tags: _tags,
        );
        widget.provider.updateTask(updatedTask);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTask != null;
    final categories = widget.provider.categories;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Task' : 'New Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: _isStarred ? Colors.amber : null,
                          ),
                          onPressed: () {
                            setState(() {
                              _isStarred = !_isStarred;
                            });
                          },
                          tooltip: 'Star task',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Scrollable Form Body
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Title Input
                        TextFormField(
                          controller: _titleController,
                          autofocus: !isEditing,
                          decoration: const InputDecoration(
                            hintText: 'What do you need to do?',
                            labelText: 'Task Title *',
                            prefixIcon: Icon(Icons.check_circle_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a task title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Priority Selector
                        const Text(
                          'Priority Level',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: TaskPriority.values.map((priority) {
                            final isSelected = _priority == priority;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: ChoiceChip(
                                  showCheckmark: false,
                                  label: Text(
                                    priority.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : priority.color,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: priority.color,
                                  backgroundColor: priority.color.withValues(alpha: 0.1),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _priority = priority;
                                      });
                                    }
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown & Date Picker Row
                        Row(
                          children: [
                            // Category Selector
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Category',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedCategoryId,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    items: categories.map((cat) {
                                      return DropdownMenuItem<String>(
                                        value: cat.id,
                                        child: Row(
                                          children: [
                                            Icon(cat.icon, color: cat.color, size: 18),
                                            const SizedBox(width: 8),
                                            Text(cat.name, style: const TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedCategoryId = val;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Due Date and Time Section
                        const Text(
                          'Due Date & Time',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                                label: Text(
                                  _dueDate != null
                                      ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                                      : 'Set Date',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                onPressed: _pickDueDate,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.access_time_rounded, size: 16),
                                label: Text(
                                  _dueTime != null
                                      ? _dueTime!.format(context)
                                      : 'Set Time',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                onPressed: _pickDueTime,
                              ),
                            ),
                            if (_dueDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _dueDate = null;
                                    _dueTime = null;
                                  });
                                },
                                tooltip: 'Clear date',
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Subtasks / Checklist
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtasks (${_subtasks.where((s) => s.isCompleted).length}/${_subtasks.length})',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _subtaskInputController,
                                decoration: const InputDecoration(
                                  hintText: 'Add a subtask step...',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onSubmitted: (_) => _addSubtask(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_rounded),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: _addSubtask,
                            ),
                          ],
                        ),
                        if (_subtasks.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _subtasks.length,
                            itemBuilder: (context, index) {
                              final sub = _subtasks[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: sub.isCompleted,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (val) {
                                        setState(() {
                                          _subtasks[index].isCompleted = val ?? false;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        sub.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          decoration: sub.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 16),
                                      onPressed: () {
                                        setState(() {
                                          _subtasks.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Tags Section
                        const Text(
                          'Tags',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagInputController,
                                decoration: const InputDecoration(
                                  hintText: 'Add tag (e.g. work, design)',
                                  prefixText: '# ',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onSubmitted: (_) => _addTag(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.label_outline_rounded),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: _addTag,
                            ),
                          ],
                        ),
                        if (_tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _tags.map((tag) {
                              return Chip(
                                label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () {
                                  setState(() {
                                    _tags.remove(tag);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Notes & Description Text Box
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Add any details, links, or notes...',
                            labelText: 'Notes',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Save & Cancel Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _saveForm,
                      icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                      label: Text(isEditing ? 'Save Changes' : 'Create Task'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
