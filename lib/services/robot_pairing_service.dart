import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/museum_ticket.dart';
import '../models/robot_tour_ticket.dart';
import '../models/ticket_order.dart';

enum RobotPairingFailureCode {
  invalidQr,
  signInRequired,
  robotTourTicketRequired,
  robotNotFound,
  robotUnavailable,
  permissionDenied,
  network,
  unknown,
}

class RobotPairingService {
  RobotPairingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<RobotPairingResult> pairRobot({
    required String userId,
    required String scannedCode,
  }) async {
    final robotId = parseRobotId(scannedCode);
    if (robotId == null) {
      throw const RobotPairingException(RobotPairingFailureCode.invalidQr);
    }
    if (userId.trim().isEmpty) {
      throw const RobotPairingException(RobotPairingFailureCode.signInRequired);
    }

    try {
      final museumTicket = await _activeMuseumTicketForUser(userId);
      final robotTourTicket = await _activeRobotTourTicketForUser(
        userId,
        museumTicket,
      );
      if (museumTicket == null || robotTourTicket == null) {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotTourTicketRequired,
        );
      }

      final selectedExhibitIds = _selectedExhibitIds(robotTourTicket);
      final sessionRef = _firestore.collection('tourSessions').doc();
      final sessionId = sessionRef.id;
      final robotRef = _firestore.collection('robots').doc(robotId);

      await _firestore.runTransaction((transaction) async {
        final robotSnapshot = await transaction.get(robotRef);
        if (!robotSnapshot.exists) {
          throw const RobotPairingException(
            RobotPairingFailureCode.robotNotFound,
          );
        }

        final robotData = robotSnapshot.data() ?? {};
        if (robotData['status'] != 'available') {
          throw const RobotPairingException(
            RobotPairingFailureCode.robotUnavailable,
          );
        }

        transaction.set(sessionRef, {
          'sessionId': sessionId,
          'userId': userId,
          'robotId': robotId,
          'museumTicketId': museumTicket.id,
          'robotTourTicketId': robotTourTicket.id,
          'selectedExhibitIds': selectedExhibitIds,
          'currentExhibitId': null,
          'nextExhibitId': selectedExhibitIds.isEmpty
              ? null
              : selectedExhibitIds.first,
          'visitedExhibitIds': const <String>[],
          'status': 'ready',
          'robotState': 'waiting',
          'userDistanceFromRobot': null,
          'startedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'completedAt': null,
        });

        transaction.update(robotRef, {
          'status': 'paired',
          'activeSessionId': sessionId,
          'currentUserId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return RobotPairingResult(
        sessionId: sessionId,
        robotId: robotId,
        museumTicketId: museumTicket.id,
        robotTourTicketId: robotTourTicket.id,
        selectedExhibitIds: selectedExhibitIds,
        nextExhibitId: selectedExhibitIds.isEmpty
            ? null
            : selectedExhibitIds.first,
      );
    } on RobotPairingException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const RobotPairingException(
          RobotPairingFailureCode.permissionDenied,
        );
      }
      if (e.code == 'unavailable' ||
          e.code == 'deadline-exceeded' ||
          e.code == 'network-request-failed') {
        throw const RobotPairingException(RobotPairingFailureCode.network);
      }
      throw const RobotPairingException(RobotPairingFailureCode.unknown);
    }
  }

  String? parseRobotId(String value) {
    final trimmed = value.trim();
    final match = RegExp(r'ROBOT-HORUS-[A-Za-z0-9_-]+').firstMatch(trimmed);
    return match?.group(0);
  }

  Future<MuseumTicket?> _activeMuseumTicketForUser(String userId) async {
    final snapshot = await _firestore
        .collection('museumTickets')
        .where('userId', isEqualTo: userId)
        .get();
    final tickets = snapshot.docs
        .map((doc) => MuseumTicket.fromFirestore(doc.id, doc.data()))
        .where((ticket) => ticket.status == TicketStatus.active)
        .toList();
    if (tickets.isEmpty) return null;
    tickets.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return tickets.first;
  }

  Future<RobotTourTicket?> _activeRobotTourTicketForUser(
    String userId,
    MuseumTicket? museumTicket,
  ) async {
    if (museumTicket == null) return null;
    final snapshot = await _firestore
        .collection('robotTourTickets')
        .where('userId', isEqualTo: userId)
        .get();
    final tickets = snapshot.docs
        .map((doc) => RobotTourTicket.fromFirestore(doc.id, doc.data()))
        .where((ticket) => ticket.status == TicketStatus.active)
        .toList();
    if (tickets.isEmpty) return null;

    for (final ticket in tickets) {
      final robotLinksMuseum =
          ticket.museumTicketId != null &&
          ticket.museumTicketId == museumTicket.id;
      final museumLinksRobot =
          museumTicket.robotTourTicketId != null &&
          museumTicket.robotTourTicketId == ticket.id;
      if (robotLinksMuseum || museumLinksRobot) return ticket;
    }

    return tickets.firstWhere(
      (ticket) =>
          ticket.museumTicketId == null &&
          museumTicket.robotTourTicketId == null,
      orElse: () => tickets.first,
    );
  }

  List<String> _selectedExhibitIds(RobotTourTicket ticket) {
    if (ticket.tourType == RobotTourType.personalized) {
      final selected = ticket.personalizedTourConfig?.selectedExhibitIds;
      if (selected != null && selected.isNotEmpty) return selected;
    }

    final route = ticket.standardTourConfig?.routeExhibitIds;
    if (route != null && route.isNotEmpty) return route;

    final selectedArtifactIds = ticket.selectedArtifactIds;
    if (selectedArtifactIds != null && selectedArtifactIds.isNotEmpty) {
      return selectedArtifactIds;
    }

    return const [];
  }
}

class RobotPairingResult {
  final String sessionId;
  final String robotId;
  final String museumTicketId;
  final String robotTourTicketId;
  final List<String> selectedExhibitIds;
  final String? nextExhibitId;

  const RobotPairingResult({
    required this.sessionId,
    required this.robotId,
    required this.museumTicketId,
    required this.robotTourTicketId,
    required this.selectedExhibitIds,
    required this.nextExhibitId,
  });
}

class RobotPairingException implements Exception {
  final RobotPairingFailureCode code;

  const RobotPairingException(this.code);
}
