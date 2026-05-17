import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/robot_tour_ticket.dart';
import '../models/ticket_order.dart';

enum RobotPairingFailureCode {
  invalidQr,
  signInRequired,
  robotTourTicketRequired,
  ambiguousRobotTourTicket,
  robotNotFound,
  robotUnavailable,
  robotBusy,
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
    String? robotTourTicketId,
  }) async {
    final robotId = parseRobotId(scannedCode);
    if (robotId == null) {
      throw const RobotPairingException(RobotPairingFailureCode.invalidQr);
    }
    if (userId.trim().isEmpty) {
      throw const RobotPairingException(RobotPairingFailureCode.signInRequired);
    }

    try {
      final pairableTicket = await _selectPairableRobotTourTicket(
        userId,
        preferredTicketId: robotTourTicketId,
      );
      if (pairableTicket == null) {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotTourTicketRequired,
        );
      }

      final robotTourTicket = pairableTicket.ticket;
      final selectedExhibitIds = _selectedExhibitIds(robotTourTicket);
      final sessionRef = _firestore.collection('tourSessions').doc();
      final sessionId = sessionRef.id;
      final robotRef = _firestore.collection('robots').doc(robotId);
      final robotTicketRef = _firestore
          .collection('robotTourTickets')
          .doc(pairableTicket.documentId);
      final bookingId = robotTourTicket.bookingId ?? '';
      final museumTicketId = robotTourTicket.museumTicketId ?? '';
      if (bookingId.isEmpty || museumTicketId.isEmpty) {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotTourTicketRequired,
        );
      }

      await _firestore.runTransaction((transaction) async {
        final robotTicketSnapshot = await transaction.get(robotTicketRef);
        if (!robotTicketSnapshot.exists) {
          throw const RobotPairingException(
            RobotPairingFailureCode.robotTourTicketRequired,
          );
        }
        final robotTicketData = robotTicketSnapshot.data() ?? {};
        if (!_isUnpairedActiveRobotTicket(robotTicketData, userId)) {
          throw const RobotPairingException(
            RobotPairingFailureCode.robotTourTicketRequired,
          );
        }

        final robotSnapshot = await transaction.get(robotRef);
        if (!robotSnapshot.exists) {
          throw const RobotPairingException(
            RobotPairingFailureCode.robotNotFound,
          );
        }

        final robotData = robotSnapshot.data() ?? {};
        final robotStatus = robotData['status']?.toString();
        final activeSessionId =
            _stringValue(robotData['active_session_id']) ??
            _stringValue(robotData['activeSessionId']);
        final activeUserId =
            _stringValue(robotData['active_user_id']) ??
            _stringValue(robotData['currentUserId']);
        final isOnline =
            _boolValue(robotData['is_online']) ??
            _boolValue(robotData['online']);
        if (robotStatus != 'available' ||
            activeSessionId != null ||
            activeUserId != null) {
          throw RobotPairingException(
            robotStatus == 'paired' ||
                    robotStatus == 'busy' ||
                    robotStatus == 'assigned' ||
                    robotStatus == 'in_tour' ||
                    activeSessionId != null ||
                    activeUserId != null
                ? RobotPairingFailureCode.robotBusy
                : RobotPairingFailureCode.robotUnavailable,
          );
        }
        if (isOnline == false) {
          throw const RobotPairingException(
            RobotPairingFailureCode.robotUnavailable,
          );
        }

        final now = FieldValue.serverTimestamp();

        transaction.set(sessionRef, {
          'session_id': sessionId,
          'userId': userId,
          'booking_id': bookingId,
          'museum_ticket_id': museumTicketId,
          'robot_tour_ticket_id': pairableTicket.documentId,
          'robotId': robotId,
          'status': 'paired',
          'current_exhibit_id': null,
          'current_exhibit_index': 0,
          'selected_exhibits': selectedExhibitIds,
          'route_id': robotTourTicket.routeId,
          'route_title_en': robotTourTicket.routeTitleEn,
          'route_title_ar': robotTourTicket.routeTitleAr,
          'preferred_language': robotTourTicket.languageCode,
          'pace': _paceValue(pairableTicket.data, robotTourTicket),
          'started_at': null,
          'paired_at': now,
          'completed_at': null,
          'created_at': now,
          'updated_at': now,
        });

        transaction.update(robotTicketRef, {
          'status': 'paired',
          'paired_robot_id': robotId,
          'session_id': sessionId,
          'paired_at': now,
          'updated_at': now,
        });

        transaction.update(robotRef, {
          'status': 'assigned',
          'active_session_id': sessionId,
          'active_user_id': userId,
          'active_robot_tour_ticket_id': pairableTicket.documentId,
          'updated_at': now,
        });
      });

      return RobotPairingResult(
        sessionId: sessionId,
        robotId: robotId,
        museumTicketId: museumTicketId,
        robotTourTicketId: pairableTicket.documentId,
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

  Future<_PairableRobotTicket?> _selectPairableRobotTourTicket(
    String userId, {
    String? preferredTicketId,
  ) async {
    final snapshot = await _firestore
        .collection('robotTourTickets')
        .where('userId', isEqualTo: userId)
        .get();
    final tickets = snapshot.docs
        .where((doc) => _isUnpairedActiveRobotTicket(doc.data(), userId))
        .map(
          (doc) => _PairableRobotTicket(
            documentId: doc.id,
            ticket: RobotTourTicket.fromFirestore(doc.id, doc.data()),
            data: doc.data(),
          ),
        )
        .toList();
    if (tickets.isEmpty) return null;

    final preferred = preferredTicketId?.trim();
    if (preferred != null && preferred.isNotEmpty) {
      for (final ticket in tickets) {
        if (ticket.documentId == preferred || ticket.ticket.id == preferred) {
          return ticket;
        }
      }
      return null;
    }

    tickets.sort((a, b) => _tourStartValue(a).compareTo(_tourStartValue(b)));
    if (tickets.length > 1 &&
        _tourStartValue(
          tickets[0],
        ).isAtSameMomentAs(_tourStartValue(tickets[1]))) {
      throw const RobotPairingException(
        RobotPairingFailureCode.ambiguousRobotTourTicket,
      );
    }
    return tickets.first;
  }

  bool _isUnpairedActiveRobotTicket(
    Map<String, dynamic> data,
    String userId,
  ) {
    return data['userId'] == userId &&
        data['status'] == TicketStatus.active.name &&
        _stringValue(data['paired_robot_id']) == null &&
        _stringValue(data['session_id']) == null;
  }

  DateTime _tourStartValue(_PairableRobotTicket pairable) {
    final ticket = pairable.ticket;
    final visitDate = ticket.visitDate;
    if (visitDate == null) return ticket.purchasedAt;
    final parts = ticket.timeSlot?.split(':');
    final hour = parts == null || parts.isEmpty ? 0 : int.tryParse(parts[0]);
    final minute = parts == null || parts.length < 2
        ? 0
        : int.tryParse(parts[1]);
    return DateTime(
      visitDate.year,
      visitDate.month,
      visitDate.day,
      hour ?? 0,
      minute ?? 0,
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

  String _paceValue(Map<String, dynamic> data, RobotTourTicket ticket) {
    return _stringValue(data['pace']) ??
        ticket.personalizedTourConfig?.pace.name ??
        TourPace.normal.name;
  }

  String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  bool? _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
    return null;
  }
}

class _PairableRobotTicket {
  const _PairableRobotTicket({
    required this.documentId,
    required this.ticket,
    required this.data,
  });

  final String documentId;
  final RobotTourTicket ticket;
  final Map<String, dynamic> data;
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
