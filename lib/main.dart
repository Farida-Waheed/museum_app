import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // for date formatting

import 'app/app.dart';
import 'models/user_preferences.dart';

Future<void> main() async {
  // Needed when doing async work before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize intl date formatting for the locales you use
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserPreferencesModel()),
      ],
      child: const MuseumApp(),
    ),
  );
}
