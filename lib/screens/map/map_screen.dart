import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exhibit.dart';
import '../../models/tour_provider.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/robot_status_banner.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

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

    Future.delayed(Duration.zero, () {
      _checkLocationPermission();
    });

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

  void _showExhibitPopup(Exhibit exhibit, bool isVisited) {
    showDialog(
      context: context,
      builder: (context) => _ExhibitInfoPopup(exhibit: exhibit, isVisited: isVisited),
    );
  }

  Future<void> _checkLocationPermission() async {
    if (kIsWeb) return;
    final status = await Permission.locationWhenInUse.status;
    if (!status.isGranted && mounted) {
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BrandedPermissionDialog(
          icon: Icons.location_on_outlined,
          title: l10n.locationPermissionTitle,
          description: l10n.locationPermissionDesc,
          onAllow: () async {
            Navigator.pop(context);
            await Permission.locationWhenInUse.request();
          },
          onDeny: () => Navigator.pop(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final tourProvider = Provider.of<TourProvider>(context);

    final currentExhibit = exhibits.firstWhere((e) => e.id == tourProvider.currentExhibitId, orElse: () => exhibits.first);
    final robotX = (currentExhibit.x / 400) * mapWidth;
    final robotY = (currentExhibit.y / 600) * mapHeight;

    return AppMenuShell(
      title: (isArabic ? "خريطة المتحف" : "Museum Map").toUpperCase(),
      subHeader: const RobotStatusBanner(),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: AppColors.darkBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isArabic ? "المتحف المصري الكبير" : "Grand Egyptian Museum", style: AppTextStyles.titleMedium(context).copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(isArabic ? "الجناح الشرقي • مقتنيات ذهبية" : "East Wing • Golden Artifacts", style: AppTextStyles.metadata(context)),
                  ],
                ),
                _FilterChip(label: isArabic ? "مقتنيات" : "Exhibits"),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                // --- INTERACTIVE MAP AREA ---
                Container(
                  color: AppColors.darkBackground,
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    boundaryMargin: const EdgeInsets.all(100),
                    minScale: 0.5,
                    maxScale: 2.5,
                    constrained: false,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Container(
                        width: mapWidth,
                        height: mapHeight,
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          border: Border.all(color: AppColors.darkDivider, width: 2),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.25),
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
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    isArabic ? "المدخل" : "Entrance",
                                    style: AppTextStyles.metadata(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.neutralMedium,
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

                // --- MAP ACTIONS (Recenter) ---
                Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      _MapActionBtn(
                        icon: Icons.smart_toy_rounded,
                        onPressed: () {
                          final tourProvider = Provider.of<TourProvider>(context, listen: false);
                          final currentExhibit = exhibits.firstWhere((e) => e.id == tourProvider.currentExhibitId, orElse: () => exhibits.first);
                          final robotX = (currentExhibit.x / 400) * mapWidth;
                          final robotY = (currentExhibit.y / 600) * mapHeight;
                          _transformController.value = Matrix4.identity()..translate(-robotX + 150, -robotY + 200);
                        },
                      ),
                      const SizedBox(height: 12),
                      _MapActionBtn(
                        icon: Icons.my_location_rounded,
                        onPressed: () {
                          _transformController.value = Matrix4.identity()..translate(-mapWidth * 0.5 + 150, -mapHeight * 0.7 + 200);
                        },
                      ),
                    ],
                  ),
                ),

                // --- LEGEND FLOATING CARD ---
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkDivider),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(AppColors.primaryGold, l10n.horusBot),
                        const SizedBox(height: 8),
                        _buildLegendItem(Colors.blue, l10n.you),
                        const SizedBox(height: 8),
                        _buildLegendItem(Colors.green, l10n.visited),
                        const SizedBox(height: 8),
                        _buildLegendItem(AppColors.neutralMedium, l10n.exhibit),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MARKERS ------------------------------------------------------

  Widget _buildExhibitMarker(Exhibit e, bool isVisited) {
    final double x = (e.x / 400) * mapWidth;
    final double y = (e.y / 600) * mapHeight;

    return Positioned(
      left: x - 20,
      top: y - 20,
      child: GestureDetector(
        onTap: () => _showExhibitPopup(e, isVisited),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isVisited ? Colors.green : AppColors.darkBackground,
            shape: BoxShape.circle,
            border: Border.all(color: isVisited ? Colors.green : AppColors.primaryGold, width: 2),
            boxShadow: [
              if (!isVisited)
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Icon(
            Icons.museum_outlined,
            size: 14,
            color: isVisited ? Colors.white : AppColors.primaryGold,
          ),
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
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10, spreadRadius: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildRobotMarker(double x, double y, AppLocalizations l10n) {
    return Positioned(
      left: x - 30,
      top: y - 30,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow / Pulse
              Container(
                width: 40 * _pulseAnimation.value,
                height: 40 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGold.withOpacity((0.3 - (_pulseAnimation.value - 1.0)).clamp(0, 1)),
                ),
              ),
              // Robot Base
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.darkInk,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.smart_toy_rounded, color: AppColors.primaryGold, size: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.metadata(context).copyWith(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MapActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _MapActionBtn({required this.icon, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryGold, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
      ),
      child: Text(label, style: AppTextStyles.metadata(context).copyWith(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _ExhibitInfoPopup extends StatelessWidget {
  final Exhibit exhibit;
  final bool isVisited;
  const _ExhibitInfoPopup({required this.exhibit, required this.isVisited});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
              child: Image.asset(exhibit.imageAsset, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exhibit.getName(isArabic ? 'ar' : 'en'),
                          style: AppTextStyles.displayArtifactTitle(context).copyWith(fontSize: 18),
                        ),
                      ),
                      if (isVisited) const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(exhibit.getDescription(isArabic ? 'ar' : 'en'), style: AppTextStyles.bodyPrimary(context), maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _PopupBtn(label: isArabic ? "شرح" : "Explain", icon: Icons.volume_up, onTap: () {})),
                      const SizedBox(width: 12),
                      Expanded(child: _PopupBtn(label: isArabic ? "اختبار" : "Quiz", icon: Icons.quiz, onTap: () {})),
                      const SizedBox(width: 12),
                      _PopupIconBtn(icon: Icons.bookmark_border, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PopupBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: AppTextStyles.buttonLabel(context).copyWith(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.darkInk,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}

class _PopupIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PopupIconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.darkBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkDivider)),
      child: IconButton(icon: Icon(icon, color: AppColors.primaryGold, size: 20), onPressed: onTap),
    );
  }
}

// ========== PAINTERS ==========

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    double gridSize = 50;
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
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
      ..color = AppColors.primaryGold.withOpacity(0.2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(visitorPos.dx, visitorPos.dy);
    path.lineTo(robotPos.dx, visitorPos.dy);
    path.lineTo(robotPos.dx, robotPos.dy);

    canvas.drawPath(path, paint);

    final dashPaint = Paint()
      ..color = AppColors.primaryGold
      ..strokeWidth = 2;

    for (double i = 0; i < 1.0; i += 0.1) {
       double dx = visitorPos.dx + (robotPos.dx - visitorPos.dx) * i;
       double dy = visitorPos.dy + (robotPos.dy - visitorPos.dy) * i;
       canvas.drawCircle(Offset(dx, dy), 1.5, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
