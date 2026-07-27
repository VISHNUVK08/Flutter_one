import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'providers/task_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  final taskProvider = TaskProvider(storageService);

  runApp(TaskMasterApp(provider: taskProvider));
}

class TaskMasterApp extends StatelessWidget {
  final TaskProvider provider;

  const TaskMasterApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, child) {
        if (provider.isLoading) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'TaskMaster Pro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.themeMode,
          home: HomeScreen(provider: provider),
        );
      },
    );
  }
}
