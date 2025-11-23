import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings & Accessibility")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Visual"),
          SwitchListTile(
            title: const Text("High Contrast Mode"),
            subtitle: const Text("Increases visibility for low vision"),
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }
}