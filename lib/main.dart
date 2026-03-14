import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'models/user_preferences.dart';
import 'models/exhibit_provider.dart';
import 'models/tour_provider.dart';
import 'models/chat_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ar', null);
  } catch (e) {
    debugPrint("DateFormatting init failed: $e");
  }

  final userPrefs = await UserPreferencesModel.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userPrefs),
        ChangeNotifierProvider(create: (_) => ExhibitProvider()),
        ChangeNotifierProvider(create: (_) => TourProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MuseumApp(),
    ),
  );
}
