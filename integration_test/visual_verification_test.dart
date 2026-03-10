import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:museum_app/main.dart' as app;
import 'package:museum_app/app/router.dart';
import 'package:museum_app/screens/home/home_screen.dart';
import 'package:museum_app/screens/onboarding/onboarding_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Verify Onboarding and Home Screen', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Initial Onboarding
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await tester.takeScreenshot('onboarding_1');

    // 2. Swipe through onboarding
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.takeScreenshot('onboarding_swiped');

    // 3. Start Exploring (Available on every slide now)
    final startExploringBtn = find.text('Start Exploring');
    expect(startExploringBtn, findsAtLeast(1));
    await tester.tap(startExploringBtn.first);
    await tester.pumpAndSettle();

    // 4. Verify Home Screen
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.takeScreenshot('home_initial');

    // 5. Scroll and check App Bar
    final scrollable = find.byType(CustomScrollView);
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.takeScreenshot('home_scrolled_new');

    // 6. Check FAB
    expect(find.text('Talk to Horus-Bot'), findsOneWidget);
  });
}
