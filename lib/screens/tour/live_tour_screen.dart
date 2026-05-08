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
      if (tourProvider.currentExhibitId == null) {
        tourProvider.setCurrentExhibit(
          MockDataService.getAllExhibits().first.id,
        );
      }
      if (sessionProvider.isInActiveTour &&
          tourProvider.tourLifecycleState == TourLifecycleState.notStarted) {
        tourProvider.startTour(context: context);
      }
      if (sessionProvider.isInActiveTour ||
          tourProvider.tourLifecycleState == TourLifecycleState.active ||
          tourProvider.tourLifecycleState == TourLifecycleState.paused) {
        _startSimulation();
      }
    });
  }

  void _startSimulation() {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final exhibitId = tourProvider.currentExhibitId;
    if (exhibitId == null) return;

    final allExhibits = MockDataService.getAllExhibits();
    final exhibit = allExhibits.firstWhere(
      (e) => e.id == exhibitId,
      orElse: () => allExhibits.first,
    );

    final sentences = [
      "Welcome to the ${exhibit.nameEn}.",
      exhibit.descriptionEn,
      "This artifact is extremely significant to our history.",
      "Notice the intricate details on the surface.",
      "It was discovered during a major excavation.",
      "Let's move closer to observe the craftsmanship.",
    ];

    int index = 0;

    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final isProviderPaused =
          Provider.of<TourProvider>(context, listen: false).tourLifecycleState ==
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
    if (tourProvider.tourLifecycleState == TourLifecycleState.paused) {
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
    if (tourProvider.tourLifecycleState != TourLifecycleState.active) return;
    final all = MockDataService.getAllExhibits();
    final currentIdx = all.indexWhere(
      (e) => e.id == tourProvider.currentExhibitId,
    );
    if (currentIdx < all.length - 1) {
      tourProvider.setCurrentExhibit(all[currentIdx + 1].id);
      setState(() {
        _transcript.clear();
      });
      _startSimulation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context);
    final sessionProvider = Provider.of<session.AppSessionProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final sessionTourState = sessionProvider.tourLifecycleState;
    final isSessionPaused = sessionTourState == session.TourLifecycleState.paused;
    final isSessionCompleted =
        sessionTourState == session.TourLifecycleState.completed;
    final isSessionReady =
        sessionTourState == session.TourLifecycleState.readyToStart;
    final isConnectedNotActive =
        sessionProvider.isRobotConnected &&
        sessionTourState != session.TourLifecycleState.active &&
        !isSessionPaused &&
        !isSessionCompleted;
    final isTourAccessible =
        sessionProvider.isInActiveTour ||
        isSessionCompleted ||
        (sessionProvider.isRobotConnected &&
            sessionTourState != session.TourLifecycleState.notStarted) ||
        isSessionReady;

    if (isSessionPaused) {
      return AppMenuShell(
        title: 'HORUS-BOT',
        subHeader: const RobotStatusBanner(),
        bottomNavigationBar: const BottomNav(currentIndex: 2),
        showChatButton: false,
        hideDefaultAppBar: true,
        floatingActionButton: AskTheGuideButton(
          screen: 'live_tour',
          currentExhibitId: tourProvider.currentExhibitId,
          subtle: true,
        ),
        body: _buildLockedState(
          context,
          title: 'Tour paused',
          subtitle: 'Resume your guided museum tour.',
          primaryLabel: 'Resume Tour',
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
      final hasValidTourAccess =
          sessionProvider.hasMuseumEntryTicket &&
          sessionProvider.hasRobotTourTicket;
      final bool shouldScanRobotQr =
          hasValidTourAccess &&
          sessionProvider.robotConnectionState ==
              session.RobotConnectionState.disconnected;

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
              ? 'Connect to Horus-Bot'
              : l10n.liveTourLockedTitle,
          subtitle: shouldScanRobotQr
              ? 'Scan the robot QR code to start your guided tour.'
              : 'Get your ticket first, then connect to Horus-Bot at the museum.',
          primaryLabel: shouldScanRobotQr ? 'Scan Robot QR' : 'Get Tickets',
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
          showSecondaryQrAction: !shouldScanRobotQr,
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
          currentExhibitId: tourProvider.currentExhibitId,
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
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.paddingOf(context).top + 92,
                  20,
                  24,
                ),
                child: _buildReadyStateCard(
                  context,
                  onStartTour: () => tourProvider.startTour(context: context),
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

    final allExhibits = MockDataService.getAllExhibits();
    final currentExhibit = allExhibits.firstWhere(
      (e) => e.id == tourProvider.currentExhibitId,
      orElse: () => allExhibits.first,
    );
    final currentIdx = allExhibits.indexWhere((e) => e.id == currentExhibit.id);
    final nextExhibit = currentIdx < allExhibits.length - 1
        ? allExhibits[currentIdx + 1]
        : null;
    final isPaused =
        tourProvider.tourLifecycleState == TourLifecycleState.paused ||
        isSessionPaused;
    final isCompleted =
        tourProvider.tourLifecycleState == TourLifecycleState.completed ||
        isSessionCompleted;
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
        currentExhibitId: tourProvider.currentExhibitId,
        subtle: true,
      ),
      body: Builder(
        builder: (shellContext) => Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.screenBackground),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.paddingOf(context).top + 92,
                20,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.liveTour.toUpperCase(),
                    style: AppTextStyles.displaySectionTitle(context).copyWith(
                      color: AppColors.softGold,
                      letterSpacing: 1.4,
                    ),
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
                        ? 'Tour completed. Review your summary.'
                        : isPaused
                        ? 'Tour paused. Resume when you are ready.'
                        : isMoving
                        ? 'Horus-Bot is moving to the next stop.'
                        : 'Horus-Bot is currently explaining this exhibit.',
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
                        final appSession = Provider.of<session.AppSessionProvider>(
                          context,
                          listen: false,
                        );
                        tour.completeTour(context: context);
                        appSession.endTour();
                        Navigator.pushReplacementNamed(context, AppRoutes.summary);
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
    BuildContext context,
  {
    required String title,
    required String subtitle,
    required String primaryLabel,
    required VoidCallback onPrimaryAction,
    required bool showSecondaryQrAction,
  }
  ) {
    return Builder(
      builder: (shellContext) => Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.screenBackground),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
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
                        style: AppTextStyles.bodyPrimary(
                          context,
                        ).copyWith(color: AppColors.neutralMedium, height: 1.45),
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
                            label: const Text(
                              'Already have a ticket? Scan Robot QR',
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
    IconData icon;
    Color color;
    String title;

    String subtitle;
    if (isCompleted) {
      icon = Icons.verified_rounded;
      color = AppColors.primaryGold;
      title = 'Tour completed';
      subtitle = 'You can view your summary and memories.';
    } else if (isPaused) {
      icon = Icons.pause_circle_outline_rounded;
      color = Colors.orange;
      title = 'Tour paused';
      subtitle = 'Resume when you are ready to continue with Horus-Bot.';
    } else if (isRecovery) {
      icon = Icons.my_location_rounded;
      color = Colors.redAccent;
      title = 'You are far from Horus-Bot';
      subtitle = 'Use map recovery to return to your guided route.';
    } else if (isMoving) {
      icon = Icons.route_rounded;
      color = Colors.blue;
      title = 'Moving to next stop';
      subtitle = 'Horus-Bot is leading you to the next exhibit.';
    } else if (isLastStop) {
      icon = Icons.flag_circle_rounded;
      color = AppColors.primaryGold;
      title = 'Final exhibit in your tour';
      subtitle = 'You are at the last guided stop.';
    } else {
      icon = Icons.record_voice_over_rounded;
      color = Colors.green;
      title = 'Horus-Bot is guiding now';
      subtitle = 'Stay nearby and enjoy the story.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), AppColors.cinematicCard.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
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
    );
  }

  Widget _buildReadyStateCard(
    BuildContext context, {
    required VoidCallback onStartTour,
    required VoidCallback onGoMap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.goldBorder(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Tour',
            style: AppTextStyles.displaySectionTitle(context).copyWith(
              color: AppColors.softGold,
              fontSize: 13,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Horus-Bot is ready',
            style: AppTextStyles.displayArtifactTitle(context).copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your guided tour when you are ready.',
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: AppColors.neutralMedium),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Start Tour',
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
              child: const Text('Go to Map'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT EXHIBIT',
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onSkip,
                        icon: const Icon(Icons.skip_next_rounded, size: 18),
                        label: const Text('Skip'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onRecover,
                        icon: const Icon(Icons.my_location_rounded, size: 18),
                        label: const Text('Find Horus'),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cinematicSection,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Narration Updates',
            style: AppTextStyles.displaySectionTitle(context).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(
            'Simulated session updates for prototype preview.',
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

  Widget _buildRecoveryCard(BuildContext context, {required VoidCallback onRecover}) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need help finding Horus-Bot?',
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Find Horus on Map',
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
            'Where Horus takes you next',
            style: AppTextStyles.metadata(context).copyWith(
              color: AppColors.softGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
    return Column(
      children: [
        PrimaryButton(
          label: 'View Summary',
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
            child: const Text('Back Home'),
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
              padding: const EdgeInsets.fromLTRB(16, 3, 16, 0),
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
                        Image.asset('assets/icons/ankh.png', width: 18, height: 18),
                        const SizedBox(width: 8),
                        Text(
                          'HORUS-BOT',
                          style: AppTextStyles.premiumBrandTitle(
                            context,
                          ).copyWith(
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
