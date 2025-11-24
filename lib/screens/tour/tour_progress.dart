import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../core/services/mock_data.dart';

class TourProgressScreen extends StatelessWidget {
  const TourProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final exhibits = MockDataService.getAllExhibits();

    // Simulating that the first 2 exhibits are "Visited"
    const visitedCount = 2; 

    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? "ملخص الجولة" : "Tour Summary")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          Card(
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "${((visitedCount / exhibits.length) * 100).toInt()}%",
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    isArabic ? "اكتملت الجولة" : "Tour Completed",
                    style: const TextStyle(color: Colors.white70),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? "سجل الزيارات" : "Visit Log",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...List.generate(exhibits.length, (index) {
            final isVisited = index < visitedCount; // Mock logic
            return ListTile(
              leading: Icon(
                isVisited ? Icons.check_circle : Icons.circle_outlined,
                color: isVisited ? Colors.green : Colors.grey,
              ),
              title: Text(exhibits[index].getName(prefs.language)),
              subtitle: Text(isVisited 
                ? (isArabic ? "تمت الزيارة: 10:30 ص" : "Visited: 10:30 AM")
                : (isArabic ? "لم تتم الزيارة بعد" : "Not visited yet")
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: Text(isArabic ? "تحميل ملخص PDF" : "Download PDF Summary"),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloading Summary...")));
            },
          )
        ],
      ),
    );
  }
}