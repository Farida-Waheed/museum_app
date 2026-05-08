import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exhibit.dart';
import '../../models/tour_provider.dart';
import '../../models/app_session_provider.dart' as session;
import '../../core/services/mock_data.dart';
import '../quiz/quiz_screen.dart';
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

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  late List<Exhibit> exhibits;

  FollowModeState _lastFollowMode = FollowModeState.off;

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

  void _showExhibitPopup(Exhibit exhibit, bool isVisited) {
    showDialog(
      context: context,
      builder: (context) =>
          _ExhibitInfoPopup(exhibit: exhibit, isVisited: isVisited),
    );
  }

  void _centerOn(double x, double y) {
    _transformController.value = Matrix4.identity()
      ..translateByDouble(-x + 150, -y + 200, 0, 1);
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
    final sessionProvider = Provider.of<session.AppSessionProvider>(context);

    final currentExhibitId =
        tourProvider.currentExhibitId ?? sessionProvider.currentExhibitId;
    final nextExhibitId =
        tourProvider.nextExhibitId ?? sessionProvider.nextExhibitId;
    final currentExhibit = exhibits.firstWhere(
      (e) => e.id == currentExhibitId,
      orElse: () => exhibits.first,
    );
    Exhibit? nextExhibit;
    if (nextExhibitId != null) {
      for (final exhibit in exhibits) {
        if (exhibit.id == nextExhibitId) {
          nextExhibit = exhibit;
          break;
        }
      }
    }
    final robotX = (currentExhibit.x / 400) * mapWidth;
    final robotY = (currentExhibit.y / 600) * mapHeight;
    final showRobot = sessionProvider.shouldShowRobotOnMap;
    final showPath = sessionProvider.shouldShowRobotPath;

    if (tourProvider.followMode == FollowModeState.on &&
        _lastFollowMode != FollowModeState.on) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _transformController.value = Matrix4.identity()
          ..translateByDouble(-robotX + 150, -robotY + 200, 0, 1);
      });
    }
    _lastFollowMode = tourProvider.followMode;

    return AppMenuShell(
      title: (isArabic ? "خريطة المتحف" : "Museum Map").toUpperCase(),
      subHeader: sessionProvider.shouldShowRobotOnMap
          ? const RobotStatusBanner()
          : null,
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      showChatButton: true,
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
                    Text(
                      isArabic
                          ? "المتحف المصري الكبير"
                          : "Grand Egyptian Museum",
                      style: AppTextStyles.titleMedium(
                        context,
                      ).copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? "الجناح الشرقي • مقتنيات ذهبية"
                          : "East Wing • Golden Artifacts",
                      style: AppTextStyles.metadata(context),
                    ),
                  ],
                ),
                _FilterChip(label: isArabic ? "مقتنيات" : "Exhibits"),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _MapStatusPanel(
              sessionProvider: sessionProvider,
              tourProvider: tourProvider,
              currentExhibit: currentExhibit,
              nextExhibit: nextExhibit,
              isArabic: isArabic,
              onRecover: showRobot
                  ? () {
                      tourProvider.requestRecovery(context);
                      _centerOn(robotX, robotY);
                    }
                  : null,
            ),
          ),

          // Follow Mode Card - only show if shouldShowFollowControls
          if (sessionProvider.shouldShowFollowControls)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: AppColors.darkSurfaceSecondary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tourProvider.followMode == FollowModeState.on
                                  ? (isArabic
                                        ? 'التتبع قيد التشغيل'
                                        : 'Follow mode is on')
                                  : (isArabic
                                        ? 'التتبع متوقف'
                                        : 'Follow mode is off'),
                              style: AppTextStyles.bodyPrimary(
                                context,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tourProvider.getProximityText(l10n.localeName),
                              style: AppTextStyles.metadata(
                                context,
                              ).copyWith(color: AppColors.neutralMedium),
                            ),
                          ],
                        ),
                      ),
                      _MapActionBtn(
                        icon: Icons.my_location_rounded,
                        onPressed: () {
                          tourProvider.requestRecovery(context);
                        },
                      ),
                    ],
                  ),
                ),
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
                          border: Border.all(
                            color: AppColors.darkDivider,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .25),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
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

                              // ROUTE TO NEXT STOP - only show if shouldShowRobotPath
                              if (showPath)
                                CustomPaint(
                                  size: Size(mapWidth, mapHeight),
                                  painter: RoutePainter(
                                    visitorPos: Offset(
                                      mapWidth * 0.5,
                                      mapHeight * 0.7,
                                    ),
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
                                    style: AppTextStyles.metadata(context)
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neutralMedium,
                                        ),
                                  ),
                                ),
                              ),

                              // EXHIBITS
                              ...exhibits.map(
                                (e) => _buildExhibitMarker(
                                  e,
                                  tourProvider.hasVisited(e.id),
                                  e.id == currentExhibitId,
                                  e.id == nextExhibitId,
                                  isArabic,
                                ),
                              ),

                              // VISITOR
                              _buildVisitorMarker(
                                mapWidth * 0.5,
                                mapHeight * 0.7,
                              ),

                              // ROBOT - only show if shouldShowRobotOnMap
                              if (showRobot)
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
                      // Robot center button - only show if robot is visible
                      if (showRobot)
                        Column(
                          children: [
                            _MapActionBtn(
                              icon: Icons.smart_toy_rounded,
                              onPressed: () {
                                final tourProvider = Provider.of<TourProvider>(
                                  context,
                                  listen: false,
                                );
                                final currentExhibit = exhibits.firstWhere(
                                  (e) => e.id == tourProvider.currentExhibitId,
                                  orElse: () => exhibits.first,
                                );
                                final robotX =
                                    (currentExhibit.x / 400) * mapWidth;
                                final robotY =
                                    (currentExhibit.y / 600) * mapHeight;
                                _centerOn(robotX, robotY);
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      _MapActionBtn(
                        icon: Icons.my_location_rounded,
                        onPressed: () {
                          _centerOn(mapWidth * 0.5, mapHeight * 0.7);
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
                      color: AppColors.cinematicCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.darkBorder,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Robot legend - only show if robot is visible
                        if (showRobot) ...[
                          _buildLegendItem(
                            AppColors.primaryGold,
                            l10n.horusBot,
                          ),
                          const SizedBox(height: 8),
                        ],
                        _buildLegendItem(
                          AppColors.primaryGold,
                          isArabic ? 'Ø§Ù„Ø­Ø§Ù„ÙŠ' : 'Current',
                          icon: Icons.place_rounded,
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(
                          AppColors.darkGold,
                          isArabic ? 'Ø§Ù„ØªØ§Ù„ÙŠ' : 'Next',
                          icon: Icons.flag_rounded,
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem(Colors.blue, l10n.you),
                        const SizedBox(height: 8),
                        _buildLegendItem(Colors.green, l10n.visited),
                        const SizedBox(height: 8),
                        _buildLegendItem(AppColors.neutralMedium, l10n.exhibit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MARKERS ------------------------------------------------------

  Widget _buildExhibitMarker(
    Exhibit e,
    bool isVisited,
    bool isCurrent,
    bool isNext,
    bool isArabic,
  ) {
    final double x = (e.x / 400) * mapWidth;
    final double y = (e.y / 600) * mapHeight;
    final markerColor = isCurrent
        ? AppColors.primaryGold
        : isNext
        ? AppColors.darkGold
        : isVisited
        ? Colors.green
        : AppColors.darkBackground;
    final borderColor = isVisited && !isCurrent && !isNext
        ? Colors.green
        : AppColors.primaryGold;
    final icon = isCurrent
        ? Icons.place_rounded
        : isNext
        ? Icons.flag_rounded
        : isVisited
        ? Icons.check_rounded
        : Icons.museum_outlined;
    final iconColor = isCurrent || isNext
        ? AppColors.darkInk
        : isVisited
        ? Colors.white
        : AppColors.primaryGold;

    return Positioned(
      left: x - 24,
      top: y - 28,
      child: Tooltip(
        message: e.getName(isArabic ? 'ar' : 'en'),
        child: GestureDetector(
          onTap: () => _showExhibitPopup(e, isVisited),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrent || isNext)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkInk.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    isCurrent
                        ? (isArabic ? 'Ø§Ù„Ø¢Ù†' : 'Now')
                        : (isArabic ? 'Ø§Ù„ØªØ§Ù„ÙŠ' : 'Next'),
                    style: AppTextStyles.metadata(context).copyWith(
                      color: AppColors.primaryGold,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              Container(
                width: isCurrent || isNext ? 32 : 24,
                height: isCurrent || isNext ? 32 : 24,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    if (!isVisited || isCurrent || isNext)
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(
                          alpha: isCurrent ? 0.55 : 0.35,
                        ),
                        blurRadius: isCurrent ? 18 : 12,
                        spreadRadius: isCurrent ? 2 : 1,
                      ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: isCurrent || isNext ? 17 : 14,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitorMarker(double x, double y) {
    return Positioned(
      left: x - 18,
      top: y - 18,
      child: Tooltip(
        message: 'You',
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_pin_circle_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
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
                  color: AppColors.primaryGold.withValues(
                    alpha: (0.3 - (_pulseAnimation.value - 1.0)).clamp(0, 1),
                  ),
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
                      color: AppColors.primaryGold.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: AppColors.primaryGold,
                    size: 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {IconData? icon}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: icon == null
              ? null
              : Icon(icon, color: AppColors.darkInk, size: 10),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.metadata(context).copyWith(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
        color: AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.metadata(context).copyWith(
          color: AppColors.primaryGold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MapStatusPanel extends StatelessWidget {
  final session.AppSessionProvider sessionProvider;
  final TourProvider tourProvider;
  final Exhibit currentExhibit;
  final Exhibit? nextExhibit;
  final bool isArabic;
  final VoidCallback? onRecover;

  const _MapStatusPanel({
    required this.sessionProvider,
    required this.tourProvider,
    required this.currentExhibit,
    required this.nextExhibit,
    required this.isArabic,
    required this.onRecover,
  });

  @override
  Widget build(BuildContext context) {
    final status = _statusCopy();
    final lang = isArabic ? 'ar' : 'en';
    final canRecover =
        onRecover != null &&
        (sessionProvider.tourLifecycleState ==
                session.TourLifecycleState.paused ||
            tourProvider.proximityState == ProximityState.far);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.secondaryGlassCard(radius: 18, opacity: 0.72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: status.color.withValues(alpha: 0.45),
                  ),
                ),
                child: Icon(status.icon, color: status.color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.title,
                      style: AppTextStyles.bodyPrimary(
                        context,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      status.subtitle,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.neutralMedium, height: 1.25),
                    ),
                  ],
                ),
              ),
              if (canRecover)
                _MapActionBtn(
                  icon: Icons.center_focus_strong_rounded,
                  onPressed: onRecover!,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                icon: Icons.place_rounded,
                label: isArabic ? 'Ø§Ù„Ø­Ø§Ù„ÙŠ' : 'Current',
                value: currentExhibit.getName(lang),
              ),
              if (nextExhibit != null)
                _StatusPill(
                  icon: Icons.flag_rounded,
                  label: isArabic ? 'Ø§Ù„ØªØ§Ù„ÙŠ' : 'Next',
                  value: nextExhibit!.getName(lang),
                ),
              _StatusPill(
                icon: Icons.check_circle_outline_rounded,
                label: isArabic ? 'ØªÙ…Øª Ø²ÙŠØ§Ø±ØªÙ‡Ø§' : 'Visited',
                value: '${tourProvider.visitedExhibitIds.length}',
              ),
              _StatusPill(
                icon: tourProvider.followMode == FollowModeState.on
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                label: isArabic ? 'Ø§Ù„ØªØªØ¨Ø¹' : 'Follow',
                value: tourProvider.followMode == FollowModeState.on
                    ? (isArabic ? 'Ù…ÙØ¹Ù„' : 'On')
                    : (isArabic ? 'Ù…ØªÙˆÙ‚Ù' : 'Off'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _MapStatusCopy _statusCopy() {
    switch (sessionProvider.robotConnectionState) {
      case session.RobotConnectionState.connecting:
        return _MapStatusCopy(
          icon: Icons.sync_rounded,
          color: AppColors.primaryGold,
          title: isArabic
              ? 'Ø¬Ø§Ø±ÙŠ Ø§Ù„Ø§ØªØµØ§Ù„ Ø¨Ø­ÙˆØ±ÙˆØ³-Ø¨ÙˆØª'
              : 'Connecting to Horus-Bot',
          subtitle: isArabic
              ? 'Ø³ØªØ¸Ù‡Ø± Ù…ÙˆØ§Ù‚Ø¹ Ø­ÙˆØ±ÙˆØ³ ÙˆØ§Ù„Ù…Ø³Ø§Ø± Ø¹Ù†Ø¯ Ø§ÙƒØªÙ…Ø§Ù„ Ø§Ù„Ø§ØªØµØ§Ù„.'
              : 'Robot position and route appear once the connection is ready.',
        );
      case session.RobotConnectionState.connected:
        if (sessionProvider.tourLifecycleState ==
            session.TourLifecycleState.paused) {
          return _MapStatusCopy(
            icon: Icons.pause_circle_outline_rounded,
            color: AppColors.darkGold,
            title: isArabic
                ? 'Ø§Ù„Ø¬ÙˆÙ„Ø© Ù…ØªÙˆÙ‚ÙØ© Ù…Ø¤Ù‚ØªØ§'
                : 'Tour paused',
            subtitle: isArabic
                ? 'Ø­Ø§ÙØ¸ Ø¹Ù„Ù‰ Ù…ÙˆÙ‚Ø¹Ùƒ Ø£Ùˆ Ø§Ø³ØªØ¹Ø¯ Ù…Ø±ÙƒØ² Ø­ÙˆØ±ÙˆØ³ Ø¹Ù„Ù‰ Ø§Ù„Ø®Ø±ÙŠØ·Ø©.'
                : 'Keep your place or recenter on Horus-Bot for recovery.',
          );
        }
        return _MapStatusCopy(
          icon: Icons.smart_toy_rounded,
          color: AppColors.primaryGold,
          title: isArabic
              ? 'Ø­ÙˆØ±ÙˆØ³-Ø¨ÙˆØª ÙŠÙˆØ¬Ù‡ Ø§Ù„Ø¬ÙˆÙ„Ø©'
              : 'Horus-Bot is guiding',
          subtitle: tourProvider.getProximityText(isArabic ? 'ar' : 'en'),
        );
      case session.RobotConnectionState.failed:
        return _MapStatusCopy(
          icon: Icons.error_outline_rounded,
          color: AppColors.alertRed,
          title: isArabic
              ? 'ÙŠØ­ØªØ§Ø¬ Ø§Ù„Ø§ØªØµØ§Ù„ Ø¥Ù„Ù‰ ØªØ­Ù‚Ù‚'
              : 'Connection needs attention',
          subtitle: isArabic
              ? 'ØªØ¨Ù‚Ù‰ Ø§Ù„Ø®Ø±ÙŠØ·Ø© Ù…ØªØ§Ø­Ø© Ù„Ù„Ø§Ø³ØªÙƒØ´Ø§Ù Ø¨Ø¯ÙˆÙ† ØªØªØ¨Ø¹ Ø­ÙŠ.'
              : 'The map remains available for exhibit exploration without live tracking.',
        );
      case session.RobotConnectionState.disconnected:
        return _MapStatusCopy(
          icon: Icons.explore_rounded,
          color: AppColors.neutralMedium,
          title: isArabic
              ? 'Ø§Ø³ØªÙƒØ´Ø§Ù Ø§Ù„Ù…Ø¹Ø±ÙˆØ¶Ø§Øª'
              : 'Explore the gallery',
          subtitle: isArabic
              ? 'Ø§Ù„Ø®Ø±ÙŠØ·Ø© ØªØ¹Ø±Ø¶ Ø§Ù„Ù…Ø¹Ø±ÙˆØ¶Ø§Øª Ø§Ù„Ù…Ø®Ø²Ù†Ø© Ø¨Ø¯ÙˆÙ† Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø±ÙˆØ¨ÙˆØª.'
              : 'Showing saved exhibit positions. Robot tracking is not connected.',
        );
    }
  }
}

class _MapStatusCopy {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _MapStatusCopy({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryGold),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: AppColors.neutralMedium, fontSize: 10),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 145),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.metadata(context).copyWith(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
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
    final hasQuiz = MockDataService.getAllQuestions().any(
      (question) => question.exhibitId == exhibit.id,
    );
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(23),
              ),
              child: Image.asset(
                exhibit.imageAsset,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
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
                          style: AppTextStyles.displayArtifactTitle(
                            context,
                          ).copyWith(fontSize: 18),
                        ),
                      ),
                      if (isVisited)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exhibit.getDescription(isArabic ? 'ar' : 'en'),
                    style: AppTextStyles.bodyPrimary(context),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _PopupBtn(
                          label: isArabic ? "اختبار" : "Quiz",
                          icon: Icons.quiz,
                          onTap: () {
                            final sessionProvider =
                                Provider.of<session.AppSessionProvider>(
                                  context,
                                  listen: false,
                                );
                            if (sessionProvider.canTakeQuiz && hasQuiz) {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      QuizScreen(exhibitId: exhibit.id),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic
                                        ? 'الاختبارات متاحة فقط خلال الجولة أو بعدها.'
                                        : 'Quizzes are only available during or after a tour.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
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
  const _PopupBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: AppTextStyles.buttonLabel(context).copyWith(fontSize: 12),
      ),
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

// ========== PAINTERS ==========

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
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
      ..color = AppColors.primaryGold.withValues(alpha: 0.2)
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
