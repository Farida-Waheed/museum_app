import 'package:flutter/material.dart';
import '../../core/services/mock_data.dart';
import '../../models/exhibit.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Exhibit> exhibits = MockDataService.getAllExhibits();

    return Scaffold(
      appBar: AppBar(title: const Text("Museum Map")),
      body: Stack(
        children: [
          // Background (Simulated Map)
          Container(color: Colors.grey[200]),
          
          // Grid Lines (for effect)
          ...List.generate(10, (i) => Positioned(
              top: i * 60.0, left: 0, right: 0, 
              child: const Divider(color: Colors.black12))),
              
          // Render Exhibits on Map
          ...exhibits.map((e) => Positioned(
            left: e.x,
            top: e.y,
            child: Column(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 40),
                Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.white,
                  child: Text(e.nameEn, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )),
          
          // Simulated Robot Position
          const Positioned(
            left: 100,
            top: 100,
            child: Icon(Icons.smart_toy, size: 40, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}