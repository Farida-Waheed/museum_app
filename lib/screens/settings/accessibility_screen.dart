import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart'; // ADD NAV BAR

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // 🔥 Add global bottom navigation bar
      bottomNavigationBar: const BottomNav(currentIndex: 4),

      appBar: AppBar(
        title: const Text(
          "Settings & Accessibility",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // VISUAL SETTINGS
          _buildSectionHeader("Visual"),

          SwitchListTile(
            title: const Text("High Contrast Mode"),
            subtitle: const Text("Increases visibility for low vision users"),
            value: prefs.isHighContrast,
            onChanged: (val) => prefs.toggleHighContrast(val),
          ),

          ListTile(
            title: const Text("Font Size"),
            subtitle: Slider(
              value: prefs.fontScale,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              label: "${prefs.fontScale}x",
              onChanged: (val) => prefs.setFontScale(val),
            ),
          ),

          const SizedBox(height: 20),

          // LANGUAGE SETTINGS
          _buildSectionHeader("Language"),

          ListTile(
            title: const Text("App Language"),
            trailing: DropdownButton<String>(
              value: prefs.language,
              items: const [
                DropdownMenuItem(value: 'en', child: Text("English")),
                DropdownMenuItem(value: 'ar', child: Text("العربية")),
              ],
              onChanged: (val) {
                if (val != null) prefs.setLanguage(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
