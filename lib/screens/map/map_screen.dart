import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late List<Exhibit> exhibits;

  // Robot pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Static map dimensions
  final double mapWidth = 600;
  final double mapHeight = 500;

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
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
      backgroundColor: const Color(0xFFF2F4F7),

      // 🌍 USE GLOBAL NAV BAR (NO DUPLICATION)
      bottomNavigationBar: const BottomNav(currentIndex: 1),

      appBar: AppBar(
        title: const Text("Museum Map", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Stack(
        children: [
          // --- INTERACTIVE MAP AREA ---
          Container(
            color: const Color(0xFFF6F8FA),
            child: InteractiveViewer(
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(50),
              minScale: 0.5,
              maxScale: 2.5,
              constrained: false,

              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Container(
                  width: mapWidth,
                  height: mapHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    border: Border.all(color: Colors.blueGrey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        // GRID LINES
                        CustomPaint(
                          size: Size(mapWidth, mapHeight),
                          painter: MapGridPainter(),
                        ),

                        // ENTRANCE LABEL
                        const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "Entrance",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                        ),

                        // EXHIBITS
                        ...exhibits.map((e) => _buildExhibitMarker(e)),

                        // ROBOT
                        _buildRobotMarker(150, 200),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- LEGEND FLOATING CARD ---
          Positioned(
            left: 16,
            bottom: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.75),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(Colors.blue, "Robot Location"),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.red, "Your Location"),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.teal, "Visited Exhibit"),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.grey, "Not Visited"),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // MARKERS ------------------------------------------------------

  Widget _buildExhibitMarker(Exhibit e) {
    final double x = (e.x / 400) * mapWidth;
    final double y = (e.y / 600) * mapHeight;

    return Positioned(
      left: x - 30,
      top: y - 30,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: e),
        child: Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              e.nameEn,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
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
          // CHAT BUBBLE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 6),
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
                Text(
                  "Explaining",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // PULSING ROBOT
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 60 * _pulseAnimation.value,
                height: 60 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.4 - (_pulseAnimation.value - 1.0)),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
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

// ========== GRID PAINTER ==========

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    final dashedPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    // Regular grid
    double gridSize = 50;
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }

    // Center dashed lines
    double cx = size.width / 2;
    double cy = size.height / 2;

    for (double i = 0; i < size.height; i += 10) {
      if (i % 20 == 0) canvas.drawLine(Offset(cx, i), Offset(cx, i + 5), dashedPaint);
    }

    for (double i = 0; i < size.width; i += 10) {
      if (i % 20 == 0) canvas.drawLine(Offset(i, cy), Offset(i + 5, cy), dashedPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
