import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the settings provider
    final prefs = Provider.of<UserPreferencesModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Museum Guide")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display Current Language
              Text(
                "Current Language: ${prefs.language.toUpperCase()}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              
              // High Contrast Switch
              SwitchListTile(
                title: const Text("High Contrast Mode"),
                value: prefs.isHighContrast,
                onChanged: (val) => prefs.toggleHighContrast(val),
              ),
              
              const SizedBox(height: 20),
              
              // Language Switch Button
              ElevatedButton.icon(
                icon: const Icon(Icons.language),
                label: const Text("Switch Language (AR/EN)"),
                onPressed: () {
                  prefs.setLanguage(prefs.language == 'en' ? 'ar' : 'en');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}