import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/main.dart';
import 'package:my_first_app/services/storage_service.dart';
import 'package:my_first_app/providers/task_provider.dart';

void main() {
  testWidgets('VKTaskManagerApp builds and shows today tab correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();
    final taskProvider = TaskProvider(storageService);

    await tester.pumpWidget(VKTaskManagerApp(provider: taskProvider));
    await tester.pumpAndSettle();

    expect(find.text('My Day Focus 🎯'), findsOneWidget);
  });
}
