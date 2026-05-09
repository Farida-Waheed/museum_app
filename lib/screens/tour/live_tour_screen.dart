import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/tour_provider.dart';
import '../../models/app_session_provider.dart' as session;
import '../../core/services/mock_data.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/robot_status_banner.dart';
import '../../widgets/ask_the_guide_button.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import '../../widgets/primary_button.dart';
import '../../app/router.dart';
import '../tickets/qr_scanner_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/ticket_provider.dart';

class LiveTourScreen extends StatefulWidget {
  const LiveTourScreen({super.key});

  @override
  State<LiveTourScreen> createState() => _LiveTourScreenState();
}

class _LiveTourScreenState extends State<LiveTourScreen> {
  final List<String> _transcript = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _simTimer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _checkLocationPermission();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tourProvider = Provider.of<TourProvider>(context, listen: false);
      final sessionProvider = Provider.of<session.AppSessionProvider>(
        context,
        listen: false,
      );
      if (sessionProvider.isInActiveTour &&
          sessionProvider.currentExhibitId != null &&
          tourProvider.tourLifecycleState == TourLifecycleState.notStarted) {
        tourProvider.startTour(
          context: context,
          initialExhibitId: sessionProvider.currentExhibitId,
          nextExhibitId: sessionProvider.nextExhibitId,
        );
      }
      if (sessionProvider.isInActiveTour ||
          sessionProvider.isTourPaused ||
          tourProvider.tourLifecycleState == TourLifecycleState.active ||
          tourProvider.tourLifecycleState == TourLifecycleState.paused) {
        _startSimulation();
      }
    });
  }

  void _startSimulation() {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final sessionProvider = Provider.of<session.AppSessionProvider>(
      context,
      listen: false,
    );
    final exhibitId =
        sessionProvider.currentExhibitId ?? tourProvider.currentExhibitId;
    if (exhibitId == null) return;

    final allExhibits = MockDataService.getAllExhibits();
    final exhibitIndex = allExhibits.indexWhere((e) => e.id == exhibitId);
    if (exhibitIndex < 0) return;
    final exhibit = allExhibits[exhibitIndex];
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    final sentences = [
      l10n.liveTourSimWelcome(exhibit.getName(lang)),
      exhibit.getDescription(lang),
      l10n.liveTourSimSignificance,
      l10n.liveTourSimDetails,
      l10n.liveTourSimDiscovery,
      l10n.liveTourSimMoveCloser,
    ];

    int index = 0;

    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final isProviderPaused =
          Provider.of<TourProvider>(
            context,
            listen: false,
          ).tourLifecycleState ==
          TourLifecycleState.paused;
      if (_isPaused || isProviderPaused) return;
      if (index >= sentences.length) {
        timer.cancel();
        return;
      }
      setState(() => _transcript.add(sentences[index]));
      index++;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final nextMode = tourProvider.followMode == FollowModeState.on
        ? FollowModeState.off
        : FollowModeState.on;
    tourProvider.setFollowMode(nextMode, context: context);
  }

  void _togglePause() {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final sessionProvider = Provider.of<session.AppSessionProvider>(
      context,
      listen: false,
    );
    final isPaused =
        sessionProvider.isTourPaused ||
        tourProvider.tourLifecycleState == TourLifecycleState.paused;
    if (isPaused) {
      tourProvider.resumeTour(context: context);
      sessionProvider.resumeTour();
      setState(() => _isPaused = false);
    } else {
      tourProvider.pauseTour(context: context);
      sessionProvider.pauseTour();
      setState(() => _isPaused = true);
    }
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

  void _skipExhibit() {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final sessionProvider = Provider.of<session.AppSessionProvider>(
      context,
      listen: false,
    );
    if (tourProvider.tourLifecycleState != TourLifecycleState.active) return;
    final all = MockDataService.getAllExhibits();
    final activeExhibitId =
        sessionProvider.currentExhibitId ?? tourProvider.currentExhibitId;
    final currentIdx = all.indexWhere((e) => e.id == activeExhibitId);
    if (currentIdx >= 0 && currentIdx < all.length - 1) {
      final nextExhibit = all[currentIdx + 1];
      final followingExhibit = currentIdx + 2 < all.length
          ? all[currentIdx + 2]
          : null;
      tourProvider.setCurrentExhibit(nextExhibit.id);
      tourProvider.setNextDestination(
        followingExhibit?.id,
        tourProvider.estimatedTimeToNext,
      );
      sessionProvider.setCurrentExhibit(nextExhibit.id);
      sessionProvider.setNextExhibit(followingExhibit?.id);
      setState(() {
        _transcript.clear();
      });
      _startSimulation();
    }
  }

  void _startTourFromReadyState() {
    final allExhibits = MockDataService.getAllExhibits();
    if (allExhibits.isEmpty) return;

    final currentExhibit = allExhibits.first;
    final nextExhibit = allExhibits.length > 1 ? allExhibits[1] : null;
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final sessionProvider = Provider.of<session.AppSessionProvider>(
      context,
      listen: false,
    );

    sessionProvider.startActiveTour(
      currentExhibitId: currentExhibit.id,
      nextExhibitId: nextExhibit?.id,
    );
    tourProvider.startTour(
      context: context,
      initialExhibitId: currentExhibit.id,
      nextExhibitId: nextExhibit?.id,
    );
    setState(() => _isPaused = false);
    _startSimulation();
  }

  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context);
    final sessionProvider = Provider.of<session.AppSessionProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final hasValidTourAccess = ticketProvider.hasValidRobotTourEligibility;

    final sessionTourState = sessionProvider.tourLifecycleState;
    final isSessionPaused =
        sessionTourState == session.TourLifecycleState.paused;
    final isSessionCompleted =
        sessionTourState == session.TourLifecycleState.completed;
    final allExhibits = MockDataService.getAllExhibits();
    final currentExhibitId =
        sessionProvider.currentExhibitId ?? tourProvider.currentExhibitId;
    final currentExhibitIndex = currentExhibitId == null
        ? -1
        : allExhibits.indexWhere((e) => e.id == currentExhibitId);
    final currentExhibit = currentExhibitIndex < 0
        ? null
        : allExhibits[currentExhibitIndex];
    final isConnectedNotActive =
        hasValidTourAccess &&
        sessionProvider.isRobotConnected &&
        (!sessionProvider.hasActiveOrPausedTour || currentExhibit == null) &&
        !isSessionCompleted;
    final isTourAccessible =
        hasValidTourAccess &&
        ((sessionProvider.hasActiveOrPausedTour && currentExhibit != null) ||
            (isSessionCompleted && currentExhibit != null) ||
            isConnectedNotActive);

    if (hasValidTourAccess && isSessionPaused && currentExhibit != null) {
      return AppMenuShell(
        title: 'HORUS-BOT',
        subHeader: const RobotStatusBanner(),
        bottomNavigationBar: const BottomNav(currentIndex: 2),
        showChatButton: false,
        hideDefaultAppBar: true,
        floatingActionButton: AskTheGuideButton(
          screen: 'live_tour',
          currentExhibitId: currentExhibitId,
          subtle: true,
        ),
        body: _buildLockedState(
          context,
          title: l10n.liveTourPausedDesc,
          subtitle: l10n.followAndDiscover,
          primaryLabel: l10n.resume,
          onPrimaryAction: () {
            sessionProvider.resumeTour();
            tourProvider.resumeTour(context: context);
            setState(() => _isPaused = false);
          },
          showSecondaryQrAction: false,
        ),
      );
    }

    if (!isTourAccessible) {
      final bool shouldScanRobotQr =
          hasValidTourAccess &&
          (sessionProvider.robotConnectionState ==
                  session.RobotConnectionState.disconnected ||
              sessionProvider.robotConnectionState ==
                  session.RobotConnectionState.failed);

      return AppMenuShell(
        title: 'HORUS-BOT',
        subHeader: sessionProvider.shouldShowRobotOnMap
            ? const RobotStatusBanner()
            : null,
        bottomNavigationBar: const BottomNav(currentIndex: 2),
        showChatButton: false,
        hideDefaultAppBar: true,
        body: _buildLockedState(
          context,
          title: shouldScanRobotQr
              ? l10n.homeReconnectTitle
              : l10n.liveTourLockedTitle,
          subtitle: shouldScanRobotQr
              ? l10n.liveTourReconnectSubtitle
              : l10n.liveTourLockedDesc,
          primaryLabel: shouldScanRobotQr ? l10n.homeScanRobotQr : l10n.tickets,
          onPrimaryAction: () {
            if (shouldScanRobotQr) {
              Navigator.pushNamed(
                context,
                AppRoutes.qrScan,
                arguments: QRScanMode.robotConnection,
              );
            } else {
              Navigator.pushNamed(context, AppRoutes.tickets);
            }
          },
          showSecondaryQrAction: false,
        ),
      );
    }

    if (isConnectedNotActive) {
      return AppMenuShell(
        title: 'HORUS-BOT',
        subHeader: const RobotStatusBanner(),
        bottomNavigationBar: const BottomNav(currentIndex: 2),
        showChatButton: false,
        hideDefaultAppBar: true,
        floatingActionButton: AskTheGuideButton(
          screen: 'live_tour',
          currentExhibitId: currentExhibitId,
          subtle: true,
        ),
        body: Builder(
          builder: (shellContext) => Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.screenBackground,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsetsDirectional.fromSTEB(
                  20,
                  MediaQuery.paddingOf(context).top + 92,
                  20,
                  24,
                ),
                child: _buildReadyStateCard(
                  context,
                  onStartTour: _startTourFromReadyState,
                  onGoMap: () => Navigator.pushNamed(context, AppRoutes.map),
                ),
              ),
              _LiveTourHeader(
                onMenu: () => AppMenuShell.of(shellContext)?.toggleMenu(),
              ),
            ],
          ),
        ),
      );
    }

    if (currentExhibit == null) {
      return AppMenuShell(
        title: 'HORUS-BOT',
        subHeader: const RobotStatusBanner(),
        bottomNavigationBar: const BottomNav(currentIndex: 2),
        showChatButton: false,
        hideDefaultAppBar: true,
        floatingActionButton: AskTheGuideButton(
          screen: 'live_tour',
          currentExhibitId: currentExhibitId,
          subtle: true,
        ),
        body: _buildLockedState(
          context,
          title: l10n.connectedReady,
          subtitle: l10n.followAndDiscover,
          primaryLabel: l10n.startMyTour,
          onPrimaryAction: _startTourFromReadyState,
          showSecondaryQrAction: false,
        ),
      );
    }
    final currentIdx = currentExhibitIndex;
    final nextExhibit = currentIdx < allExhibits.length - 1
        ? allExhibits[currentIdx + 1]
        : null;
    final isPaused = isSessionPaused;
    final isCompleted = isSessionCompleted;
    final isMoving = tourProvider.robotState == RobotState.moving;
    final isRecovery =
        tourProvider.proximityState == ProximityState.far &&
        tourProvider.connectionState == RobotConnectionState.connected;
    final isLastStop = nextExhibit == null;
    final canPause = !isCompleted && !isPaused;
    final canResume = !isCompleted && isPaused;
    final canSkip = !isCompleted && !isPaused && !isLastStop;
    final canRecover = !isCompleted;

    return AppMenuShell(
      title: 'HORUS-BOT',
      subHeader: const RobotStatusBanner(),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      showChatButton: false,
      hideDefaultAppBar: true,
      floatingActionButton: AskTheGuideButton(
        screen: 'live_tour',
        currentExhibitId: currentExhibitId,
        subtle: true,
      ),
      body: Builder(
        builder: (shellContext) => Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.screenBackground,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(
                20,
                MediaQuery.paddingOf(context).top + 92,
                20,
                24,
              ),
              child: Column(
                crossAxisAlignment:
                    Directionality.of(context) == TextDirection.rtl
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.liveTour.toUpperCase(),
                    style: AppTextStyles.displaySectionTitle(
                      context,
                    ).copyWith(color: AppColors.softGold, letterSpacing: 1.4),
                  ),
                  const SizedBox(height: 8),
                  _buildModeStateBanner(
                    context,
                    isPaused: isPaused,
                    isCompleted: isCompleted,
                    isMoving: isMoving,
                    isRecovery: isRecovery,
                    isLastStop: isLastStop,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusChip(
                        label: tourProvider.followMode == FollowModeState.on
                            ? l10n.followHorusBot
                            : l10n.selfPacedMode,
                        icon: tourProvider.followMode == FollowModeState.on
                            ? Icons.auto_awesome
                            : Icons.person_outline,
                        color: tourProvider.followMode == FollowModeState.on
                            ? Colors.green
                            : Colors.blue,
                        onTap: isCompleted ? null : _toggleMode,
                      ),
                      _StatusChip(
                        label: tourProvider.getTourStateText(l10n.localeName),
                        icon: Icons.radio_button_checked,
                        color:
                            tourProvider.tourLifecycleState ==
                                TourLifecycleState.active
                            ? Colors.green
                            : Colors.orange,
                        isPulsing:
                            tourProvider.tourLifecycleState ==
                            TourLifecycleState.active,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tourProvider.getProximityText(l10n.localeName),
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(color: AppColors.neutralMedium),
                  ),
                  const SizedBox(height: 16),
                  _TourProgressTimeline(
                    currentIndex: currentIdx,
                    total: allExhibits.length,
                    label: l10n.tourProgress,
                  ),
                  const SizedBox(height: 18),
                  _buildCurrentExhibitHero(
                    context,
                    exhibitTitle: currentExhibit.getName(
                      Localizations.localeOf(context).languageCode,
                    ),
                    imageAsset: currentExhibit.imageAsset,
                    statusText: isCompleted
                        ? l10n.visitComplete
                        : isPaused
                        ? l10n.liveTourPausedDesc
                        : isMoving
                        ? l10n.robotMoving
                        : l10n.robotDescribing,
                    pauseLabel: isPaused ? l10n.resume : l10n.pause,
                    onPauseResume: canPause || canResume ? _togglePause : null,
                    onSkip: canSkip ? _skipExhibit : null,
                    onRecover: canRecover
                        ? () => tourProvider.requestRecovery(context)
                        : null,
                  ),
                  const SizedBox(height: 18),
                  _buildNarrationUpdates(context),
                  const SizedBox(height: 18),
                  if (isRecovery && !isCompleted)
                    _buildRecoveryCard(
                      context,
                      onRecover: () => tourProvider.requestRecovery(context),
                    ),
                  if (isRecovery && !isCompleted) const SizedBox(height: 16),
                  if (nextExhibit != null)
                    _buildNextStopCard(
                      context,
                      title: nextExhibit.getName(
                        Localizations.localeOf(context).languageCode,
                      ),
                      imageAsset: nextExhibit.imageAsset,
                      subtitle: l10n.robotWaiting,
                    )
                  else if (!isCompleted)
                    PrimaryButton(
                      label: l10n.endTour,
                      onPressed: () {
                        final tour = Provider.of<TourProvider>(
                          context,
                          listen: false,
                        );
                        final appSession =
                            Provider.of<session.AppSessionProvider>(
                              context,
                              listen: false,
                            );
                        tour.completeTour(context: context);
                        appSession.endTour();
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.summary,
                        );
                      },
                      fullWidth: true,
                    )
                  else
                    _buildCompletedActions(context),
                ],
              ),
            ),
            _LiveTourHeader(
              onMenu: () => AppMenuShell.of(shellContext)?.toggleMenu(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedState(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String primaryLabel,
    required VoidCallback onPrimaryAction,
    required bool showSecondaryQrAction,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Builder(
      builder: (shellContext) => Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.screenBackground,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                24,
                MediaQuery.paddingOf(context).top + 88,
                24,
                104,
              ),
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.cinematicCard.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.goldBorder(0.22)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.36),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.goldBorder(0.4)),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          size: 34,
                          color: AppColors.primaryGold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        style: AppTextStyles.displaySectionTitle(
                          context,
                        ).copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyPrimary(context).copyWith(
                          color: AppColors.neutralMedium,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: primaryLabel,
                        onPressed: onPrimaryAction,
                        fullWidth: true,
                      ),
                      if (showSecondaryQrAction) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.qrScan,
                                arguments: QRScanMode.robotConnection,
                              );
                            },
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 18,
                              color: AppColors.primaryGold,
                            ),
                            label: Text(
                              l10n.scanQrOnRobot,
                              style: TextStyle(
                                color: AppColors.primaryGold,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryGold,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: const Size(0, 34),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          _LiveTourHeader(
            onMenu: () => AppMenuShell.of(shellContext)?.toggleMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeStateBanner(
    BuildContext context, {
    required bool isPaused,
    required bool isCompleted,
    required bool isMoving,
    required bool isRecovery,
    required bool isLastStop,
  }) {
    final l10n = AppLocalizations.of(context)!;
    IconData icon;
    Color color;
    String title;

    String subtitle;
    if (isCompleted) {
      icon = Icons.verified_rounded;
      color = AppColors.primaryGold;
      title = l10n.liveTourCompletedTitle;
      subtitle = l10n.liveTourCompletedSubtitle;
    } else if (isPaused) {
      icon = Icons.pause_circle_outline_rounded;
      color = Colors.orange;
      title = l10n.liveTourPausedTitle;
      subtitle = l10n.liveTourPausedSubtitle;
    } else if (isRecovery) {
      icon = Icons.my_location_rounded;
      color = Colors.redAccent;
      title = l10n.liveTourFarTitle;
      subtitle = l10n.liveTourFarSubtitle;
    } else if (isMoving) {
      icon = Icons.route_rounded;
      color = Colors.blue;
      title = l10n.liveTourMovingTitle;
      subtitle = l10n.liveTourMovingSubtitle;
    } else if (isLastStop) {
      icon = Icons.flag_circle_rounded;
      color = AppColors.primaryGold;
      title = l10n.liveTourFinalTitle;
      subtitle = l10n.liveTourFinalSubtitle;
    } else {
      icon = Icons.record_voice_over_rounded;
      color = Colors.green;
      title = l10n.liveTourGuidingTitle;
      subtitle = l10n.liveTourGuidingSubtitle;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            color.withOpacity(0.2),
            AppColors.cinematicCard.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Row(
        textDirection: Directionality.of(context),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  Directionality.of(context) == TextDirection.rtl
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.metadata(
                    context,
                  ).copyWith(color: AppColors.neutralMedium),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyStateCard(
    BuildContext context, {
    required VoidCallback onStartTour,
    required VoidCallback onGoMap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.goldBorder(0.2)),
      ),
      child: Column(
        crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            l10n.liveTour,
            style: AppTextStyles.displaySectionTitle(context).copyWith(
              color: AppColors.softGold,
              fontSize: 13,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.connectedReady,
            style: AppTextStyles.displayArtifactTitle(
              context,
            ).copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.followAndDiscover,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: AppColors.neutralMedium),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: l10n.startMyTour,
            onPressed: onStartTour,
            fullWidth: true,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onGoMap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGold,
                side: const BorderSide(color: AppColors.primaryGold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(l10n.map),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExhibitHero(
    BuildContext context, {
    required String exhibitTitle,
    required String imageAsset,
    required String statusText,
    required String pauseLabel,
    required VoidCallback? onPauseResume,
    required VoidCallback? onSkip,
    required VoidCallback? onRecover,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.36),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 252,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/museum_interior.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.82),
                        ],
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment:
                        Directionality.of(context) == TextDirection.rtl
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.currentStop.toUpperCase(),
                        style: AppTextStyles.metadata(context).copyWith(
                          color: AppColors.softGold,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        exhibitTitle,
                        style: AppTextStyles.displayArtifactTitle(
                          context,
                        ).copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  Directionality.of(context) == TextDirection.rtl
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(color: AppColors.bodyText),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: pauseLabel,
                  onPressed: onPauseResume ?? () {},
                  fullWidth: true,
                ),
                const SizedBox(height: 8),
                Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onSkip,
                        icon: const Icon(Icons.skip_next_rounded, size: 18),
                        label: Text(l10n.skip),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onRecover,
                        icon: const Icon(Icons.my_location_rounded, size: 18),
                        label: Text(l10n.startNavigation),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrationUpdates(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cinematicSection,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            l10n.liveTranscript,
            style: AppTextStyles.displaySectionTitle(
              context,
            ).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(
            l10n.chatInfoPopup,
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: AppColors.neutralMedium),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: _transcript.length,
              itemBuilder: (context, index) {
                final isLast = index == _transcript.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _transcript[index],
                    style: AppTextStyles.bodyPrimary(context).copyWith(
                      fontSize: 14,
                      color: isLast ? Colors.white : AppColors.neutralMedium,
                      fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryCard(
    BuildContext context, {
    required VoidCallback onRecover,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.alertRed.withOpacity(0.2),
            AppColors.cinematicCard.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.alertRed.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            l10n.connectionLost,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: l10n.startNavigation,
            onPressed: onRecover,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNextStopCard(
    BuildContext context, {
    required String title,
    required String imageAsset,
    required String subtitle,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nextStopLabel,
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: AppColors.softGold, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            textDirection: Directionality.of(context),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imageAsset,
                  width: 66,
                  height: 66,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/museum_interior.jpg',
                    width: 66,
                    height: 66,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      Directionality.of(context) == TextDirection.rtl
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium(
                        context,
                      ).copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.neutralMedium),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        PrimaryButton(
          label: l10n.visitSummary,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.summary),
          fullWidth: true,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.mainHome,
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGold,
              side: const BorderSide(color: AppColors.primaryGold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(l10n.home),
          ),
        ),
      ],
    );
  }
}

class _LiveTourHeader extends StatelessWidget {
  final VoidCallback onMenu;
  const _LiveTourHeader({required this.onMenu});

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
                      Colors.black.withOpacity(0.30),
                      Colors.black.withOpacity(0.12),
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/ankh.png',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'HORUS-BOT',
                          style: AppTextStyles.premiumBrandTitle(context)
                              .copyWith(
                                color: AppColors.primaryGold,
                                fontSize: 17.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.70),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ),
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

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.cardGlass(0.48),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.goldBorder(0.18)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPulsing;
  final VoidCallback? onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    this.isPulsing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isPulsing
                ? _PulsingDot(color: color)
                : Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.metadata(context).copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          icon: Icon(icon),
          iconSize: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.metadata(
            context,
          ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _TourProgressTimeline extends StatelessWidget {
  final int currentIndex;
  final int total;
  final String label;

  const _TourProgressTimeline({
    required this.currentIndex,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.displaySectionTitle(context),
            ),
            Text(
              "${currentIndex + 1} / $total",
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(total, (index) {
            final isCompleted = index < currentIndex;
            final isCurrent = index == currentIndex;

            return Expanded(
              child: Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryGold
                      : (isCurrent
                            ? AppColors.primaryGold.withOpacity(0.3)
                            : AppColors.cinematicSection),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
