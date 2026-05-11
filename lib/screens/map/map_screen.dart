import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router.dart';
import '../../models/exhibit.dart';
import '../../models/tour_provider.dart';
import '../../models/app_session_provider.dart' as session;
import '../../core/services/mock_data.dart';
import '../tickets/qr_scanner_screen.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/ask_the_guide_button.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/auth_provider.dart';
import '../../models/ticket_provider.dart';
import '../../services/tour_session_repository.dart';

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
  Exhibit? _previewExhibit;
  bool _previewIsVisited = false;
  bool _previewIsCurrent = false;
  bool _previewIsNext = false;
  FollowModeState _lastFollowMode = FollowModeState.off;
  // Robot pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  // Static map dimensions
  final double mapWidth = 600;
  final double mapHeight = 500;
  String? _lastRestoreUid;
  bool _restoreInFlight = false;
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

  void _showExhibitPreview(
    Exhibit exhibit, {
    required bool isVisited,
    required bool isCurrent,
    required bool isNext,
  }) {
    setState(() {
      _previewExhibit = exhibit;
      _previewIsVisited = isVisited;
      _previewIsCurrent = isCurrent;
      _previewIsNext = isNext;
    });
  }

  void _closePreview() {
    if (_previewExhibit == null) return;
    setState(() {
      _previewExhibit = null;
      _previewIsVisited = false;
      _previewIsCurrent = false;
      _previewIsNext = false;
    });
  }

  void _centerOn(double x, double y) {
    _transformController.value = Matrix4.identity()
      ..translateByDouble(-x + 150, -y + 200, 0, 1);
  }

  String _mapContentSubtitle(
    session.AppSessionProvider sessionProvider,
    bool hasRobotTourEligibility,
    AppLocalizations l10n,
  ) {
    if (sessionProvider.tourLifecycleState ==
        session.TourLifecycleState.completed) {
      return l10n.mapTourCompletedSubtitle;
    }
    if (sessionProvider.isTourPaused) {
      return l10n.mapTourPausedSubtitle;
    }
    if (sessionProvider.isInActiveTour) {
      return l10n.mapActiveTourSubtitle;
    }
    if (sessionProvider.isRobotConnected) {
      return l10n.mapRobotReadySubtitle;
    }
    if (hasRobotTourEligibility) {
      return l10n.mapConnectForNavigationSubtitle;
    }
    return l10n.mapExplorePreviewSubtitle;
  }

  Exhibit? _findExhibitById(String? exhibitId) {
    if (exhibitId == null) return null;
    for (final exhibit in exhibits) {
      if (exhibit.id == exhibitId) return exhibit;
    }
    return null;
  }

  String? _reconnectLabel(
    session.AppSessionProvider sessionProvider,
    bool hasRobotTourEligibility,
    AppLocalizations l10n,
  ) {
    final hadTourInProgress =
        sessionProvider.tourLifecycleState ==
            session.TourLifecycleState.active ||
        sessionProvider.tourLifecycleState == session.TourLifecycleState.paused;
    if (sessionProvider.tourLifecycleState ==
        session.TourLifecycleState.completed) {
      return null;
    }
    if (sessionProvider.robotConnectionState ==
            session.RobotConnectionState.failed &&
        hadTourInProgress) {
      return l10n.mapReconnectToHorus;
    }
    if (sessionProvider.robotConnectionState ==
            session.RobotConnectionState.disconnected &&
        hasRobotTourEligibility &&
        hadTourInProgress) {
      return l10n.mapConnectToHorus;
    }
    return null;
  }

  void _maybeRestoreActiveSession() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (!authProvider.isLoggedIn || userId == null || userId.isEmpty) return;
    if (_restoreInFlight || _lastRestoreUid == userId) return;

    _restoreInFlight = true;
    _lastRestoreUid = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final sessionProvider = context.read<session.AppSessionProvider>();
      final tourProvider = context.read<TourProvider>();
      try {
        final restoredSession = await sessionProvider
            .restoreActiveSessionForUser(userId);
        if (!mounted) return;
        if (restoredSession != null) {
          await tourProvider.restoreActiveSessionForUser(userId);
        }
      } on TourSessionRepositoryException catch (e) {
        _lastRestoreUid = null;
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      } finally {
        _restoreInFlight = false;
      }
    });
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
    _maybeRestoreActiveSession();
    final tourProvider = Provider.of<TourProvider>(context);
    final sessionProvider = Provider.of<session.AppSessionProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final hasRobotTourEligibility = ticketProvider.hasValidRobotTourEligibility;
    final hasTourContext =
        sessionProvider.isRobotConnected ||
        sessionProvider.isInActiveTour ||
        sessionProvider.isTourPaused;
    final currentExhibitId = hasTourContext
        ? (sessionProvider.currentExhibitId ?? tourProvider.currentExhibitId)
        : null;
    final nextExhibitId = hasTourContext
        ? (sessionProvider.nextExhibitId ?? tourProvider.nextExhibitId)
        : null;
    final currentExhibit = _findExhibitById(currentExhibitId);
    final nextExhibit = _findExhibitById(nextExhibitId);
    final robotX = currentExhibit == null
        ? mapWidth * 0.5
        : (currentExhibit.x / 400) * mapWidth;
    final robotY = currentExhibit == null
        ? mapHeight * 0.5
        : (currentExhibit.y / 600) * mapHeight;
    final showRobot =
        sessionProvider.shouldShowRobotOnMap &&
        hasTourContext &&
        currentExhibit != null;
    final showPath = sessionProvider.shouldShowRobotPath && showRobot;
    final visitedCount = tourProvider.visitedExhibitIds.length;
    final contentSubtitle = _mapContentSubtitle(
      sessionProvider,
      hasRobotTourEligibility,
      l10n,
    );
    final reconnectLabel = _reconnectLabel(
      sessionProvider,
      hasRobotTourEligibility,
      l10n,
    );
    final showRecoveryCenter =
        showRobot &&
        (sessionProvider.isTourPaused ||
            tourProvider.proximityState == ProximityState.far);
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
      title: 'HORUS-BOT',
      subHeader: null,
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      showChatButton: false,
      hideDefaultAppBar: true,
      floatingActionButton: AskTheGuideButton(
        screen: 'map',
        currentExhibitId: currentExhibitId,
        subtle: true,
      ),
      body: Builder(
        builder: (shellContext) => Stack(
          children: [
            Column(
              children: [
                // Map title content, beneath the Horus-Bot header identity.
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    20,
                    MediaQuery.paddingOf(context).top + 74,
                    20,
                    16,
                  ),
                  decoration: AppDecorations.cinematicBackground(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.museumMap,
                            style: AppTextStyles.titleMedium(
                              context,
                            ).copyWith(fontSize: 15),
                            textAlign: isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contentSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.metadata(
                              context,
                            ).copyWith(color: AppColors.bodyText),
                            textAlign: isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                        ],
                      ),
                      _FilterChip(label: l10n.exhibits),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
                  child: _MapStatusPanel(
                    sessionProvider: sessionProvider,
                    tourProvider: tourProvider,
                    hasRobotTourEligibility: hasRobotTourEligibility,
                    currentExhibit: currentExhibit,
                    nextExhibit: nextExhibit,
                    isArabic: isArabic,
                    visitedCount: visitedCount,
                    actionLabel: reconnectLabel,
                    onAction: reconnectLabel != null
                        ? () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.qrScan,
                              arguments: QRScanMode.robotConnection,
                            );
                          }
                        : null,
                    onRecover: showRecoveryCenter
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
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
                                    tourProvider.followMode ==
                                            FollowModeState.on
                                        ? l10n.mapFollowingHorus
                                        : l10n.mapExploreOwnPace,
                                    style: AppTextStyles.bodyPrimary(
                                      context,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tourProvider.getProximityText(
                                      l10n.localeName,
                                    ),
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
                                          l10n.entrance,
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
                      PositionedDirectional(
                        end: 16,
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
                      PositionedDirectional(
                        start: 16,
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
                            crossAxisAlignment: isArabic
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              // Legend reflects only markers currently visible.
                              if (showRobot) ...[
                                _buildLegendItem(
                                  AppColors.primaryGold,
                                  l10n.horusBot,
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (currentExhibit != null) ...[
                                _buildLegendItem(
                                  AppColors.primaryGold,
                                  l10n.mapCurrent,
                                  icon: Icons.place_rounded,
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (nextExhibit != null) ...[
                                _buildLegendItem(
                                  AppColors.darkGold,
                                  l10n.mapNext,
                                  icon: Icons.flag_rounded,
                                ),
                                const SizedBox(height: 8),
                              ],
                              _buildLegendItem(Colors.blue, l10n.you),
                              const SizedBox(height: 8),
                              if (visitedCount > 0) ...[
                                _buildLegendItem(Colors.green, l10n.visited),
                                const SizedBox(height: 8),
                              ],
                              _buildLegendItem(
                                AppColors.neutralMedium,
                                l10n.exhibit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _MapHomeStyleHeader(
                onMenu: () => AppMenuShell.of(shellContext)?.toggleMenu(),
              ),
            ),
            if (_previewExhibit != null)
              _ExhibitPreviewOverlay(
                exhibit: _previewExhibit!,
                isVisited: _previewIsVisited,
                isCurrent: _previewIsCurrent,
                isNext: _previewIsNext,
                isArabic: isArabic,
                l10n: l10n,
                onClose: _closePreview,
                onViewDetails: () {
                  final exhibit = _previewExhibit;
                  _closePreview();
                  if (exhibit != null) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.exhibitDetails,
                      arguments: exhibit,
                    );
                  }
                },
              ),
          ],
        ),
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
    final l10n = AppLocalizations.of(context)!;
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
          onTap: () => _showExhibitPreview(
            e,
            isVisited: isVisited,
            isCurrent: isCurrent,
            isNext: isNext,
          ),
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
                    isCurrent ? l10n.mapNow : l10n.mapNext,
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
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      left: x - 18,
      top: y - 18,
      child: Tooltip(
        message: l10n.you,
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
  final bool hasRobotTourEligibility;
  final Exhibit? currentExhibit;
  final Exhibit? nextExhibit;
  final bool isArabic;
  final int visitedCount;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onRecover;
  const _MapStatusPanel({
    required this.sessionProvider,
    required this.tourProvider,
    required this.hasRobotTourEligibility,
    required this.currentExhibit,
    required this.nextExhibit,
    required this.isArabic,
    required this.visitedCount,
    required this.actionLabel,
    required this.onAction,
    required this.onRecover,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = _statusCopy(l10n);
    final lang = isArabic ? 'ar' : 'en';
    final canRecover = onRecover != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.secondaryGlassCard(radius: 18, opacity: 0.72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.title,
                      style: AppTextStyles.bodyPrimary(
                        context,
                      ).copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      status.subtitle,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.neutralMedium, height: 1.25),
                      textAlign: TextAlign.start,
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
          if (actionLabel != null && onAction != null) ...[
            _MapPanelAction(label: actionLabel!, onTap: onAction!),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (currentExhibit != null)
                _StatusPill(
                  icon: Icons.place_rounded,
                  label: l10n.mapCurrent,
                  value: currentExhibit!.getName(lang),
                ),
              if (nextExhibit != null)
                _StatusPill(
                  icon: Icons.flag_rounded,
                  label: l10n.mapNext,
                  value: nextExhibit!.getName(lang),
                ),
              _StatusPill(
                icon: Icons.check_circle_outline_rounded,
                label: l10n.mapVisited,
                value: '$visitedCount',
              ),
              _StatusPill(
                icon: tourProvider.followMode == FollowModeState.on
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                label: l10n.mapGuide,
                value: tourProvider.followMode == FollowModeState.on
                    ? l10n.mapGuideActive
                    : l10n.mapGuideFree,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _MapStatusCopy _statusCopy(AppLocalizations l10n) {
    if (sessionProvider.tourLifecycleState ==
        session.TourLifecycleState.completed) {
      return _MapStatusCopy(
        icon: Icons.verified_rounded,
        color: AppColors.primaryGold,
        title: l10n.mapTourCompletedTitle,
        subtitle: l10n.mapTourCompletedStatusSubtitle,
      );
    }
    switch (sessionProvider.robotConnectionState) {
      case session.RobotConnectionState.connecting:
        return _MapStatusCopy(
          icon: Icons.sync_rounded,
          color: AppColors.primaryGold,
          title: l10n.mapConnectingTitle,
          subtitle: l10n.mapConnectingSubtitle,
        );
      case session.RobotConnectionState.connected:
        if (sessionProvider.tourLifecycleState ==
            session.TourLifecycleState.paused) {
          return _MapStatusCopy(
            icon: Icons.pause_circle_outline_rounded,
            color: AppColors.darkGold,
            title: l10n.mapPausedTitle,
            subtitle: l10n.mapPausedStatusSubtitle,
          );
        }
        if (sessionProvider.tourLifecycleState ==
            session.TourLifecycleState.active) {
          return _MapStatusCopy(
            icon: Icons.smart_toy_rounded,
            color: AppColors.primaryGold,
            title: l10n.mapGuidingTitle,
            subtitle: l10n.mapGuidingSubtitle,
          );
        }
        return _MapStatusCopy(
          icon: Icons.smart_toy_rounded,
          color: AppColors.primaryGold,
          title: l10n.mapReadyTitle,
          subtitle: l10n.mapReadyStatusSubtitle,
        );
      case session.RobotConnectionState.failed:
        return _MapStatusCopy(
          icon: Icons.error_outline_rounded,
          color: AppColors.alertRed,
          title: l10n.mapNotConnectedTitle,
          subtitle: l10n.mapNotConnectedSubtitle,
        );
      case session.RobotConnectionState.disconnected:
        if (hasRobotTourEligibility &&
            (sessionProvider.tourLifecycleState ==
                    session.TourLifecycleState.active ||
                sessionProvider.tourLifecycleState ==
                    session.TourLifecycleState.paused)) {
          return _MapStatusCopy(
            icon: Icons.qr_code_scanner_rounded,
            color: AppColors.primaryGold,
            title: l10n.mapConnectForTourTitle,
            subtitle: l10n.mapConnectForTourSubtitle,
          );
        }
        return _MapStatusCopy(
          icon: Icons.explore_rounded,
          color: AppColors.neutralMedium,
          title: l10n.mapExploreExhibitsTitle,
          subtitle: l10n.mapExplorePreviewSubtitle,
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

class _MapPanelAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MapPanelAction({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 17),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.buttonLabel(context).copyWith(fontSize: 13),
        ),
        style: AppDecorations.secondaryButton().copyWith(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(42)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
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

class _MapHomeStyleHeader extends StatelessWidget {
  final VoidCallback onMenu;
  const _MapHomeStyleHeader({required this.onMenu});
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: topPadding + 86,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.26),
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 3, 16, 0),
              child: SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      children: [
                        _HeaderCircleButton(
                          icon: Icons.menu_rounded,
                          onTap: onMenu,
                        ),
                        const Spacer(),
                        const SizedBox(width: 44, height: 44),
                      ],
                    ),
                    const IgnorePointer(child: _MapHeaderBrand()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapHeaderBrand extends StatelessWidget {
  const _MapHeaderBrand();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/icons/ankh.png', width: 18, height: 18),
        const SizedBox(width: 8),
        Text(
          'HORUS-BOT',
          style: AppTextStyles.premiumBrandTitle(context).copyWith(
            fontSize: 17.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.70),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderCircleButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.goldBorder(0.18), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.whiteTitle, size: 22),
        ),
      ),
    );
  }
}

class _ExhibitPreviewOverlay extends StatelessWidget {
  final Exhibit exhibit;
  final bool isVisited;
  final bool isCurrent;
  final bool isNext;
  final bool isArabic;
  final AppLocalizations l10n;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  const _ExhibitPreviewOverlay({
    required this.exhibit,
    required this.isVisited,
    required this.isCurrent,
    required this.isNext,
    required this.isArabic,
    required this.l10n,
    required this.onClose,
    required this.onViewDetails,
  });
  @override
  Widget build(BuildContext context) {
    final lang = isArabic ? 'ar' : 'en';
    final status = isCurrent
        ? l10n.mapCurrentStop
        : isNext
        ? l10n.mapNextStop
        : isVisited
        ? l10n.mapVisited
        : l10n.mapExhibit;
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withValues(alpha: 0.44)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 84),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    decoration: AppDecorations.premiumGlassCard(
                      radius: 28,
                      highlighted: isCurrent || isNext,
                      opacity: 0.88,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.asset(
                              exhibit.imageAsset,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            PositionedDirectional(
                              end: 10,
                              top: 10,
                              child: _HeaderCircleButton(
                                icon: Icons.close_rounded,
                                onTap: onClose,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: isArabic
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              _PreviewStatusBadge(label: status),
                              const SizedBox(height: 10),
                              Text(
                                exhibit.getName(lang),
                                textAlign: TextAlign.start,
                                style: AppTextStyles.displayArtifactTitle(
                                  context,
                                ).copyWith(fontSize: 20),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.grandEgyptianMuseum,
                                style: AppTextStyles.metadata(
                                  context,
                                ).copyWith(color: AppColors.primaryGold),
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                exhibit.getDescription(lang),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: AppTextStyles.bodyPrimary(context)
                                    .copyWith(
                                      color: AppColors.bodyText,
                                      height: 1.35,
                                    ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: onViewDetails,
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    l10n.mapViewDetails,
                                    style: AppTextStyles.buttonLabel(context),
                                  ),
                                  style: AppDecorations.primaryButton(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewStatusBadge extends StatelessWidget {
  final String label;
  const _PreviewStatusBadge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.goldBorder(0.34)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.metadata(context).copyWith(
          color: AppColors.primaryGold,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
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
