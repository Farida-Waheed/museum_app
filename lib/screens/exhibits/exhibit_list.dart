import 'package:flutter/material.dart';
import '../../core/services/mock_data.dart';

class ExhibitListScreen extends StatelessWidget {
  const ExhibitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exhibits = MockDataService.getAllExhibits();

    return Scaffold(
      appBar: AppBar(title: const Text("Exhibits")),
      body: ListView.builder(
        itemCount: exhibits.length,
        itemBuilder: (context, index) {
          final exhibit = exhibits[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text(exhibit.id)),
              title: Text(exhibit.nameEn),
              subtitle: Text(exhibit.descriptionEn, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to detail (We will implement detail screen later)
              },
            ),
          );
        },
      ),
    );
  }
}