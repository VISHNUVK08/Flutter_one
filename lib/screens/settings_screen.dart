import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/todo_item.dart';
import '../models/category.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  final TaskProvider provider;

  const SettingsScreen({super.key, required this.provider});

  void _showExportDialog(BuildContext context) {
    final jsonStr = provider.exportJsonData();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export JSON Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Copy your tasks backup string below:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy to Clipboard'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup copied to clipboard!')),
                );
              },
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import JSON Backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Paste your exported JSON string below:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: const InputDecoration(
                  hintText: '{"version":1, "tasks":[...]}',
                  border: OutlineInputBorder(),
                ),
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
                final input = controller.text.trim();
                if (input.isNotEmpty) {
                  try {
                    final Map<String, dynamic> data = jsonDecode(input);
                    final List<dynamic> taskList = data['tasks'] ?? [];
                    final List<dynamic> catList = data['categories'] ?? [];

                    final importedTasks = taskList
                        .map((t) => TodoItem.fromJson(t as Map<String, dynamic>))
                        .toList();
                    final importedCats = catList.isNotEmpty
                        ? catList
                            .map((c) => TaskCategory.fromJson(c as Map<String, dynamic>))
                            .toList()
                        : TaskCategory.defaultCategories;

                    provider.importJsonData(importedTasks, importedCats);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data imported successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid JSON format: $e')),
                    );
                  }
                }
              },
              child: const Text('Import Data'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Section Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.palette_rounded, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        'Appearance & Theme Mode',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ignore: deprecated_member_use
                  ListTile(
                    title: const Text('System Default'),
                    leading: const Icon(Icons.brightness_auto_rounded),
                    // ignore: deprecated_member_use
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.system,
                      // ignore: deprecated_member_use
                      groupValue: provider.themeMode,
                      // ignore: deprecated_member_use
                      onChanged: (val) {
                        if (val != null) provider.setThemeMode(val);
                      },
                    ),
                  ),
                  // ignore: deprecated_member_use
                  ListTile(
                    title: const Text('Light Theme'),
                    leading: const Icon(Icons.light_mode_rounded, color: Colors.amber),
                    // ignore: deprecated_member_use
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.light,
                      // ignore: deprecated_member_use
                      groupValue: provider.themeMode,
                      // ignore: deprecated_member_use
                      onChanged: (val) {
                        if (val != null) provider.setThemeMode(val);
                      },
                    ),
                  ),
                  // ignore: deprecated_member_use
                  ListTile(
                    title: const Text('Dark Theme'),
                    leading: const Icon(Icons.dark_mode_rounded, color: Colors.indigoAccent),
                    // ignore: deprecated_member_use
                    trailing: Radio<ThemeMode>(
                      value: ThemeMode.dark,
                      // ignore: deprecated_member_use
                      groupValue: provider.themeMode,
                      // ignore: deprecated_member_use
                      onChanged: (val) {
                        if (val != null) provider.setThemeMode(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Data Management Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storage_rounded, color: Colors.teal),
                      SizedBox(width: 8),
                      Text(
                        'Data & Backup Management',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.download_rounded, color: Colors.blue),
                    title: const Text('Export Backup (JSON)'),
                    subtitle: const Text('Copy all tasks & categories data'),
                    onTap: () => _showExportDialog(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.upload_rounded, color: Colors.orange),
                    title: const Text('Import Backup (JSON)'),
                    subtitle: const Text('Restore tasks from exported JSON string'),
                    onTap: () => _showImportDialog(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.refresh_rounded, color: Colors.purple),
                    title: const Text('Reset Sample Data'),
                    subtitle: const Text('Restore sample tasks for testing features'),
                    onTap: () {
                      provider.resetToSampleData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reset to sample data!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About App Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        'TaskMaster Pro',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Version 1.0.0 • Built with Flutter & Material 3',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Full-featured task manager with priority levels, custom categories, subtasks, due dates, analytics, dark mode, and local persistence.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
