import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'models/user_preferences.dart';

void main() {
  runApp(
    // Initialize Provider for State Management
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserPreferencesModel()),
      ],
      child: const MuseumApp(),
    ),
  );
}