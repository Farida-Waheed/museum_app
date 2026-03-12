import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'models/user_preferences.dart';
import 'models/exhibit_provider.dart';
import 'models/tour_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);

  final userPrefs = UserPreferencesModel();
  await userPrefs.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userPrefs),
        ChangeNotifierProvider(create: (_) => ExhibitProvider()),
        ChangeNotifierProvider(create: (_) => TourProvider()),
      ],
      child: const MuseumApp(),
    ),
  );
}
