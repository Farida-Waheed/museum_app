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
  }) {
    final hasSessionTourContext =
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

    final visitedCount = tourProvider.visitedExhibitIds.length;
    final totalExhibits = exhibits.length;
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
    final ticketCount =
        ticketProvider.museumTickets.length +
        ticketProvider.robotTourTickets.length;
    final connected = sessionProvider.isRobotConnected;

    final featuredArtifact = demoService.getFeaturedArtifact(
      exhibits: exhibits,
      lang: lang,
      preferredExhibitId: currentExhibit?.id,
    );
    final didYouKnowText = demoService.getDidYouKnow(lang);
    final smallUpdateCard = demoService.getMuseumUpdate(lang);
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
      ticketCount: ticketCount,
      nextTicketQrAvailable: ticketProvider.hasTickets,
      isRobotConnected: connected,
      connectedRobotId: connected ? 'HORUS-01' : null,
      connectedRobotName: 'Horus-Bot',
      robotStatus: robotStatus,
      robotStatusLabel: _robotStatusLabel(lang, robotStatus),
      robotBatteryPercent: connected ? 87 : null,
      lastRobotSyncTime: connected ? DateTime.now() : null,
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
}
