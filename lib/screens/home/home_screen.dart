import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/mock_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_session_provider.dart' as app;
import '../../models/auth_provider.dart';
import '../../models/exhibit.dart';
import '../../models/ticket_provider.dart';
import '../../models/tour_provider.dart';
import '../../models/user_preferences.dart';
import '../../screens/tickets/qr_scanner_screen.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/ask_the_guide_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import 'state/home_controller.dart';
import 'state/home_snapshot.dart';
import 'widgets/home_featured_artifact_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_info_card.dart';
import 'widgets/home_map_preview_card.dart';
import 'widgets/home_quick_actions_grid.dart';
import 'widgets/home_stats_row.dart';
import 'widgets/live_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _readyCardOverlap = 58;
  final HomeController _homeController = const HomeController();
  final ScrollController _scrollController = ScrollController();
  late final List<Exhibit> exhibits;

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      final prefs = context.read<UserPreferencesModel>();
      if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
        await _requestInitialPermissions(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _requestInitialPermissions(BuildContext context) async {
    final prefs = context.read<UserPreferencesModel>();
    final l10n = AppLocalizations.of(context)!;

    if (kIsWeb) {
      prefs.setHasSeenLocationPrompt(true);
      return;
    }

    final notifStatus = await Permission.notification.status;
    if (!context.mounted) return;
    if (!notifStatus.isGranted && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (context) => BrandedPermissionDialog(
          icon: Icons.notifications_none_rounded,
          title: l10n.notificationPermissionTitle,
          description: l10n.notificationPermissionDesc,
          isHighContrast: prefs.isHighContrast,
          onAllow: () async {
            Navigator.pop(context);
            await Permission.notification.request();
          },
          onDeny: () => Navigator.pop(context),
        ),
      );
      if (!context.mounted) return;
    }

    final locStatus = await Permission.locationWhenInUse.status;
    if (!context.mounted) return;
    if (!locStatus.isGranted && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (context) => BrandedPermissionDialog(
          icon: Icons.location_on_outlined,
          title: l10n.locationPermissionTitle,
          description: l10n.locationPermissionDesc,
          helperText: l10n.dataReassurance,
          isHighContrast: prefs.isHighContrast,
          onAllow: () async {
            Navigator.pop(context);
            prefs.setHasSeenLocationPrompt(true);
            await Permission.locationWhenInUse.request();
          },
          onDeny: () {
            Navigator.pop(context);
            prefs.setHasSeenLocationPrompt(true);
          },
        ),
      );
      if (!context.mounted) return;
    } else {
      prefs.setHasSeenLocationPrompt(true);
    }
  }

  HomeSnapshot _snapshot(BuildContext context) {
    return _homeController.buildSnapshot(
      authProvider: context.watch<AuthProvider>(),
      ticketProvider: context.watch<TicketProvider>(),
      sessionProvider: context.watch<app.AppSessionProvider>(),
      tourProvider: context.watch<TourProvider>(),
      exhibits: exhibits,
      lang: Localizations.localeOf(context).languageCode,
    );
  }

  void _openRobotPairing(BuildContext context) {
    final ticketProvider = context.read<TicketProvider>();
    final sessionProvider = context.read<app.AppSessionProvider>();
    final isReconnect =
        sessionProvider.robotConnectionState == app.RobotConnectionState.failed;
    if (!ticketProvider.hasValidRobotTourEligibility && !isReconnect) {
      Navigator.pushNamed(context, AppRoutes.tickets);
      return;
    }
    sessionProvider.startVisiting();
    sessionProvider.startRobotConnection();
    Navigator.pushNamed(
      context,
      AppRoutes.qrScan,
      arguments: QRScanMode.robotConnection,
    );
  }

  void _openTickets(BuildContext context, HomeSnapshot snapshot) {
    Navigator.pushNamed(
      context,
      snapshot.hasAnyTicket ? AppRoutes.myTickets : AppRoutes.tickets,
    );
  }

  void _openTourFlow(BuildContext context, HomeSnapshot snapshot) {
    final sessionProvider = context.read<app.AppSessionProvider>();
    final tourProvider = context.read<TourProvider>();

    if (snapshot.isTourPaused) {
      sessionProvider.resumeTour();
      tourProvider.resumeTour(context: context);
      Navigator.pushNamed(context, AppRoutes.liveTour);
      return;
    }

    if (snapshot.hasActiveTour || snapshot.isTourCompleted) {
      Navigator.pushNamed(context, AppRoutes.liveTour);
      return;
    }

    if (snapshot.robotStatus == HomeRobotStatus.error) {
      _openRobotPairing(context);
      return;
    }

    if (snapshot.hasRobotTourEligibility && !snapshot.isRobotConnected) {
      _openRobotPairing(context);
      return;
    }

    if (snapshot.hasRobotTourEligibility && snapshot.isRobotConnected) {
      Navigator.pushNamed(context, AppRoutes.liveTour);
      return;
    }

    sessionProvider.startVisiting();
    Navigator.pushNamed(context, AppRoutes.tickets);
  }

  void _openMap(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.map, (route) => false);
  }

  void _openArtifactDetails(
    BuildContext context,
    HomeFeaturedArtifact artifact,
  ) {
    final exhibit = exhibits.firstWhere(
      (item) => item.id == artifact.id,
      orElse: () => exhibits.isNotEmpty
          ? exhibits.first
          : MockDataService.getAllExhibits().first,
    );
    Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: exhibit);
  }

  ({
    String label,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  })
  _statusModel(BuildContext context, HomeSnapshot snapshot, bool isArabic) {
    final l10n = AppLocalizations.of(context)!;
    if (!snapshot.hasAnyTicket) {
      return (
        label: l10n.homeReadyLabel,
        title: l10n.homeReadyTitle,
        subtitle: l10n.homeReadySubtitle,
        icon: Icons.explore_rounded,
        onTap: () => _openTickets(context, snapshot),
      );
    }

    if (snapshot.robotStatus == HomeRobotStatus.error) {
      return (
        label: l10n.homeConnectionLostLabel,
        title: l10n.homeReconnectTitle,
        subtitle: l10n.homeReconnectSubtitle,
        icon: Icons.wifi_off_rounded,
        onTap: () => _openRobotPairing(context),
      );
    }

    if (snapshot.isTourCompleted) {
      return (
        label: l10n.homeTourCompletedLabel,
        title: l10n.homeTourCompletedTitle,
        subtitle: l10n.homeTourCompletedSubtitle,
        icon: Icons.verified_rounded,
        onTap: () => _openTourFlow(context, snapshot),
      );
    }

    if (snapshot.isTourPaused) {
      return (
        label: l10n.homeTourPausedLabel,
        title: l10n.homeTourPausedTitle,
        subtitle: l10n.homeTourPausedSubtitle,
        icon: Icons.pause_circle_outline_rounded,
        onTap: () => _openTourFlow(context, snapshot),
      );
    }

    if (snapshot.hasActiveTour) {
      final exhibit = snapshot.currentExhibitName ?? snapshot.nextStopName;
      switch (snapshot.robotStatus) {
        case HomeRobotStatus.speaking:
          return (
            label: l10n.homeHorusSpeakingLabel,
            title: exhibit ?? l10n.currentStop,
            subtitle: exhibit == null
                ? l10n.homeListenRobotSubtitle
                : l10n.homeCurrentStopValue(exhibit),
            icon: Icons.record_voice_over_rounded,
            onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
          );
        case HomeRobotStatus.moving:
          return (
            label: l10n.homeHorusMovingLabel,
            title: snapshot.nextStopName ?? l10n.nextStopLabel,
            subtitle: l10n.homeStayCloseSubtitle,
            icon: Icons.route_rounded,
            onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
          );
        default:
          return (
            label: l10n.homeHorusWaitingLabel,
            title: exhibit ?? l10n.homeContinueTourAction,
            subtitle: l10n.homeAskOrContinueSubtitle,
            icon: Icons.hourglass_top_rounded,
            onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
          );
      }
    }

    if (snapshot.hasValidMuseumTicket &&
        !snapshot.hasRobotTourTicket &&
        !snapshot.isRobotConnected) {
      return (
        label: l10n.homeMuseumTicketReadyLabel,
        title: l10n.homeMuseumTicketReadyTitle,
        subtitle: l10n.startMyTourDescription,
        icon: Icons.confirmation_number_outlined,
        onTap: () => Navigator.pushNamed(context, AppRoutes.tickets),
      );
    }

    if (snapshot.hasRobotTourEligibility && !snapshot.isRobotConnected) {
      return (
        label: l10n.homeMuseumTicketReadyLabel,
        title: l10n.homeMuseumTicketReadyTitle,
        subtitle: l10n.homeConnectTourSubtitle,
        icon: Icons.qr_code_scanner_rounded,
        onTap: () => _openRobotPairing(context),
      );
    }

    if (snapshot.isRobotConnected) {
      return (
        label: l10n.homeConnectedLabel,
        title: l10n.homeConnectedTitle,
        subtitle: _robotMetaLine(snapshot, l10n),
        icon: Icons.smart_toy_outlined,
        onTap: () => _openTourFlow(context, snapshot),
      );
    }

    return (
      label: l10n.homeNextStopCaps,
      title: snapshot.nextStopName ?? l10n.homeTutankhamunHall,
      subtitle: l10n.homeMinutesAway(
        snapshot.estimatedTimeToNextStop ?? 5,
        snapshot.nextStopLocation ?? l10n.homeGoldenHall,
      ),
      icon: Icons.near_me_rounded,
      onTap: () => _openTourFlow(context, snapshot),
    );
  }

  String _robotMetaLine(HomeSnapshot snapshot, AppLocalizations l10n) {
    final parts = <String>[];
    if (snapshot.connectedRobotName.isNotEmpty) {
      parts.add(snapshot.connectedRobotName);
    }
    if (snapshot.robotBatteryPercent != null) {
      parts.add(l10n.homeBattery(snapshot.robotBatteryPercent!));
    }
    if (snapshot.lastRobotSyncTime != null) {
      parts.add(_syncLabel(snapshot.lastRobotSyncTime!, l10n));
    }
    return parts.join(' · ');
  }

  String _syncLabel(DateTime time, AppLocalizations l10n) {
    final elapsed = DateTime.now().difference(time);
    if (elapsed.inMinutes < 1) {
      return l10n.homeSyncedNow;
    }
    if (elapsed.inMinutes < 60) {
      return l10n.homeSyncedMinutesAgo(elapsed.inMinutes);
    }
    return l10n.homeSyncedHoursAgo(elapsed.inHours);
  }

  String _primaryActionLabel(HomeSnapshot snapshot, AppLocalizations l10n) {
    if (snapshot.robotStatus == HomeRobotStatus.error) {
      return l10n.homeReconnectAction;
    }
    if (snapshot.isTourPaused) {
      return l10n.homeResumeTourAction;
    }
    if (snapshot.hasActiveTour || snapshot.isTourCompleted) {
      return l10n.homeContinueTourAction;
    }
    if (snapshot.hasRobotTourEligibility && !snapshot.isRobotConnected) {
      return l10n.homeScanRobotQr;
    }
    return l10n.startMyTour;
  }

  String _ticketStatusLine(HomeSnapshot snapshot, AppLocalizations l10n) {
    if (!snapshot.hasAnyTicket) {
      return l10n.homeNoTicketsYet;
    }
    if (snapshot.hasValidMuseumTicket && !snapshot.hasRobotTourTicket) {
      return l10n.homeMuseumTicketReadyTitle;
    }
    if (snapshot.hasValidMuseumTicket && snapshot.hasRobotTourTicket) {
      return l10n.homeMuseumAndRobotTicketsReady;
    }
    if (snapshot.ticketCount == 1) {
      return l10n.homeOneTicketReady;
    }
    return l10n.homeTicketsSaved(snapshot.ticketCount);
  }

  List<HomeStatItem> _tourStats(HomeSnapshot snapshot, AppLocalizations l10n) {
    final stopsValue = '${snapshot.visitedCount} / ${snapshot.totalExhibits}';
    final nextStop = snapshot.isTourCompleted
        ? l10n.homeComplete
        : (snapshot.nextStopName ?? snapshot.currentExhibitName ?? '-');
    final minutes = snapshot.estimatedTimeToNextStop;
    return [
      HomeStatItem(
        icon: Icons.account_tree_outlined,
        value: stopsValue,
        label: l10n.homeStopsVisited,
      ),
      HomeStatItem(
        icon: Icons.place_outlined,
        value: nextStop,
        label: snapshot.currentExhibitName != null && snapshot.hasActiveTour
            ? l10n.currentStop
            : l10n.nextStopLabel,
      ),
      HomeStatItem(
        icon: Icons.schedule_rounded,
        value: snapshot.isTourCompleted
            ? l10n.done
            : (minutes == null
                  ? '${snapshot.tourDurationMinutes}m'
                  : '$minutes ${l10n.minutes}'),
        label: l10n.homeTimeLeft,
      ),
    ];
  }

  String _artifactSectionLabel(HomeSnapshot snapshot, AppLocalizations l10n) {
    if (snapshot.hasActiveTour && snapshot.currentExhibitName != null) {
      return l10n.homeCurrentExhibitCaps;
    }
    if ((snapshot.hasActiveTour || snapshot.isTourPaused) &&
        snapshot.nextStopName != null) {
      return l10n.homeNextStopCaps;
    }
    return l10n.homeDiscoverArtifactsCaps;
  }

  HomeFeaturedArtifact _contextualArtifact(
    HomeSnapshot snapshot,
    AppLocalizations l10n,
  ) {
    if (snapshot.hasActiveTour && snapshot.currentExhibitName != null) {
      return HomeFeaturedArtifact(
        id: snapshot.featuredArtifact.id,
        title: snapshot.currentExhibitName!,
        subtitle: l10n.homeHorusExplainingStop,
        imageAsset: snapshot.featuredArtifact.imageAsset,
        contextHint: l10n.homeContinueStory,
      );
    }
    if ((snapshot.hasActiveTour || snapshot.isTourPaused) &&
        snapshot.nextStopName != null) {
      return HomeFeaturedArtifact(
        id: snapshot.featuredArtifact.id,
        title: snapshot.nextStopName!,
        subtitle: l10n.homePreviewBeforeHorus,
        imageAsset: snapshot.featuredArtifact.imageAsset,
        contextHint: l10n.homeTapForDetails,
      );
    }
    return HomeFeaturedArtifact(
      id: snapshot.featuredArtifact.id,
      title: snapshot.featuredArtifact.title,
      subtitle: l10n.homeGoldenHallRecommended,
      imageAsset: snapshot.featuredArtifact.imageAsset,
      contextHint: snapshot.featuredArtifact.contextHint,
    );
  }

  String _heroSubtitle(HomeSnapshot snapshot, AppLocalizations l10n) {
    if (snapshot.isLoggedIn) {
      return l10n.homeWelcomeUser(snapshot.userName);
    }
    return l10n.homeGuestSubtitle;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesModel>();
    final isArabic = prefs.language == 'ar';
    final l10n = AppLocalizations.of(context)!;
    final snapshot = _snapshot(context);
    final status = _statusModel(context, snapshot, isArabic);
    final heroHeight = MediaQuery.sizeOf(context).height * 0.56;
    final contextualArtifact = _contextualArtifact(snapshot, l10n);
    final canShowRobotQr =
        snapshot.hasRobotTourEligibility ||
        snapshot.robotStatus == HomeRobotStatus.error;

    final quickActions = <HomeQuickActionItem>[
      HomeQuickActionItem(
        icon: Icons.map_outlined,
        label: l10n.map,
        subtitle: l10n.homeFullMap,
        onTap: () => _openMap(context),
      ),
      if (canShowRobotQr)
        HomeQuickActionItem(
          icon: Icons.qr_code_scanner_rounded,
          label: l10n.homeScanRobotQr,
          subtitle: l10n.homePairWithHorus,
          onTap: () => _openRobotPairing(context),
        )
      else
        HomeQuickActionItem(
          icon: Icons.confirmation_number_outlined,
          label: l10n.viewTickets,
          subtitle: l10n.startMyTourDescription,
          onTap: () => _openTickets(context, snapshot),
        ),
      HomeQuickActionItem(
        icon: Icons.confirmation_number_outlined,
        label: l10n.myTickets,
        subtitle: l10n.homeStoredQrCodes,
        onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets),
      ),
      HomeQuickActionItem(
        icon: Icons.photo_library_outlined,
        label: l10n.gallery,
        subtitle: l10n.homeExploreArtifacts,
        onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
      ),
    ];

    return AppMenuShell(
      hideDefaultAppBar: true,
      backgroundColor: AppColors.baseBlack,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      showChatButton: false,
      body: Builder(
        builder: (innerContext) => Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.screenBackground,
                  ),
                ),
              ),
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(bottom: 112),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: heroHeight + _readyCardOverlap,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _HeroSection(
                              height: heroHeight,
                              title: l10n.homeExploreWithHorus,
                              subtitle: _heroSubtitle(snapshot, l10n),
                              isArabic: isArabic,
                              scrollController: _scrollController,
                            ),
                            Positioned(
                              left: AppSpacing.screenHorizontal,
                              right: AppSpacing.screenHorizontal,
                              bottom: 0,
                              child: LiveStatusCard(
                                label: status.label,
                                title: status.title,
                                subtitle: status.subtitle,
                                icon: status.icon,
                                isArabic: isArabic,
                                trailingLabel: snapshot.isRobotConnected
                                    ? snapshot.robotStatusLabel
                                    : null,
                                onTap: status.onTap,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (snapshot.shouldShowStats) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: HomeStatsRow(
                            items: _tourStats(snapshot, l10n),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: _PrimaryActionCard(
                          isArabic: isArabic,
                          title: l10n.homePlanVisitTitle,
                          subtitle: l10n.homePlanVisitSubtitle,
                          statusLine: _ticketStatusLine(snapshot, l10n),
                          primaryLabel: l10n.viewTickets,
                          secondaryLabel: _primaryActionLabel(snapshot, l10n),
                          onPrimary: () => _openTickets(context, snapshot),
                          onSecondary: () => _openTourFlow(context, snapshot),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(label: l10n.homeQuickActions),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeQuickActionsGrid(items: quickActions),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(
                        label: _artifactSectionLabel(snapshot, l10n),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeFeaturedArtifactCard(
                          artifact: contextualArtifact,
                          onTap: () =>
                              _openArtifactDetails(context, contextualArtifact),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(label: l10n.mapPreview),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeMapPreviewCard(
                          data: snapshot.mapPreview,
                          legendHorus: 'Horus',
                          legendYou: l10n.you,
                          fullViewLabel: l10n.fullView,
                          liveLabel: l10n.live,
                          onTap: () => _openMap(context),
                          onFullView: () => _openMap(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeInfoCard(
                          title: l10n.didYouKnow,
                          body: snapshot.didYouKnowText,
                          icon: Icons.auto_awesome_rounded,
                          bodyColor: AppColors.whiteTitle,
                        ),
                      ),
                      if (snapshot.smallUpdateCard != null) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: HomeInfoCard(
                            title: l10n.homeMuseumUpdate,
                            body: snapshot.smallUpdateCard!,
                            icon: Icons.campaign_outlined,
                            bodyColor: AppColors.bodyText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: HomeHeader(
                  onMenu: () => AppMenuShell.of(innerContext)?.toggleMenu(),
                  onScanRobotQr: () => _openRobotPairing(innerContext),
                  scrollController: _scrollController,
                  showScanRobotQr: canShowRobotQr,
                ),
              ),
              PositionedDirectional(
                end: 12,
                bottom: 12,
                child: AskTheGuideButton(
                  screen: 'home',
                  currentExhibitId: context
                      .watch<TourProvider>()
                      .currentExhibitId,
                  subtle: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.isArabic,
    required this.scrollController,
  });

  final double height;
  final String title;
  final String subtitle;
  final bool isArabic;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        final offset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;
        final opacity = (1.0 - (offset / 240)).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/colossal-statue-of-ramesses-ii.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 72,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x26000000), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 284,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xF2000000),
                          Color(0xD1000000),
                          Color(0x66000000),
                          Color(0x00000000),
                        ],
                        stops: [0.0, 0.32, 0.68, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 82,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: AppTextStyles.premiumHero(context).copyWith(
                          fontSize: isArabic ? 30 : 32,
                          height: 1.08,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.82),
                              blurRadius: 22,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: isArabic
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            style: AppTextStyles.premiumBody(context).copyWith(
                              fontSize: 14.5,
                              color: AppColors.whiteTitle.withValues(
                                alpha: 0.84,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        14,
      ),
      child: Text(
        label,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style: AppTextStyles.premiumSectionLabel(
          context,
        ).copyWith(color: AppColors.softGold),
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.isArabic,
    required this.title,
    required this.subtitle,
    required this.statusLine,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final bool isArabic;
  final String title;
  final String subtitle;
  final String statusLine;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardGlass(0.58),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.goldBorder(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: AppTextStyles.premiumScreenTitle(
                  context,
                ).copyWith(fontSize: 22),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: AppTextStyles.premiumBody(
                  context,
                ).copyWith(fontSize: 14, color: AppColors.bodyText),
              ),
              const SizedBox(height: 15),
              _TicketStatusPill(label: statusLine, isArabic: isArabic),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stackButtons = constraints.maxWidth < 330;
                  if (stackButtons) {
                    return Column(
                      children: [
                        _ActionButton.primary(
                          label: primaryLabel,
                          icon: Icons.confirmation_number_outlined,
                          onTap: onPrimary,
                        ),
                        const SizedBox(height: 12),
                        _ActionButton.secondary(
                          label: secondaryLabel,
                          icon: Icons.play_arrow_rounded,
                          onTap: onSecondary,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _ActionButton.primary(
                          label: primaryLabel,
                          icon: Icons.confirmation_number_outlined,
                          onTap: onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton.secondary(
                          label: secondaryLabel,
                          icon: Icons.play_arrow_rounded,
                          onTap: onSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketStatusPill extends StatelessWidget {
  const _TicketStatusPill({required this.label, required this.isArabic});

  final String label;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isArabic
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.primaryGold,
              size: 15,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.premiumMutedBody(
                  context,
                ).copyWith(color: AppColors.bodyText, fontSize: 12.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton.primary({
    required this.label,
    required this.icon,
    required this.onTap,
  }) : primary = true;

  const _ActionButton.secondary({
    required this.label,
    required this.icon,
    required this.onTap,
  }) : primary = false;

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 48,
          decoration: primary
              ? BoxDecoration(
                  gradient: AppGradients.premiumGold,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldBorder(0.42)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                )
              : BoxDecoration(
                  color: AppColors.cardGlass(0.36),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.goldBorder(0.42),
                    width: 1.1,
                  ),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: primary ? AppColors.darkInk : AppColors.primaryGold,
                size: 19,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.premiumButtonLabel(context).copyWith(
                    fontSize: 15,
                    color: primary ? AppColors.darkInk : AppColors.primaryGold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
