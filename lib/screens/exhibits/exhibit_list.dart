import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/mock_data.dart';
import '../../models/user_preferences.dart';
import '../../app/router.dart';

class ExhibitListScreen extends StatelessWidget {
  const ExhibitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get data and settings
    final exhibits = MockDataService.getAllExhibits();
    final prefs = Provider.of<UserPreferencesModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text(prefs.language == 'ar' ? "المعروضات" : "Exhibits")),
      body: ListView.builder(
        itemCount: exhibits.length,
        itemBuilder: (context, index) {
          final exhibit = exhibits[index];
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue[100],
                child: Text(exhibit.id, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(
                exhibit.getName(prefs.language), // Dynamic Language
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                exhibit.getDescription(prefs.language), // Dynamic Language
                maxLines: 1, 
                overflow: TextOverflow.ellipsis
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              
              // --- NAVIGATION LOGIC ---
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  AppRoutes.exhibitDetails,
                  arguments: exhibit, // Pass the exhibit object to the details screen
                );
              },
              // ------------------------
            ),
          );
        },
      ),
    );
  }
}