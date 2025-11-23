import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../app/router.dart'; // Import routes for navigation

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the settings provider to read language/theme
    final prefs = Provider.of<UserPreferencesModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Museum Guide")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView( // Added scroll in case screen is small
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Status Section ---
                Text(
                  "Current Language: ${prefs.language.toUpperCase()}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                
                // --- Settings Controls ---
                SwitchListTile(
                  title: const Text("High Contrast Mode"),
                  value: prefs.isHighContrast,
                  onChanged: (val) => prefs.toggleHighContrast(val),
                ),
                
                ElevatedButton.icon(
                  icon: const Icon(Icons.language),
                  label: const Text("Switch Language (AR/EN)"),
                  onPressed: () {
                    prefs.setLanguage(prefs.language == 'en' ? 'ar' : 'en');
                  },
                ),

                const Divider(height: 40),

                // --- Navigation Buttons (The part you wanted to add) ---
                
                SizedBox(
                  width: double.infinity, // Make buttons wide
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text("Open Map"),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.map);
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text("View Exhibits"),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.exhibits);
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text("Accessibility Settings"),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}