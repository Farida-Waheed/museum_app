import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:museum_app/app/app.dart'; 
import 'package:museum_app/models/user_preferences.dart';
import 'package:museum_app/models/exhibit_provider.dart';
import 'package:museum_app/models/tour_provider.dart';

void main() {
  testWidgets('Museum App loads', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserPreferencesModel()),
            ChangeNotifierProvider(create: (_) => ExhibitProvider()),
            ChangeNotifierProvider(create: (_) => TourProvider()),
          ],
          child: const MuseumApp(),
        ),
      );

      // Should start at IntroScreen
      expect(find.text('Museums'), findsWidgets);
    });
  });
}
