import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exhibit.dart';
import '../../models/tour_provider.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final tourProvider = Provider.of<TourProvider>(context);

    final currentExhibit = exhibits.firstWhere((e) => e.id == tourProvider.currentExhibitId, orElse: () => exhibits.first);
    final robotX = (currentExhibit.x / 400) * mapWidth;
    final robotY = (currentExhibit.y / 600) * mapHeight;

    return AppMenuShell(
      title: l10n.map,
      bottomNavigationBar: const BottomNav(currentIndex: 1),
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

                        // ROUTE TO NEXT STOP
                        CustomPaint(
                          size: Size(mapWidth, mapHeight),
                          painter: RoutePainter(
                            visitorPos: Offset(mapWidth * 0.5, mapHeight * 0.7),
                            robotPos: Offset(robotX, robotY),
                          ),
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
                        ...exhibits.map((e) => _buildExhibitMarker(e, tourProvider.hasVisited(e.id))),

                        // VISITOR
                        _buildVisitorMarker(mapWidth * 0.5, mapHeight * 0.7),

                        // ROBOT
                        _buildRobotMarker(robotX, robotY, l10n),
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
                      _buildLegendItem(Colors.blue, l10n.horusBot),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.orange, l10n.you),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.teal, l10n.visited),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.grey, l10n.exhibit),
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

  Widget _buildExhibitMarker(Exhibit e, bool isVisited) {
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
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isVisited ? Colors.teal : Colors.grey.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              e.getName(Localizations.localeOf(context).languageCode),
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorMarker(double x, double y) {
    return Positioned(
      left: x - 10,
      top: y - 10,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10, spreadRadius: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildRobotMarker(double x, double y, AppLocalizations l10n) {
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
                  l10n.live,
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
                    color: Colors.orange.withOpacity((0.4 - (_pulseAnimation.value - 1.0)).clamp(0, 1)),
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

class RoutePainter extends CustomPainter {
  final Offset visitorPos;
  final Offset robotPos;

  RoutePainter({required this.visitorPos, required this.robotPos});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(visitorPos.dx, visitorPos.dy);

    // Simple L-shaped route for museum feel
    path.lineTo(robotPos.dx, visitorPos.dy);
    path.lineTo(robotPos.dx, robotPos.dy);

    canvas.drawPath(path, paint);

    // Draw dots along the path
    final dashPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    for (double i = 0; i < 1.0; i += 0.1) {
       // Manual interpolation for L-shape is complex, just draw a direct dashed line for now
       double dx = visitorPos.dx + (robotPos.dx - visitorPos.dx) * i;
       double dy = visitorPos.dy + (robotPos.dy - visitorPos.dy) * i;
       canvas.drawCircle(Offset(dx, dy), 2, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
