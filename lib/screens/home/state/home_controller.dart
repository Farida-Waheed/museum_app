import '../../../models/app_session_provider.dart' as app;
import '../../../models/auth_provider.dart';
import '../../../models/exhibit.dart';
import '../../../models/ticket_provider.dart';
import '../../../models/tour_provider.dart';
import 'home_demo_service.dart';
import 'home_snapshot.dart';

class HomeController {
  const HomeController({this.demoService = const HomeDemoService()});

  final HomeDemoService demoService;

  HomeSnapshot buildSnapshot({
    required AuthProvider authProvider,
    required TicketProvider ticketProvider,
    required app.AppSessionProvider sessionProvider,
    required TourProvider tourProvider,
    required List<Exhibit> exhibits,
    required String lang,
    required int didYouKnowIndex,
    required int featuredArtifactIndex,
  }) {
    final hasSessionTourContext =
        sessionProvider.isRobotConnected ||
        sessionProvider.isInActiveTour ||
        sessionProvider.isTourPaused ||
        sessionProvider.isTourCompleted;
    final currentExhibit = _findExhibit(
      exhibits: exhibits,
      exhibitId: hasSessionTourContext
          ? (sessionProvider.currentExhibitId ?? tourProvider.currentExhibitId)
          : null,
    );
    final nextExhibit = _findExhibit(
      exhibits: exhibits,
      exhibitId: hasSessionTourContext
          ? (sessionProvider.nextExhibitId ?? tourProvider.nextExhibitId)
          : null,
    );

    final visitedCount = sessionProvider.visitedExhibitIds.isNotEmpty
        ? sessionProvider.visitedExhibitIds.length
        : tourProvider.visitedExhibitIds.length;
    final routeCount = sessionProvider.selectedExhibitIds.isNotEmpty
        ? sessionProvider.selectedExhibitIds.length
        : tourProvider.selectedExhibitIds.length;
    final totalExhibits = routeCount > 0 ? routeCount : exhibits.length;
    final rawProgress = tourProvider.progress > 0
        ? tourProvider.progress
        : (totalExhibits == 0 ? 0.0 : visitedCount / totalExhibits);

    final robotStatus = _mapRobotStatus(sessionProvider, tourProvider);
    final hasActiveTour = sessionProvider.isInActiveTour;
    final isPaused = sessionProvider.isTourPaused;
    final isCompleted = sessionProvider.isTourCompleted;
    final hasValidMuseumTicket = ticketProvider.hasValidMuseumEntryEntitlement;
    final hasRobotTourTicket = ticketProvider.hasValidRobotTourEntitlement;
    final hasRobotTourEligibility = ticketProvider.hasValidRobotTourEligibility;
    final connected = sessionProvider.isRobotConnected;
    final hasPendingPayment =
        ticketProvider.museumTickets.any(
          (ticket) => _isPaymentPending(ticket.paymentStatus),
        ) ||
        ticketProvider.robotTourTickets.any(
          (ticket) => _isPaymentPending(ticket.paymentStatus),
        );
    final isAwaitingRobotPairing =
        hasRobotTourEligibility &&
        !connected &&
        !hasActiveTour &&
        !isPaused &&
        !isCompleted &&
        sessionProvider.appUsageMode == app.AppUsageMode.visiting;
    final ticketCount =
        ticketProvider.museumTickets.length +
        ticketProvider.robotTourTickets.length;

    final featuredArtifact = demoService.getFeaturedArtifact(
      exhibits: exhibits,
      lang: lang,
      preferredExhibitId: currentExhibit?.id,
      fallbackIndex: featuredArtifactIndex,
    );
    final didYouKnowText = _buildDidYouKnow(
      exhibits: exhibits,
      lang: lang,
      index: didYouKnowIndex,
      currentExhibit: hasSessionTourContext ? currentExhibit : null,
      activeTour: hasActiveTour || isPaused,
    );
    const String? smallUpdateCard = null;
    final mapPreview = demoService.getMapPreview(
      isRobotConnected: connected,
      hasActiveTour: hasActiveTour,
      lang: lang,
    );

    return HomeSnapshot(
      userName:
          authProvider.currentUser?.name ?? (lang == 'ar' ? 'زائر' : 'Guest'),
      isLoggedIn: authProvider.isLoggedIn,
      hasValidMuseumTicket: hasValidMuseumTicket,
      hasRobotTourTicket: hasRobotTourTicket,
      hasRobotTourEligibility: hasRobotTourEligibility,
      hasTicketHistory: ticketProvider.hasTicketHistory,
      hasCompletedTourHistory:
          ticketProvider.hasCompletedTourHistory || isCompleted,
      hasPendingPayment: hasPendingPayment,
      isStaffBlocked:
          authProvider.errorMessage == AuthProvider.staffAccountMessage,
      isAwaitingRobotPairing: isAwaitingRobotPairing,
      ticketCount: ticketCount,
      nextTicketQrAvailable: ticketProvider.hasValidMuseumEntryEntitlement,
      isRobotConnected: connected,
      connectedRobotId: connected ? sessionProvider.connectedRobotId : null,
      connectedRobotName: 'Horus-Bot',
      robotStatus: robotStatus,
      robotStatusLabel: _robotStatusLabel(lang, robotStatus),
      robotBatteryPercent: null,
      lastRobotSyncTime: sessionProvider.lastRobotEventAt,
      hasActiveTour: hasActiveTour,
      isTourPaused: isPaused,
      isTourCompleted: isCompleted,
      currentExhibitName: currentExhibit == null
          ? null
          : (lang == 'ar' ? currentExhibit.nameAr : currentExhibit.nameEn),
      nextStopName: nextExhibit == null
          ? null
          : (lang == 'ar' ? nextExhibit.nameAr : nextExhibit.nameEn),
      nextStopLocation: nextExhibit == null
          ? null
          : (lang == 'ar' ? 'القاعة الذهبية' : 'Golden Hall'),
      estimatedTimeToNextStop: hasActiveTour
          ? _estimatedMinutes(tourProvider)
          : null,
      visitedCount: visitedCount,
      totalExhibits: totalExhibits,
      tourDurationMinutes: visitedCount == 0 ? 5 : visitedCount * 5,
      tourProgressPercent: rawProgress.clamp(0.0, 1.0),
      featuredArtifact: featuredArtifact,
      didYouKnowText: didYouKnowText,
      smallUpdateCard: smallUpdateCard,
      mapPreview: mapPreview,
      isLiveMapAvailable: connected && (hasActiveTour || isPaused),
    );
  }

  Exhibit? _findExhibit({
    required List<Exhibit> exhibits,
    required String? exhibitId,
  }) {
    if (exhibits.isEmpty) return null;
    if (exhibitId == null) return null;
    for (final exhibit in exhibits) {
      if (exhibit.id == exhibitId) return exhibit;
    }
    return null;
  }

  int _estimatedMinutes(TourProvider provider) {
    final seconds = provider.estimatedTimeToNext;
    if (seconds <= 0) return 5;
    return (seconds / 60).ceil();
  }

  bool _isPaymentPending(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('-', '_');
    return normalized == 'pay_at_counter' ||
        normalized == 'pending' ||
        normalized == 'unpaid' ||
        normalized == 'awaiting_payment';
  }

  HomeRobotStatus _mapRobotStatus(
    app.AppSessionProvider sessionProvider,
    TourProvider tourProvider,
  ) {
    if (sessionProvider.robotConnectionState ==
        app.RobotConnectionState.failed) {
      return HomeRobotStatus.error;
    }
    if (sessionProvider.isTourPaused) {
      return HomeRobotStatus.paused;
    }
    if (!sessionProvider.isRobotConnected) {
      return HomeRobotStatus.disconnected;
    }

    switch (tourProvider.robotState) {
      case RobotState.speaking:
      case RobotState.listening:
      case RobotState.thinking:
        return HomeRobotStatus.speaking;
      case RobotState.moving:
      case RobotState.approaching:
        return HomeRobotStatus.moving;
      case RobotState.waiting:
      case RobotState.idle:
      case RobotState.syncing:
        return HomeRobotStatus.waiting;
      case RobotState.disconnected:
        return HomeRobotStatus.error;
    }
  }

  String _robotStatusLabel(String lang, HomeRobotStatus status) {
    if (lang == 'ar') {
      switch (status) {
        case HomeRobotStatus.disconnected:
          return 'غير متصل';
        case HomeRobotStatus.connected:
          return 'متصل';
        case HomeRobotStatus.speaking:
          return 'يتحدث';
        case HomeRobotStatus.moving:
          return 'يتحرك';
        case HomeRobotStatus.waiting:
          return 'في الانتظار';
        case HomeRobotStatus.paused:
          return 'متوقف مؤقتا';
        case HomeRobotStatus.error:
          return 'خطأ';
      }
    }
    switch (status) {
      case HomeRobotStatus.disconnected:
        return lang == 'ar' ? 'غير متصل' : 'Disconnected';
      case HomeRobotStatus.connected:
        return lang == 'ar' ? 'متصل' : 'Connected';
      case HomeRobotStatus.speaking:
        return lang == 'ar' ? 'يتحدث' : 'Speaking';
      case HomeRobotStatus.moving:
        return lang == 'ar' ? 'يتحرك' : 'Moving';
      case HomeRobotStatus.waiting:
        return lang == 'ar' ? 'في الانتظار' : 'Waiting';
      case HomeRobotStatus.paused:
        return lang == 'ar' ? 'متوقف مؤقتا' : 'Paused';
      case HomeRobotStatus.error:
        return lang == 'ar' ? 'خطأ' : 'Error';
    }
  }

  String _buildDidYouKnow({
    required List<Exhibit> exhibits,
    required String lang,
    required int index,
    Exhibit? currentExhibit,
    bool activeTour = false,
  }) {
    if (exhibits.isEmpty) return '';

    final exhibit = activeTour && currentExhibit != null
        ? currentExhibit
        : exhibits[index % exhibits.length];
    final description = exhibit.getDescription(lang).trim();
    if (description.isEmpty) return '';

    final sentences = description
        .split(RegExp(r'(?<=[.!?؟])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (sentences.isEmpty) return '';

    var fact = sentences.first;

    if (fact.length > 86) {
      fact = fact.substring(0, 86).trimRight();
      final lastSpace = fact.lastIndexOf(' ');
      if (lastSpace > 48) {
        fact = fact.substring(0, lastSpace).trimRight();
      }
      if (!fact.endsWith('.')) fact += '.';
    } else if (!fact.endsWith('.') && !fact.endsWith('...')) {
      fact += '.';
    }

    return fact;
  }
}
