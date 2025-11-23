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
  
  // Robot Simulation State
  int currentTargetIndex = 0;
  late AnimationController _robotAnimController;
  late Animation<Offset> _robotAnimation;

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();
    
    // Setup Robot Animation (Patrols between exhibits)
    _robotAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    // Create a tween that moves through the exhibits mock positions
    // Note: In a real app, this would update based on live MQTT data
    _robotAnimation = TweenSequence<Offset>([
      TweenSequenceItem(tween: Tween(begin: const Offset(100, 100), end: const Offset(50, 100)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(50, 100), end: const Offset(50, 300)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(50, 300), end: const Offset(200, 300)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: const Offset(200, 300), end: const Offset(200, 150)), weight: 1),
    ]).animate(_robotAnimController);
  }

  @override
  void dispose() {
    _robotAnimController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () {
              // Reset Zoom
              _transformController.value = Matrix4.identity();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Instructions Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.blue[50],
            child: const Text(
              "Pinch to zoom • Tap icons for details",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
          
          // The Map Area
          Expanded(
            child: Container(
              color: Colors.grey[200], // Map Background
              child: InteractiveViewer(
                transformationController: _transformController,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.5,
                maxScale: 3.0,
                child: Stack(
                  children: [
                    // 1. The Map Image/Grid (Size: 500x600)
                    Container(
                      width: 500,
                      height: 600,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: CustomPaint(
                        painter: GridPainter(), // Draws grid lines
                      ),
                    ),

                    // 2. The Path (Lines connecting exhibits)
                    CustomPaint(
                      size: const Size(500, 600),
                      painter: PathPainter(exhibits),
                    ),

                    // 3. The Exhibits (Clickable Icons)
                    ...exhibits.map((e) => Positioned(
                      left: e.x - 20, // Center the icon (40px width / 2)
                      top: e.y - 40, // Pin bottom of icon to location
                      child: GestureDetector(
                        onTap: () => _showExhibitPreview(context, e),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black26)]
                              ),
                              child: Text(e.nameEn, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ],
                        ),
                      ),
                    )),

                    // 4. The Animated Robot
                    AnimatedBuilder(
                      animation: _robotAnimation,
                      builder: (context, child) {
                        return Positioned(
                          left: _robotAnimation.value.dx - 15,
                          top: _robotAnimation.value.dy - 15,
                          child: child!,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)]
                        ),
                        child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Floating Action Button to Recenter on Robot
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Locating Robot...")));
        },
        icon: const Icon(Icons.my_location),
        label: const Text("Find Robot"),
      ),
    );
  }

  void _showExhibitPreview(BuildContext context, Exhibit e) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 200,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.nameEn, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(e.descriptionEn, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close sheet
                      Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: e);
                    },
                    child: const Text("View Details"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- Custom Painters for Map Graphics ---

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey[200]!..strokeWidth = 1;
    // Draw vertical lines
    for (double i = 0; i <= size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PathPainter extends CustomPainter {
  final List<Exhibit> exhibits;
  PathPainter(this.exhibits);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (exhibits.isEmpty) return;

    path.moveTo(exhibits[0].x, exhibits[0].y);
    for (int i = 1; i < exhibits.length; i++) {
      path.lineTo(exhibits[i].x, exhibits[i].y);
    }

    // Draw dashed line effect (Simplified)
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}