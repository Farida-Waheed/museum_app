import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/museum_ticket.dart';
import '../models/robot_tour_ticket.dart';
import '../models/ticket_order.dart';

enum RobotPairingFailureCode {
  invalidQr,
  signInRequired,
  robotTourTicketRequired,
  robotTourTicketExpired,
  robotTourTicketCompleted,
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
    final parsedRobotId = parseRobotId(scannedCode);
    final rawRobotCode = robotCodeForParsedId(parsedRobotId);
    _logPairing(
      'scan received',
      {
        'rawQr': scannedCode,
        'parsedRobotId': parsedRobotId,
        'rawRobotCode': rawRobotCode,
        'preferredRobotTourTicketId': robotTourTicketId,
      },
    );
    if (parsedRobotId == null) {
      throw const RobotPairingException(RobotPairingFailureCode.invalidQr);
    }
    if (userId.trim().isEmpty) {
      throw const RobotPairingException(RobotPairingFailureCode.signInRequired);
    }

    try {
      final robotCandidates = _robotIdCandidates(parsedRobotId);
      _logPairing(
        'robot candidates',
        {'candidates': robotCandidates.toList(growable: false)},
      );
      final restorablePairing = await _findRestorableInProgressPairing(
        userId: userId,
        robotIdCandidates: robotCandidates,
        preferredTicketId: robotTourTicketId,
      );
      if (restorablePairing != null) {
        _logPairing(
          'restored existing pairing',
          {
            'sessionId': restorablePairing.sessionId,
            'robotId': restorablePairing.robotId,
            'robotTourTicketId': restorablePairing.robotTourTicketId,
            'museumTicketId': restorablePairing.museumTicketId,
          },
        );
        return restorablePairing;
      }

      final pairableTicket = await _selectPairableRobotTourTicket(
        userId,
        preferredTicketId: robotTourTicketId,
      );
      if (pairableTicket == null) {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotTourTicketRequired,
        );
      }
      _logPairing(
        'selected robot tour ticket',
        {
          'robotTourTicketDocId': pairableTicket.documentId,
          'ticketId': pairableTicket.ticket.id,
          'bookingId': pairableTicket.ticket.bookingId,
          'museumTicketId': pairableTicket.ticket.museumTicketId,
          'paymentStatus': pairableTicket.data['payment_status'],
          'status': pairableTicket.data['status'],
        },
      );

      final robotTourTicket = pairableTicket.ticket;
      final selectedExhibitIds = _selectedExhibitIds(robotTourTicket);
      final plannerMetadata = _plannerMetadata(
        ticket: robotTourTicket,
        data: pairableTicket.data,
        selectedExhibitIds: selectedExhibitIds,
      );
      final sessionRef = _firestore.collection('tourSessions').doc();
      final sessionId = sessionRef.id;
      final robotRef = await _robotDocumentRef(parsedRobotId);
      _logPairing(
        'robot lookup result',
        {
          'parsedRobotId': parsedRobotId,
          'selectedRobotDocPath': robotRef?.path,
        },
      );
      if (robotRef == null) {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotNotFound,
        );
      }
      final robotId = robotRef.id;
      final robotCode = rawRobotCode ?? robotCodeForParsedId(robotId) ?? robotId;
      final shortRobotId = parsedRobotId;
      final robotTicketRef = _firestore
          .collection('robotTourTickets')
          .doc(pairableTicket.documentId);
      final bookingId = robotTourTicket.bookingId ?? '';
      final museumTicketId = robotTourTicket.museumTicketId ?? '';
      final currentExhibitId = selectedExhibitIds.isEmpty
          ? null
          : selectedExhibitIds.first;
      final nextExhibitId = selectedExhibitIds.length > 1
          ? selectedExhibitIds[1]
          : null;
      if (bookingId.isEmpty || museumTicketId.isEmpty) {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotTourTicketRequired,
        );
      }
      _logPairing(
        'transaction starting',
        {
          'sessionId': sessionId,
          'robotDocPath': robotRef.path,
          'robotTourTicketPath': robotTicketRef.path,
          'linkedMuseumTicketId': museumTicketId,
          'bookingId': bookingId,
        },
      );

      await _firestore.runTransaction((transaction) async {
        final robotTicketSnapshot = await transaction.get(robotTicketRef);
        if (!robotTicketSnapshot.exists) {
          throw const RobotPairingException(
            RobotPairingFailureCode.robotTourTicketRequired,
          );
        }
        final robotTicketData = robotTicketSnapshot.data() ?? {};
        if (!_isUnpairedActiveRobotTicket(robotTicketData, userId)) {
          throw RobotPairingException(_ticketFailureCode(robotTicketData));
        }
        final museumTicketRef = _firestore
            .collection('museumTickets')
            .doc(museumTicketId);
        final museumTicketSnapshot = await transaction.get(museumTicketRef);
        if (!museumTicketSnapshot.exists ||
            !_isActiveMuseumTicket(museumTicketSnapshot.data(), userId)) {
          throw RobotPairingException(
            _ticketFailureCode(museumTicketSnapshot.data()),
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
        final activeRobotTourTicketId =
            _stringValue(robotData['active_robot_tour_ticket_id']) ??
            _stringValue(robotData['activeRobotTourTicketId']);
        final isConnected = _isRobotConnected(robotData);
        final isActive =
            _boolValue(robotData['is_active']) ??
            _boolValue(robotData['active']) ??
            true;
        final canAcceptPairing =
            robotStatus == 'available' || robotStatus == 'active';
        if (!canAcceptPairing ||
            activeSessionId != null ||
            activeUserId != null ||
            activeRobotTourTicketId != null) {
          throw RobotPairingException(
            robotStatus == 'paired' ||
                    robotStatus == 'busy' ||
                    robotStatus == 'assigned' ||
                    robotStatus == 'in_tour' ||
                    activeSessionId != null ||
                    activeUserId != null ||
                    activeRobotTourTicketId != null
                ? RobotPairingFailureCode.robotBusy
                : RobotPairingFailureCode.robotUnavailable,
          );
        }
        if (!isConnected) {
          throw const RobotPairingException(
            RobotPairingFailureCode.robotUnavailable,
          );
        }
        if (isActive == false) {
          throw const RobotPairingException(
            RobotPairingFailureCode.robotUnavailable,
          );
        }
        if (_boolValue(robotData['mqttEnabled']) == false) {
          _logPairing(
            'mqtt disabled',
            {
              'robotDocPath': robotRef.path,
              'message':
                  'MQTT disabled for robot document; physical robot activation may require Firestore listener.',
            },
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
          'robot_id': robotId,
          'robot_code': robotCode,
          'short_robot_id': shortRobotId,
          'status': 'active',
          'current_exhibit_id': currentExhibitId,
          'current_exhibit_index': 0,
          'next_exhibit_id': nextExhibitId,
          'visitedExhibitIds': currentExhibitId == null
              ? <String>[]
              : <String>[currentExhibitId],
          'selected_exhibits': selectedExhibitIds,
          ...plannerMetadata,
          'route_id': robotTourTicket.routeId,
          'route_title_en': robotTourTicket.routeTitleEn,
          'route_title_ar': robotTourTicket.routeTitleAr,
          'preferred_language': robotTourTicket.languageCode,
          'pace': _paceValue(pairableTicket.data, robotTourTicket),
          'started_at': now,
          'paired_at': now,
          'completed_at': null,
          'created_at': now,
          'updated_at': now,
        });

        transaction.update(robotTicketRef, {
          'status': 'in_progress',
          'paired_robot_id': robotId,
          'session_id': sessionId,
          'paired_at': now,
          'updated_at': now,
        });

        transaction.update(robotRef, {
          'status': 'assigned',
          'active_session_id': sessionId,
          'activeSessionId': sessionId,
          'active_user_id': userId,
          'currentUserId': userId,
          'active_robot_tour_ticket_id': pairableTicket.documentId,
          'activeRobotTourTicketId': pairableTicket.documentId,
          'robotId': robotId,
          'robot_code': robotCode,
          'updated_at': now,
          'updatedAt': now,
        });
      });
      _logPairing(
        'transaction committed',
        {
          'sessionId': sessionId,
          'robotId': robotId,
          'robotTourTicketId': pairableTicket.documentId,
          'museumTicketId': museumTicketId,
        },
      );

      return RobotPairingResult(
        sessionId: sessionId,
        robotId: robotId,
        museumTicketId: museumTicketId,
        robotTourTicketId: pairableTicket.documentId,
        selectedExhibitIds: selectedExhibitIds,
        currentExhibitId: currentExhibitId,
        nextExhibitId: nextExhibitId,
      );
    } on RobotPairingException {
      rethrow;
    } on FirebaseException catch (e) {
      _logPairing(
        'firebase error',
        {
          'code': e.code,
          'message': e.message,
          'plugin': e.plugin,
        },
      );
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

  Future<RobotPairingResult?> _findRestorableInProgressPairing({
    required String userId,
    required Set<String> robotIdCandidates,
    String? preferredTicketId,
  }) async {
    final snapshot = await _firestore
        .collection('robotTourTickets')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: TicketStatus.in_progress.name)
        .get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final pairedRobotId = _stringValue(data['paired_robot_id']);
      final sessionId = _stringValue(data['session_id']);
      final preferred = preferredTicketId?.trim();
      if (preferred != null &&
          preferred.isNotEmpty &&
          preferred != doc.id &&
          preferred != _stringValue(data['id'])) {
        continue;
      }
      if (pairedRobotId == null ||
          !robotIdCandidates.contains(pairedRobotId) ||
          sessionId == null) {
        continue;
      }

      final sessionSnapshot = await _firestore
          .collection('tourSessions')
          .doc(sessionId)
          .get();
      final sessionData = sessionSnapshot.data();
      if (!sessionSnapshot.exists ||
          sessionData == null ||
          sessionData['userId'] != userId ||
          !robotIdCandidates.contains(_stringValue(sessionData['robotId'])) ||
          _stringValue(sessionData['status']) == 'completed' ||
          _stringValue(sessionData['status']) == 'cancelled') {
        continue;
      }

      final ticket = RobotTourTicket.fromFirestore(doc.id, data);
      await _patchSessionPlannerMetadataIfMissing(
        sessionId: sessionId,
        sessionData: sessionData,
        ticket: ticket,
        ticketData: data,
      );
      final selectedExhibitIds = _stringList(
        sessionData['selected_artifact_ids'] ??
            sessionData['selected_exhibits'] ??
            sessionData['selectedExhibitIds'],
      );
      final route = selectedExhibitIds.isEmpty
          ? _selectedExhibitIds(ticket)
          : selectedExhibitIds;
      final currentExhibitId = _stringValue(
        sessionData['current_exhibit_id'] ?? sessionData['currentExhibitId'],
      );
      final nextExhibitId =
          _stringValue(
            sessionData['next_exhibit_id'] ?? sessionData['nextExhibitId'],
          ) ??
          _nextExhibit(route, currentExhibitId);
      return RobotPairingResult(
        sessionId: sessionId,
        robotId: pairedRobotId,
        museumTicketId: ticket.museumTicketId ?? '',
        robotTourTicketId: doc.id,
        selectedExhibitIds: route,
        currentExhibitId:
            currentExhibitId ?? (route.isEmpty ? null : route.first),
        nextExhibitId: nextExhibitId,
      );
    }
    return null;
  }

  String? parseRobotId(String value) {
    final trimmed = value.trim();
    final robotMatch = RegExp(
      r'\bROBOT-(HORUS-[A-Za-z0-9_-]+)\b',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (robotMatch != null) return robotMatch.group(1)!.toUpperCase();
    final directMatch = RegExp(
      r'\bHORUS-[A-Za-z0-9_-]+\b',
      caseSensitive: false,
    ).firstMatch(trimmed);
    return directMatch?.group(0)?.toUpperCase();
  }

  Set<String> _robotIdCandidates(String parsedRobotId) {
    final robotCode = robotCodeForParsedId(parsedRobotId);
    return {
      if (robotCode != null) robotCode,
      parsedRobotId,
    };
  }

  String? robotCodeForParsedId(String? parsedRobotId) {
    final id = parsedRobotId?.trim().toUpperCase();
    if (id == null || id.isEmpty) return null;
    return id.startsWith('ROBOT-') ? id : 'ROBOT-$id';
  }

  Future<DocumentReference<Map<String, dynamic>>?> _robotDocumentRef(
    String parsedRobotId,
  ) async {
    for (final id in _robotIdCandidates(parsedRobotId)) {
      final ref = _firestore.collection('robots').doc(id);
      final snapshot = await ref.get();
      _logPairing(
        'robot candidate checked',
        {
          'path': ref.path,
          'exists': snapshot.exists,
        },
      );
      if (snapshot.exists) return ref;
    }
    return null;
  }

  Future<_PairableRobotTicket?> _selectPairableRobotTourTicket(
    String userId, {
    String? preferredTicketId,
  }) async {
    final snapshot = await _firestore
        .collection('robotTourTickets')
        .where('userId', isEqualTo: userId)
        .get();
    final allTickets = snapshot.docs.where((doc) {
      final preferred = preferredTicketId?.trim();
      if (preferred == null || preferred.isEmpty) return true;
      final data = doc.data();
      return doc.id == preferred || _stringValue(data['id']) == preferred;
    }).toList();
    final tickets = allTickets
        .where((doc) => _isUnpairedActiveRobotTicket(doc.data(), userId))
        .map(
          (doc) => _PairableRobotTicket(
            documentId: doc.id,
            ticket: RobotTourTicket.fromFirestore(doc.id, doc.data()),
            data: doc.data(),
          ),
        )
        .toList();
    if (tickets.isEmpty) {
      await _throwSpecificTicketFailure(allTickets);
      return null;
    }

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

  Future<void> _throwSpecificTicketFailure(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    for (final doc in docs) {
      if (_isCompletedTicketData(doc.data())) {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotTourTicketCompleted,
        );
      }
    }
    for (final doc in docs) {
      if (_isExpiredTicketData(doc.data())) {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotTourTicketExpired,
        );
      }
    }
    for (final doc in docs) {
      final sessionId = _stringValue(doc.data()['session_id']);
      if (sessionId == null) continue;
      final session = await _firestore
          .collection('tourSessions')
          .doc(sessionId)
          .get();
      final status = _stringValue(session.data()?['status']);
      if (status == 'completed') {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotTourTicketCompleted,
        );
      }
    }
  }

  bool _isUnpairedActiveRobotTicket(Map<String, dynamic> data, String userId) {
    return data['userId'] == userId &&
        _isUsableStatus(data['status']) &&
        _isPaymentConfirmed(data['payment_status']) &&
        !_isCompletedTicketData(data) &&
        !_isPastVisitDateTime(
          data['visit_date'] ?? data['visitDate'],
          data['visit_time'] ?? data['timeSlot'],
        ) &&
        _stringValue(data['paired_robot_id']) == null &&
        _stringValue(data['session_id']) == null;
  }

  bool _isActiveMuseumTicket(Map<String, dynamic>? data, String userId) {
    if (data == null) return false;
    return data['userId'] == userId &&
        _isUsableStatus(data['status']) &&
        _isPaymentConfirmed(data['payment_status']) &&
        !_isPastVisitDateTime(
          data['visit_date'] ?? data['visitDate'],
          data['visit_time'] ?? data['timeSlot'],
        );
  }

  bool _isUsableStatus(Object? value) {
    final status = value?.toString().trim().toLowerCase().replaceAll('-', '_');
    return status == TicketStatus.active.name ||
        status == 'valid' ||
        status == 'confirmed';
  }

  bool _isPaymentConfirmed(Object? value) {
    final status = value?.toString().trim().toLowerCase().replaceAll('-', '_');
    return status == 'paid' || status == 'confirmed';
  }

  RobotPairingFailureCode _ticketFailureCode(Map<String, dynamic>? data) {
    if (_isCompletedTicketData(data)) {
      return RobotPairingFailureCode.robotTourTicketCompleted;
    }
    if (_isExpiredTicketData(data)) {
      return RobotPairingFailureCode.robotTourTicketExpired;
    }
    return RobotPairingFailureCode.robotTourTicketRequired;
  }

  bool _isCompletedTicketData(Map<String, dynamic>? data) {
    final status = data?['status']?.toString().trim().toLowerCase();
    return status == TicketStatus.completed.name ||
        status == 'used' ||
        _dateValue(data?['completed_at'] ?? data?['completedAt']) != null;
  }

  bool _isExpiredTicketData(Map<String, dynamic>? data) {
    if (data == null) return false;
    final status = data['status']?.toString().trim().toLowerCase();
    return status == TicketStatus.expired.name ||
        (_isUsableStatus(status) &&
            _isPastVisitDateTime(
              data['visit_date'] ?? data['visitDate'],
              data['visit_time'] ?? data['timeSlot'],
            ));
  }

  bool _isPastVisitDateTime(Object? dateValue, Object? timeValue) {
    final date = _dateValue(dateValue);
    if (date == null) return false;
    final startsAt = visitDateTimeFromParts(
      date,
      _stringValue(timeValue) ?? '',
    );
    final fallbackStart = DateTime(date.year, date.month, date.day);
    return DateTime.now().isAfter(startsAt ?? fallbackStart);
  }

  DateTime _tourStartValue(_PairableRobotTicket pairable) {
    final ticket = pairable.ticket;
    final visitDate = ticket.visitDate;
    if (visitDate == null) return ticket.purchasedAt;
    return visitDateTimeFromParts(visitDate, ticket.timeSlot ?? '') ??
        DateTime(visitDate.year, visitDate.month, visitDate.day);
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

  Map<String, dynamic> _plannerMetadata({
    required RobotTourTicket ticket,
    required Map<String, dynamic> data,
    required List<String> selectedExhibitIds,
  }) {
    final personalized = ticket.personalizedTourConfig;
    final interests = personalized?.selectedThemes.isNotEmpty == true
        ? personalized!.selectedThemes
        : _stringList(
            data['selected_interests'] ??
                data['selectedInterests'] ??
                data['interests'] ??
                ticket.selectedInterests,
          );
    final accessibility = personalized?.accessibilityNeeds.isNotEmpty == true
        ? personalized!.accessibilityNeeds
        : _stringList(
            data['accessibility_preferences'] ??
                data['accessibilityNeeds'] ??
                data['accessibility'],
          );
    final includePhotoStops =
        personalized?.photoSpotsEnabled ??
        _boolValue(
          data['include_photo_stops'] ??
              data['photoSpotsEnabled'] ??
              data['photo_spots_enabled'] ??
              data['photo_spots'],
        ) ??
        false;
    final duration =
        _intValue(data['duration_minutes']) ??
        _intValue(data['durationMinutes']) ??
        _intValue(data['tour_duration_min']) ??
        _intValue(data['tour_duration']) ??
        ticket.durationMinutes;
    final language =
        _stringValue(data['language']) ??
        _stringValue(data['languageCode']) ??
        _stringValue(data['preferred_language']) ??
        ticket.languageCode;

    return {
      'selected_artifact_ids': selectedExhibitIds,
      'selected_interests': interests,
      'duration_minutes': duration,
      'tour_type': ticket.tourType.name,
      'language': language,
      'accessibility_preferences': accessibility,
      'include_photo_stops': includePhotoStops,
    };
  }

  Future<void> _patchSessionPlannerMetadataIfMissing({
    required String sessionId,
    required Map<String, dynamic> sessionData,
    required RobotTourTicket ticket,
    required Map<String, dynamic> ticketData,
  }) async {
    final status = _stringValue(sessionData['status']);
    if (status == 'completed' || status == 'cancelled') return;

    final selectedExhibitIds = _selectedExhibitIds(ticket);
    final metadata = _plannerMetadata(
      ticket: ticket,
      data: ticketData,
      selectedExhibitIds: selectedExhibitIds,
    );
    final updates = <String, dynamic>{};
    _putIfMissingList(updates, sessionData, 'selected_artifact_ids', metadata);
    _putIfMissingList(updates, sessionData, 'selected_interests', metadata);
    _putIfMissingValue(updates, sessionData, 'duration_minutes', metadata);
    _putIfMissingValue(updates, sessionData, 'tour_type', metadata);
    _putIfMissingValue(updates, sessionData, 'language', metadata);
    _putIfMissingList(
      updates,
      sessionData,
      'accessibility_preferences',
      metadata,
    );
    _putIfMissingValue(updates, sessionData, 'include_photo_stops', metadata);
    if (_stringList(sessionData['selected_exhibits']).isEmpty &&
        selectedExhibitIds.isNotEmpty) {
      updates['selected_exhibits'] = selectedExhibitIds;
    }
    if (_stringValue(sessionData['preferred_language']) == null &&
        _stringValue(metadata['language']) != null) {
      updates['preferred_language'] = metadata['language'];
    }
    if (updates.isEmpty) return;
    updates['updated_at'] = FieldValue.serverTimestamp();
    await _firestore.collection('tourSessions').doc(sessionId).update(updates);
  }

  void _putIfMissingValue(
    Map<String, dynamic> updates,
    Map<String, dynamic> existing,
    String key,
    Map<String, dynamic> metadata,
  ) {
    final value = metadata[key];
    if (value == null) return;
    if (existing.containsKey(key) && existing[key] != null) return;
    updates[key] = value;
  }

  void _putIfMissingList(
    Map<String, dynamic> updates,
    Map<String, dynamic> existing,
    String key,
    Map<String, dynamic> metadata,
  ) {
    final value = metadata[key];
    if (value is! List || value.isEmpty) return;
    if (_stringList(existing[key]).isNotEmpty) return;
    updates[key] = value;
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

  bool _isRobotConnected(Map<String, dynamic> data) {
    final connectionState = _stringValue(data['robotConnectionState'])
        ?.toLowerCase()
        .replaceAll('-', '_');
    if (connectionState != null) {
      return connectionState == 'connected' || connectionState == 'online';
    }
    final explicitOnline =
        _boolValue(data['is_online']) ??
        _boolValue(data['isOnline']) ??
        _boolValue(data['online']);
    return explicitOnline ?? true;
  }

  int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  List<String> _stringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  void _logPairing(String message, Map<String, Object?> details) {
    debugPrint('[Horus-Bot pairing] $message: $details');
  }

  String? _nextExhibit(List<String> route, String? currentExhibitId) {
    if (route.isEmpty) return null;
    if (currentExhibitId == null) {
      return route.length > 1 ? route[1] : null;
    }
    final index = route.indexOf(currentExhibitId);
    if (index < 0 || index + 1 >= route.length) return null;
    return route[index + 1];
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
  final String? currentExhibitId;
  final String? nextExhibitId;

  const RobotPairingResult({
    required this.sessionId,
    required this.robotId,
    required this.museumTicketId,
    required this.robotTourTicketId,
    required this.selectedExhibitIds,
    required this.currentExhibitId,
    required this.nextExhibitId,
  });
}

class RobotPairingException implements Exception {
  final RobotPairingFailureCode code;

  const RobotPairingException(this.code);
}
