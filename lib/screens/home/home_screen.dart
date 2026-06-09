import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_session_provider.dart' as app;
import '../../models/auth_provider.dart';
import '../../models/exhibit.dart';
import '../../models/exhibit_provider.dart';
import '../../models/ticket_provider.dart';
import '../../models/tour_provider.dart';
import '../../models/user_preferences.dart';
import '../../screens/tickets/qr_scanner_screen.dart';
import '../../services/tour_session_repository.dart';
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
  static final DateTime _sessionRotationStartedAt = DateTime.now();
  final HomeController _homeController = const HomeController();
  final ScrollController _scrollController = ScrollController();
  String? _lastRestoreUid;
  String? _loadedTicketsUserId;
  bool _restoreInFlight = false;
  late Timer _homeRotationTimer;
  late int _rotationMinuteIndex;

  @override
  void initState() {
    super.initState();
    _rotationMinuteIndex = _currentSessionMinuteIndex;
    _scheduleHomeRotationTimer();

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      final prefs = context.read<UserPreferencesModel>();
      if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
        await _requestInitialPermissions(context);
      }
    });
  }

  int get _currentSessionMinuteIndex {
    final elapsed = DateTime.now().difference(_sessionRotationStartedAt);
    return elapsed.inMinutes;
  }

  void _scheduleHomeRotationTimer() {
    final elapsed = DateTime.now().difference(_sessionRotationStartedAt);
    final secondsUntilNextMinute = 60 - (elapsed.inSeconds % 60);
    _homeRotationTimer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      if (!mounted) return;
      _syncRotationMinute();
      _scheduleHomeRotationTimer();
    });
  }

  void _syncRotationMinute({bool rebuild = true}) {
    final minuteIndex = _currentSessionMinuteIndex;
    if (minuteIndex == _rotationMinuteIndex) return;
    if (!rebuild) {
      _rotationMinuteIndex = minuteIndex;
      return;
    }
    setState(() => _rotationMinuteIndex = minuteIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRotationMinute(rebuild: false);
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (!authProvider.isLoggedIn || userId == null) {
      _loadedTicketsUserId = null;
      return;
    }
    if (authProvider.isLoggedIn && userId != _loadedTicketsUserId) {
      _loadedTicketsUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TicketProvider>().loadUserTickets(userId);
      });
    }
  }

  @override
  void dispose() {
    _homeRotationTimer.cancel();
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

  HomeSnapshot _snapshot(BuildContext context, List<Exhibit> exhibits) {
    return _homeController.buildSnapshot(
      authProvider: context.watch<AuthProvider>(),
      ticketProvider: context.watch<TicketProvider>(),
      sessionProvider: context.watch<app.AppSessionProvider>(),
      tourProvider: context.watch<TourProvider>(),
      exhibits: exhibits,
      lang: Localizations.localeOf(context).languageCode,
      didYouKnowIndex: _rotationMinuteIndex,
      featuredArtifactIndex: _rotationMinuteIndex,
    );
  }

  void _openRobotPairing(BuildContext context) {
    final ticketProvider = context.read<TicketProvider>();
    final sessionProvider = context.read<app.AppSessionProvider>();
    final isReconnect =
        sessionProvider.robotConnectionState == app.RobotConnectionState.failed;
    if (!ticketProvider.hasValidRobotTourEligibility && !isReconnect) {
      Navigator.pushNamed(context, AppRoutes.buyTickets);
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
    if (snapshot.isLoggedIn && snapshot.hasAnyTicket) {
      Navigator.pushNamed(context, AppRoutes.myTickets);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.buyTickets);
  }

  Future<void> _openTourFlow(
    BuildContext context,
    HomeSnapshot snapshot,
  ) async {
    final sessionProvider = context.read<app.AppSessionProvider>();
    final tourProvider = context.read<TourProvider>();

    if (snapshot.isTourPaused) {
      final sessionId = sessionProvider.activeSessionId;
      if (sessionId != null) {
        try {
          await TourSessionRepository().resumeSession(sessionId);
        } on TourSessionRepositoryException catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
          return;
        }
      }
      if (!context.mounted) return;
      if (sessionId == null) {
        sessionProvider.resumeTour();
        tourProvider.resumeTour(context: context);
      }
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
    Navigator.pushNamed(context, AppRoutes.buyTickets);
  }

  void _openMap(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.map, (route) => false);
  }

  void _openChat(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.chat);
  }

  void _openSummary(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.summary);
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
      final sessionProvider = context.read<app.AppSessionProvider>();
      try {
        await sessionProvider.restoreActiveSessionForUser(userId);
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

  void _openArtifactDetails(
    BuildContext context,
    HomeFeaturedArtifact artifact,
    List<Exhibit> exhibits,
  ) {
    if (exhibits.isEmpty) return;
    final exhibit = exhibits.firstWhere(
      (item) => item.id == artifact.id,
      orElse: () => exhibits.first,
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
    switch (snapshot.dashboardState) {
      case HomeDashboardState.staffBlocked:
        return (
          label: 'Staff account',
          title: 'Use the staff portal',
          subtitle: AuthProvider.staffAccountMessage,
          icon: Icons.admin_panel_settings_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
        );
      case HomeDashboardState.guest:
        return (
          label: 'Explore the museum',
          title: 'Plan your visit',
          subtitle: 'Sign in to plan and save your personalized museum route.',
          icon: Icons.museum_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
        );
      case HomeDashboardState.loggedInNoTickets:
        return (
          label: 'Plan visit',
          title: 'Welcome back, ${snapshot.userName}',
          subtitle: 'Book a museum entry and Horus-Bot tour when ready.',
          icon: Icons.explore_rounded,
          onTap: () => Navigator.pushNamed(context, AppRoutes.buyTickets),
        );
      case HomeDashboardState.paymentPending:
        return (
          label: 'Payment pending',
          title: 'Pay at the counter',
          subtitle: 'Your QR code unlocks after cashier confirmation.',
          icon: Icons.payments_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets),
        );
      case HomeDashboardState.ticketReady:
        return (
          label: 'Ticket ready',
          title: 'Your tickets are ready',
          subtitle: 'View your QR now. Scan the robot QR when you arrive.',
          icon: Icons.confirmation_number_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets),
        );
      case HomeDashboardState.awaitingRobotPairing:
        return (
          label: 'At the museum',
          title: 'Find your Horus-Bot',
          subtitle: 'Scan the robot QR nearby to start your guided tour.',
          icon: Icons.qr_code_scanner_rounded,
          onTap: () => _openRobotPairing(context),
        );
      case HomeDashboardState.tourCompleted:
        return (
          label: l10n.homeTourCompletedLabel,
          title: 'Tour completed',
          subtitle: 'Your visit summary, memories, and achievements are ready.',
          icon: Icons.verified_rounded,
          onTap: () => _openSummary(context),
        );
      case HomeDashboardState.activeTour:
        if (snapshot.isTourPaused) {
          return (
            label: l10n.homeTourPausedLabel,
            title: snapshot.currentExhibitName ?? l10n.homeTourPausedTitle,
            subtitle: 'Resume your live Horus-Bot tour.',
            icon: Icons.pause_circle_outline_rounded,
            onTap: () => _openTourFlow(context, snapshot),
          );
        }
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
  }

  // ignore: unused_element
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
    return parts.join(' • ');
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

  List<HomeQuickActionItem> _buildQuickActions(
    HomeSnapshot snapshot,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    if (!snapshot.isLoggedIn) {
      return [
        HomeQuickActionItem(
          icon: Icons.login,
          label: l10n.login,
          subtitle: l10n.createOrLoginToPreserve,
          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
        ),
        HomeQuickActionItem(
          icon: Icons.route_outlined,
          label: l10n.tourPlanner,
          subtitle: isArabic
              ? 'جهز مسارك قبل الحجز'
              : 'Plan your route before booking',
          onTap: () => Navigator.pushNamed(context, AppRoutes.tourPlanner),
        ),
        HomeQuickActionItem(
          icon: Icons.museum_outlined,
          label: l10n.exhibits,
          subtitle: l10n.homeExploreArtifacts,
          onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
        ),
        HomeQuickActionItem(
          icon: Icons.confirmation_number_outlined,
          label: l10n.buyTickets,
          subtitle: isArabic
              ? 'اشتر تذاكر المتحف وجولة الروبوت'
              : 'Purchase museum and robot tour tickets',
          onTap: () => Navigator.pushNamed(context, AppRoutes.buyTickets),
        ),
      ];
    }

    if (snapshot.dashboardState == HomeDashboardState.paymentPending) {
      return [
        HomeQuickActionItem(
          icon: Icons.confirmation_number_outlined,
          label: l10n.myTickets,
          subtitle: 'View payment status and counter instructions',
          onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets),
        ),
        HomeQuickActionItem(
          icon: Icons.museum_outlined,
          label: l10n.exhibits,
          subtitle: l10n.homeExploreArtifacts,
          onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
        ),
      ];
    }

    if (snapshot.isLoggedInWithoutTickets) {
      final actions = <HomeQuickActionItem>[
        HomeQuickActionItem(
          icon: Icons.route_outlined,
          label: l10n.tourPlanner,
          subtitle: isArabic
              ? 'جهز مسارك قبل الحجز'
              : 'Plan your route before booking',
          onTap: () => Navigator.pushNamed(context, AppRoutes.tourPlanner),
        ),
        HomeQuickActionItem(
          icon: Icons.museum_outlined,
          label: l10n.exhibits,
          subtitle: l10n.homeExploreArtifacts,
          onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
        ),
      ];
      if (snapshot.hasTicketHistory) {
        actions.add(
          HomeQuickActionItem(
            icon: Icons.confirmation_number_outlined,
            label: l10n.myTickets,
            subtitle: isArabic
                ? '\u0639\u0631\u0636 \u062d\u0627\u0644\u0629 \u0627\u0644\u062a\u0630\u0627\u0643\u0631 \u0648\u0627\u0644\u0633\u062c\u0644'
                : 'View ticket status and history',
            onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets),
          ),
        );
      }
      if (snapshot.hasCompletedTourHistory) {
        actions.add(
          HomeQuickActionItem(
            icon: Icons.photo_library_outlined,
            label: isArabic
                ? '\u0627\u0644\u0630\u0643\u0631\u064a\u0627\u062a'
                : 'Memories',
            subtitle: isArabic
                ? '\u0627\u0633\u062a\u0639\u062f \u0644\u062d\u0638\u0627\u062a \u062c\u0648\u0644\u0627\u062a\u0643 \u0627\u0644\u0633\u0627\u0628\u0642\u0629'
                : 'Revisit moments from completed tours',
            onTap: () => Navigator.pushNamed(context, AppRoutes.memories),
          ),
        );
      }
      if (actions.length == 3) {
        actions.insert(
          1,
          HomeQuickActionItem(
            icon: Icons.confirmation_number_outlined,
            label: l10n.buyTickets,
            subtitle: isArabic
                ? '\u062e\u0637\u0637 \u0644\u0632\u064a\u0627\u0631\u0629 \u0647\u0648\u0631\u0633-\u0628\u0648\u062a \u0623\u062e\u0631\u0649'
                : 'Plan another Horus-Bot visit',
            onTap: () => Navigator.pushNamed(context, AppRoutes.buyTickets),
          ),
        );
      }
      return actions;
    }

    if (snapshot.isActiveTourState) {
      return [
        HomeQuickActionItem(
          icon: Icons.map_outlined,
          label: l10n.map,
          subtitle: 'See where you and Horus are now',
          onTap: () => _openMap(context),
        ),
        HomeQuickActionItem(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Ask Horus',
          subtitle: 'Ask about the current stop or route',
          onTap: () => _openChat(context),
        ),
        HomeQuickActionItem(
          icon: Icons.photo_library_outlined,
          label: isArabic ? 'الذكريات' : 'Memories',
          subtitle: isArabic
              ? 'شاهد لحظات جولتك الحالية'
              : 'Review moments from your current tour',
          onTap: () => Navigator.pushNamed(context, AppRoutes.memories),
        ),
        HomeQuickActionItem(
          icon: Icons.museum_outlined,
          label: l10n.exhibits,
          subtitle: l10n.homeExploreArtifacts,
          onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
        ),
      ];
    }

    if (snapshot.dashboardState == HomeDashboardState.tourCompleted) {
      return [
        HomeQuickActionItem(
          icon: Icons.summarize_outlined,
          label: 'Summary',
          subtitle: 'Review the stops and highlights from your tour',
          onTap: () => _openSummary(context),
        ),
        HomeQuickActionItem(
          icon: Icons.photo_library_outlined,
          label: isArabic ? 'Ø§Ù„Ø°ÙƒØ±ÙŠØ§Øª' : 'Memories',
          subtitle: 'Revisit photos and saved tour moments',
          onTap: () => Navigator.pushNamed(context, AppRoutes.memories),
        ),
        HomeQuickActionItem(
          icon: Icons.rate_review_outlined,
          label: l10n.feedback,
          subtitle: 'Tell us how your Horus-Bot visit felt',
          onTap: () => Navigator.pushNamed(context, AppRoutes.feedback),
        ),
        HomeQuickActionItem(
          icon: Icons.emoji_events_outlined,
          label: l10n.achievements,
          subtitle: 'See badges and progress from your visit',
          onTap: () => Navigator.pushNamed(context, AppRoutes.achievements),
        ),
      ];
    }

    if (snapshot.dashboardState == HomeDashboardState.awaitingRobotPairing) {
      return [
        HomeQuickActionItem(
          icon: Icons.qr_code_scanner_rounded,
          label: l10n.homeScanRobotQr,
          subtitle: 'Pair with the Horus-Bot beside you',
          onTap: () => _openRobotPairing(context),
        ),
        HomeQuickActionItem(
          icon: Icons.map_outlined,
          label: l10n.map,
          subtitle: 'Use the map to orient yourself before starting',
          onTap: () => _openMap(context),
        ),
        HomeQuickActionItem(
          icon: Icons.confirmation_number_outlined,
          label: l10n.myTickets,
          subtitle: 'Keep your entry QR and tour ticket handy',
          onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets),
        ),
        HomeQuickActionItem(
          icon: Icons.museum_outlined,
          label: l10n.exhibits,
          subtitle: l10n.homeExploreArtifacts,
          onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
        ),
      ];
    }

    if (snapshot.isTicketReady) {
      return [
        HomeQuickActionItem(
          icon: Icons.qr_code_scanner_rounded,
          label: l10n.homeScanRobotQr,
          subtitle: l10n.homePairWithHorus,
          onTap: () => _openRobotPairing(context),
        ),
        HomeQuickActionItem(
          icon: Icons.confirmation_number_outlined,
          label: l10n.myTickets,
          subtitle: isArabic
              ? 'عرض تذاكر دخول المتحف وجولة الروبوت'
              : 'View your museum entry and robot tour tickets',
          onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets),
        ),
        HomeQuickActionItem(
          icon: Icons.photo_library_outlined,
          label: isArabic ? 'الذكريات' : 'Memories',
          subtitle: isArabic
              ? 'شاهد صور جولتك وذكريات زياراتك السابقة.'
              : 'View your captured tour photos and past visits.',
          onTap: () => Navigator.pushNamed(context, AppRoutes.memories),
        ),
        HomeQuickActionItem(
          icon: Icons.museum_outlined,
          label: l10n.exhibits,
          subtitle: l10n.homeExploreArtifacts,
          onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
        ),
      ];
    }

    if (snapshot.hasTicketHistory || snapshot.hasCompletedTourHistory) {
      return [
        if (snapshot.hasCompletedTourHistory)
          HomeQuickActionItem(
            icon: Icons.photo_library_outlined,
            label: isArabic
                ? '\u0627\u0644\u0630\u0643\u0631\u064a\u0627\u062a'
                : 'Memories',
            subtitle: isArabic
                ? '\u0627\u0633\u062a\u0639\u062f \u0644\u062d\u0638\u0627\u062a \u062c\u0648\u0644\u0627\u062a\u0643 \u0627\u0644\u0633\u0627\u0628\u0642\u0629'
                : 'Revisit moments from completed tours',
            onTap: () => Navigator.pushNamed(context, AppRoutes.memories),
          ),
        if (snapshot.hasTicketHistory)
          HomeQuickActionItem(
            icon: Icons.confirmation_number_outlined,
            label: l10n.myTickets,
            subtitle: isArabic
                ? '\u0639\u0631\u0636 \u062d\u0627\u0644\u0629 \u0627\u0644\u062a\u0630\u0627\u0643\u0631 \u0648\u0627\u0644\u0633\u062c\u0644'
                : 'View ticket status and history',
            onTap: () => Navigator.pushNamed(context, AppRoutes.myTickets),
          ),
        HomeQuickActionItem(
          icon: Icons.confirmation_number_outlined,
          label: l10n.buyTickets,
          subtitle: isArabic
              ? '\u062e\u0637\u0637 \u0644\u0632\u064a\u0627\u0631\u0629 \u0647\u0648\u0631\u0633-\u0628\u0648\u062a \u0623\u062e\u0631\u0649'
              : 'Plan another Horus-Bot visit',
          onTap: () => Navigator.pushNamed(context, AppRoutes.buyTickets),
        ),
        HomeQuickActionItem(
          icon: Icons.museum_outlined,
          label: l10n.exhibits,
          subtitle: l10n.homeExploreArtifacts,
          onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
        ),
      ];
    }

    return [
      HomeQuickActionItem(
        icon: Icons.photo_library_outlined,
        label: isArabic ? 'الذكريات' : 'Memories',
        subtitle: isArabic
            ? 'شاهد صور جولتك وذكريات زياراتك السابقة.'
            : 'View your captured tour photos and past visits.',
        onTap: () => Navigator.pushNamed(context, AppRoutes.memories),
      ),
      HomeQuickActionItem(
        icon: Icons.museum_outlined,
        label: l10n.exhibits,
        subtitle: l10n.homeExploreArtifacts,
        onTap: () => Navigator.pushNamed(context, AppRoutes.exhibits),
      ),
    ];
  }

  String _ticketStatusLine(HomeSnapshot snapshot, AppLocalizations l10n) {
    if (snapshot.dashboardState == HomeDashboardState.paymentPending) {
      return 'Payment pending - pay at the museum counter';
    }
    if (snapshot.dashboardState == HomeDashboardState.tourCompleted) {
      return 'Tour completed - summary and memories ready';
    }
    if (!snapshot.hasCompleteTicketBundle) {
      return l10n.homeNoTicketsYet;
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

  String _heroSubtitle(HomeSnapshot snapshot) {
    final language = Localizations.localeOf(context).languageCode;
    switch (snapshot.dashboardState) {
      case HomeDashboardState.staffBlocked:
        return 'Staff accounts continue on the Horus-Bot website portal.';
      case HomeDashboardState.guest:
        return language == 'ar'
            ? 'Ø®Ø·Ø· Ù„Ø±Ø­Ù„ØªÙƒ ÙÙŠ Ø§Ù„Ù…ØªØ­Ù Ù‚Ø¨Ù„ Ø§Ù„Ø²ÙŠØ§Ø±Ø©.'
            : 'Explore the museum and plan your Horus-Bot visit.';
      case HomeDashboardState.loggedInNoTickets:
        return 'Welcome, ${snapshot.userName}. Plan your Horus-Bot visit.';
      case HomeDashboardState.paymentPending:
        return 'Payment is pending. Your QR activates after counter confirmation.';
      case HomeDashboardState.ticketReady:
        return 'Ticket ready. Keep your QR handy for museum entry.';
      case HomeDashboardState.awaitingRobotPairing:
        return 'Find your Horus-Bot and scan its QR to begin.';
      case HomeDashboardState.activeTour:
        return language == 'ar'
            ? 'Ø§ØªØ¨Ø¹ Ø­ÙˆØ±Ø³ Ø®Ù„Ø§Ù„ Ø¬ÙˆÙ„ØªÙƒ Ø§Ù„Ù…Ø¨Ø§Ø´Ø±Ø© ÙÙŠ Ø§Ù„Ù…ØªØ­Ù.'
            : 'Follow Horus through your live museum tour.';
      case HomeDashboardState.tourCompleted:
        return 'Your Horus-Bot tour is complete. Relive the visit.';
    }
    // ignore: dead_code
    if (snapshot.isActiveTourState) {
      return language == 'ar'
          ? 'اتبع حورس خلال جولتك المباشرة في المتحف.'
          : 'Follow Horus through your live museum tour.';
    }
    if (snapshot.isTicketReady) {
      return language == 'ar'
          ? 'جولتك مع Horus-Bot جاهزة.'
          : 'Your Horus-Bot tour is ready.';
    }
    if (snapshot.isLoggedIn) {
      return language == 'ar'
          ? 'مرحبا، ${snapshot.userName}. جهز زيارتك مع Horus-Bot.'
          : 'Welcome, ${snapshot.userName}. Prepare your Horus-Bot visit.';
    }
    return language == 'ar'
        ? 'خطط لرحلتك في المتحف قبل الزيارة.'
        : 'Plan your museum journey before your visit.';
  }

  ({
    String title,
    String subtitle,
    String statusLine,
    String primaryLabel,
    String secondaryLabel,
    VoidCallback onPrimary,
    VoidCallback onSecondary,
  })
  _primaryActionCardModel(
    BuildContext context,
    HomeSnapshot snapshot,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    switch (snapshot.dashboardState) {
      case HomeDashboardState.staffBlocked:
        return (
          title: 'Staff account detected',
          subtitle: AuthProvider.staffAccountMessage,
          statusLine: 'Visitor app access is blocked for staff roles',
          primaryLabel: l10n.login,
          secondaryLabel: l10n.about,
          onPrimary: () => Navigator.pushNamed(context, AppRoutes.login),
          onSecondary: () =>
              Navigator.pushNamed(context, AppRoutes.projectInfo),
        );
      case HomeDashboardState.guest:
        return (
          title: 'Explore before you book',
          subtitle:
              'Create an account or log in to save tickets, tours, and memories.',
          statusLine: l10n.homeNoTicketsYet,
          primaryLabel: l10n.buyTickets,
          secondaryLabel: l10n.login,
          onPrimary: () => Navigator.pushNamed(context, AppRoutes.buyTickets),
          onSecondary: () => Navigator.pushNamed(context, AppRoutes.login),
        );
      case HomeDashboardState.loggedInNoTickets:
        return (
          title: 'Plan your museum visit',
          subtitle:
              'Choose museum entry and a Horus-Bot tour package before your visit.',
          statusLine: l10n.homeNoTicketsYet,
          primaryLabel: l10n.buyTickets,
          secondaryLabel: l10n.exhibits,
          onPrimary: () => Navigator.pushNamed(context, AppRoutes.buyTickets),
          onSecondary: () => Navigator.pushNamed(context, AppRoutes.exhibits),
        );
      case HomeDashboardState.paymentPending:
        return (
          title: 'Payment pending',
          subtitle:
              'Please pay at the museum counter. Your QR code and robot pairing unlock after cashier confirmation.',
          statusLine: _ticketStatusLine(snapshot, l10n),
          primaryLabel: l10n.myTickets,
          secondaryLabel: l10n.exhibits,
          onPrimary: () => Navigator.pushNamed(context, AppRoutes.myTickets),
          onSecondary: () => Navigator.pushNamed(context, AppRoutes.exhibits),
        );
      case HomeDashboardState.ticketReady:
        return (
          title: 'Ticket ready',
          subtitle:
              'Your museum entry and Horus-Bot tour are confirmed. Keep the QR ready for entry.',
          statusLine: _ticketStatusLine(snapshot, l10n),
          primaryLabel: l10n.myTickets,
          secondaryLabel: l10n.homeScanRobotQr,
          onPrimary: () => Navigator.pushNamed(context, AppRoutes.myTickets),
          onSecondary: () => _openRobotPairing(context),
        );
      case HomeDashboardState.awaitingRobotPairing:
        return (
          title: 'Find your Horus-Bot',
          subtitle:
              'When you are beside the robot, scan its QR to pair and start the tour.',
          statusLine: _ticketStatusLine(snapshot, l10n),
          primaryLabel: l10n.homeScanRobotQr,
          secondaryLabel: l10n.map,
          onPrimary: () => _openRobotPairing(context),
          onSecondary: () => _openMap(context),
        );
      case HomeDashboardState.activeTour:
        return (
          title: snapshot.currentExhibitName ?? l10n.homeContinueTourAction,
          subtitle: snapshot.nextStopName == null
              ? l10n.homeAskOrContinueSubtitle
              : 'Next stop: ${snapshot.nextStopName}',
          statusLine: _ticketStatusLine(snapshot, l10n),
          primaryLabel: snapshot.isTourPaused
              ? l10n.resume
              : l10n.homeContinueTourAction,
          secondaryLabel: l10n.map,
          onPrimary: () => _openTourFlow(context, snapshot),
          onSecondary: () => _openMap(context),
        );
      case HomeDashboardState.tourCompleted:
        return (
          title: 'Tour completed',
          subtitle:
              'Review your route, revisit memories, share feedback, and keep your achievements.',
          statusLine: _ticketStatusLine(snapshot, l10n),
          primaryLabel: 'View Summary',
          secondaryLabel: 'Book another tour',
          onPrimary: () => _openSummary(context),
          onSecondary: () => Navigator.pushNamed(context, AppRoutes.buyTickets),
        );
    }

    // ignore: dead_code
    if (snapshot.isActiveTourState) {
      return (
        title: snapshot.currentExhibitName ?? l10n.homeContinueTourAction,
        subtitle: l10n.homeAskOrContinueSubtitle,
        statusLine: _ticketStatusLine(snapshot, l10n),
        primaryLabel: l10n.homeContinueTourAction,
        secondaryLabel: l10n.exhibits,
        onPrimary: () => _openTourFlow(context, snapshot),
        onSecondary: () => Navigator.pushNamed(context, AppRoutes.exhibits),
      );
    }

    if (snapshot.isTicketReady) {
      return (
        title: l10n.homeMuseumTicketReadyTitle,
        subtitle: l10n.homeConnectTourSubtitle,
        statusLine: _ticketStatusLine(snapshot, l10n),
        primaryLabel: l10n.homeScanRobotQr,
        secondaryLabel: l10n.myTickets,
        onPrimary: () => _openRobotPairing(context),
        onSecondary: () => _openTickets(context, snapshot),
      );
    }

    return (
      title: l10n.homePlanVisitTitle,
      subtitle: l10n.homePlanVisitSubtitle,
      statusLine: _ticketStatusLine(snapshot, l10n),
      primaryLabel: snapshot.isLoggedIn ? l10n.buyTickets : l10n.login,
      secondaryLabel: snapshot.isLoggedIn ? l10n.tourPlanner : l10n.buyTickets,
      onPrimary: () => snapshot.isLoggedIn
          ? Navigator.pushNamed(context, AppRoutes.buyTickets)
          : Navigator.pushNamed(context, AppRoutes.login),
      onSecondary: () => snapshot.isLoggedIn
          ? Navigator.pushNamed(context, AppRoutes.tourPlanner)
          : Navigator.pushNamed(context, AppRoutes.buyTickets),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesModel>();
    final isArabic = prefs.language == 'ar';
    final l10n = AppLocalizations.of(context)!;
    final exhibits = context.watch<ExhibitProvider>().exhibits;
    _maybeRestoreActiveSession();
    final snapshot = _snapshot(context, exhibits);
    final status = _statusModel(context, snapshot, isArabic);
    final heroHeight = MediaQuery.sizeOf(context).height * 0.56;
    final contextualArtifact = _contextualArtifact(snapshot, l10n);
    final canShowRobotQr =
        snapshot.isTicketReady || snapshot.robotStatus == HomeRobotStatus.error;

    final quickActions = _buildQuickActions(snapshot, l10n, isArabic);
    final primaryCard = _primaryActionCardModel(
      context,
      snapshot,
      l10n,
      isArabic,
    );

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
                  padding: const EdgeInsets.only(bottom: 144),
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
                              subtitle: _heroSubtitle(snapshot),
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
                      const SizedBox(height: AppSpacing.sectionGap),
                      if (snapshot.shouldShowStats) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: HomeStatsRow(
                            items: _tourStats(snapshot, l10n),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: _PrimaryActionCard(
                          isArabic: isArabic,
                          title: primaryCard.title,
                          subtitle: primaryCard.subtitle,
                          statusLine: primaryCard.statusLine,
                          primaryLabel: primaryCard.primaryLabel,
                          secondaryLabel: primaryCard.secondaryLabel,
                          onPrimary: primaryCard.onPrimary,
                          onSecondary: primaryCard.onSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel(label: l10n.homeQuickActions),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeQuickActionsGrid(items: quickActions),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _SectionLabel(
                        label: _artifactSectionLabel(snapshot, l10n),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: HomeFeaturedArtifactCard(
                          key: ValueKey(
                            'featured-${contextualArtifact.id}-$_rotationMinuteIndex',
                          ),
                          artifact: contextualArtifact,
                          onTap: () => _openArtifactDetails(
                            context,
                            contextualArtifact,
                            exhibits,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
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
                      const SizedBox(height: AppSpacing.sectionGap),
                      if (snapshot.didYouKnowText.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: HomeInfoCard(
                            key: ValueKey(
                              'did-you-know-$_rotationMinuteIndex-${snapshot.didYouKnowText}',
                            ),
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
                bottom: 104,
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
          padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
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
              const SizedBox(height: 16),
              _TicketStatusPill(label: statusLine, isArabic: isArabic),
              const SizedBox(height: 24),
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
