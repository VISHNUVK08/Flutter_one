import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'providers/task_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  final taskProvider = TaskProvider(storageService);

  runApp(VKTaskManagerApp(provider: taskProvider));
}

class VKTaskManagerApp extends StatelessWidget {
  final TaskProvider provider;

  const VKTaskManagerApp({super.key, required this.provider});

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
          title: 'VK Task Manager',
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
