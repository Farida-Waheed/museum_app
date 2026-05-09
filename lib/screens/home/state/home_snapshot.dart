import 'package:flutter/material.dart';

enum HomeRobotStatus {
  disconnected,
  connected,
  speaking,
  moving,
  waiting,
  paused,
  error,
}

class HomeFeaturedArtifact {
  const HomeFeaturedArtifact({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.contextHint,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageAsset;
  final String contextHint;
}

class HomeMapPreviewData {
  const HomeMapPreviewData({
    required this.isLive,
    required this.horusPosition,
    required this.userPosition,
    required this.hint,
  });

  final bool isLive;
  final Offset horusPosition;
  final Offset userPosition;
  final String hint;
}

class HomeSnapshot {
  const HomeSnapshot({
    required this.userName,
    required this.isLoggedIn,
    required this.hasValidMuseumTicket,
    required this.hasRobotTourTicket,
    required this.hasRobotTourEligibility,
    required this.ticketCount,
    required this.nextTicketQrAvailable,
    required this.isRobotConnected,
    required this.connectedRobotId,
    required this.connectedRobotName,
    required this.robotStatus,
    required this.robotStatusLabel,
    required this.robotBatteryPercent,
    required this.lastRobotSyncTime,
    required this.hasActiveTour,
    required this.isTourPaused,
    required this.isTourCompleted,
    required this.currentExhibitName,
    required this.nextStopName,
    required this.nextStopLocation,
    required this.estimatedTimeToNextStop,
    required this.visitedCount,
    required this.totalExhibits,
    required this.tourDurationMinutes,
    required this.tourProgressPercent,
    required this.featuredArtifact,
    required this.didYouKnowText,
    required this.smallUpdateCard,
    required this.mapPreview,
    required this.isLiveMapAvailable,
  });

  final String userName;
  final bool isLoggedIn;

  final bool hasValidMuseumTicket;
  final bool hasRobotTourTicket;
  final bool hasRobotTourEligibility;
  final int ticketCount;
  final bool nextTicketQrAvailable;

  final bool isRobotConnected;
  final String? connectedRobotId;
  final String connectedRobotName;
  final HomeRobotStatus robotStatus;
  final String robotStatusLabel;
  final int? robotBatteryPercent;
  final DateTime? lastRobotSyncTime;

  final bool hasActiveTour;
  final bool isTourPaused;
  final bool isTourCompleted;
  final String? currentExhibitName;
  final String? nextStopName;
  final String? nextStopLocation;
  final int? estimatedTimeToNextStop;
  final int visitedCount;
  final int totalExhibits;
  final int tourDurationMinutes;
  final double tourProgressPercent;

  final HomeFeaturedArtifact featuredArtifact;
  final String didYouKnowText;
  final String? smallUpdateCard;

  final HomeMapPreviewData mapPreview;
  final bool isLiveMapAvailable;

  bool get hasAnyTicket => hasValidMuseumTicket || hasRobotTourTicket;
  bool get shouldShowStats => hasActiveTour || isTourPaused || isTourCompleted;
}
