import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:museum_app/app/app.dart'; 
import 'package:museum_app/models/user_preferences.dart';

void main() {
  testWidgets('Museum App basic flow works', (WidgetTester tester) async {
    // 1. Build the app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserPreferencesModel()),
        ],
        child: const MuseumApp(),
      ),
    );

    // 2. Verify the Intro Screen appears
    expect(find.text('Museums'), findsOneWidget);
    
    // 3. Advance past Intro (2s timer)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 4. Verify Onboarding Screen (New refined text)
    expect(find.text('Explore Museums'), findsOneWidget);

    // 5. Test Language Switch
    await tester.tap(find.text('English')); // Tap current language to open popup
    await tester.pumpAndSettle();

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('استكشف المتاحف'), findsOneWidget);

    // 6. Complete onboarding
    await tester.tap(find.text('ابدأ الاستكشاف'));
    await tester.pumpAndSettle();

    // 7. Verify Home Screen loaded (at least one Horus title)
    expect(find.text('حوروس'), findsWidgets);
  });
}
