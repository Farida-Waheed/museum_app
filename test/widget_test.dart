import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Make sure these match your project name
import 'package:museum_app/app/app.dart'; 
import 'package:museum_app/models/user_preferences.dart';

void main() {
  testWidgets('Museum App loads and settings work', (WidgetTester tester) async {
    // 1. Build the app
    // We must wrap MuseumApp in a Provider to mock the data
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserPreferencesModel()),
        ],
        child: const MuseumApp(),
      ),
    );

    // 2. Verify the Home Screen appears
    // We look for the title defined in your HomeScreen
    expect(find.text('Museum Guide'), findsOneWidget);
    
    // Verify the Settings placeholder controls exist
    expect(find.text('High Contrast Mode'), findsOneWidget);
    expect(find.text('Switch Language (AR/EN)'), findsOneWidget);

    // 3. Test Interaction: Tap the "Switch Language" button
    await tester.tap(find.text('Switch Language (AR/EN)'));
    
    // Trigger a frame update (rebuild the UI)
    await tester.pump();

    // 4. Verify the language changed
    // The initial text was "Current Language: EN", now it should be "AR"
    expect(find.text('Current Language: AR'), findsOneWidget);
  });
}