import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late List<Exhibit> exhibits;
  
  // Robot Animation State
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Map Dimensions
  final double mapWidth = 600;
  final double mapHeight = 500;

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();
    
    // Setup Pulsing Animation for Robot
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Museum Map", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. The Interactive Map Area
          Container(
            color: const Color(0xFFF5F7FA), // Light blue-grey background
            child: InteractiveViewer(
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(50),
              minScale: 0.5,
              maxScale: 2.5,
              constrained: false, // Allows map to be larger than screen
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Container(
                  width: mapWidth,
                  height: mapHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blueGrey.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)
                    ],
                  ),
                  child: Stack(
                    children: [
                      // A. Grid Lines
                      CustomPaint(
                        size: Size(mapWidth, mapHeight),
                        painter: MapGridPainter(),
                      ),

                      // B. Entrance Label
                      const Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Entrance", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                              SizedBox(height: 2, width: 40, child: ColoredBox(color: Colors.teal)),
                            ],
                          ),
                        ),
                      ),

                      // C. Exhibits (Green Circles)
                      ...exhibits.map((e) => _buildExhibitMarker(e)),

                      // D. The Robot (Animated)
                      _buildRobotMarker(150, 200), // Mock position (matches "Egyptian" area roughly)
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. The Legend Card (Floating Bottom Left)
          Positioned(
            left: 16,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.blue, "Robot Location"),
                  const SizedBox(height: 8),
                  _buildLegendItem(Colors.red, "Your Location"),
                  const SizedBox(height: 8),
                  _buildLegendItem(Colors.teal, "Visited"),
                  const SizedBox(height: 8),
                  _buildLegendItem(Colors.grey, "Not Visited"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- Marker Widgets ---

  Widget _buildExhibitMarker(Exhibit e) {
    // Scale coordinates to fit our fixed map size
    final double x = (e.x / 400) * mapWidth;
    final double y = (e.y / 600) * mapHeight;

    return Positioned(
      left: x - 30, // Center horizontally
      top: y - 30,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: e),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.teal, // Green for "Visited" style
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              e.nameEn,
              style: TextStyle(fontSize: 10, color: Colors.grey[800], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRobotMarker(double x, double y) {
    return Positioned(
      left: x - 40,
      top: y - 60,
      child: Column(
        children: [
          // "Explaining" Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🤖", style: TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text("Explaining", style: TextStyle(fontSize: 10, color: Colors.blue[800], fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Pulsing Circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 60 * _pulseAnimation.value,
                height: 60 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.withOpacity(0.5 - (_pulseAnimation.value - 1.0)), width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 8)],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}

// --- Custom Painter for the Grid Lines ---

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    final dashedPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 1. Draw Light Grid
    double gridSize = 50;
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // 2. Draw Center Dashed Axes (Quadrants)
    Path path = Path();
    // Vertical Center
    double cx = size.width / 2;
    for (double i = 0; i < size.height; i += 10) {
      if (i % 20 == 0) canvas.drawLine(Offset(cx, i), Offset(cx, i + 5), dashedPaint);
    }
    // Horizontal Center
    double cy = size.height / 2;
    for (double i = 0; i < size.width; i += 10) {
      if (i % 20 == 0) canvas.drawLine(Offset(i, cy), Offset(i + 5, cy), dashedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}