import 'dart:async';

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
  robotConnectionStateNotConnected,
  robotMqttDisabled,
  robotLastSeenMissing,
  robotLastSeenStale,
  mqttSessionNotConfirmed,
  commandRejected,
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
    var passedAvailabilityBeforeTransaction = false;
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

      final initialRobotSnapshot = await _readRobotSnapshotFromServerWithRetry(
        robotRef,
      );
      _validateRobotBridgeOnline(
        initialRobotSnapshot.data() ?? {},
        requireNoActiveSession: false,
      );
      passedAvailabilityBeforeTransaction = true;
      _logPairing(
        'robot availability passed; entering ticket selection flow',
        {
          'robotDocPath': robotRef.path,
          'preferredRobotTourTicketId': robotTourTicketId,
        },
      );

      final restorablePairing = await _findRestorableInProgressPairing(
        userId: userId,
        robotIdCandidates: robotCandidates,
        preferredTicketId: robotTourTicketId,
      );
      if (restorablePairing != null) {
        _logPairing(
          'flow returned early after robot availability',
          {
            'reason': 'restorable in-progress pairing found',
            'sessionId': restorablePairing.sessionId,
            'robotId': restorablePairing.robotId,
            'robotTourTicketId': restorablePairing.robotTourTicketId,
            'museumTicketId': restorablePairing.museumTicketId,
            'transactionWillStart': false,
          },
        );
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

      _logPairing(
        'entering robot tour ticket selection after availability',
        {
          'userId': userId,
          'preferredRobotTourTicketId': robotTourTicketId,
        },
      );
      final pairableTicket = await _selectPairableRobotTourTicket(
        userId,
        preferredTicketId: robotTourTicketId,
      );
      if (pairableTicket == null) {
        _logPairing(
          'flow returned early after robot availability',
          {
            'reason': 'no pairable robot tour ticket',
            'transactionWillStart': false,
          },
        );
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
        _logPairing(
          'flow returned early after robot availability',
          {
            'reason': 'pairable robot tour ticket missing booking or museum ticket id',
            'bookingIdEmpty': bookingId.isEmpty,
            'museumTicketIdEmpty': museumTicketId.isEmpty,
            'robotTourTicketDocId': pairableTicket.documentId,
            'transactionWillStart': false,
          },
        );
        throw const RobotPairingException(
          RobotPairingFailureCode.robotTourTicketRequired,
        );
      }
      passedAvailabilityBeforeTransaction = false;
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

      final finalRobotSnapshot = await _readRobotSnapshotFromServerWithRetry(
        robotRef,
      );
      _validateRobotBridgeOnline(finalRobotSnapshot.data() ?? {});

      final transactionWrites = <_FirestoreWriteDebugEntry>[];
      try {
        await _firestore.runTransaction((transaction) async {
          final robotTicketSnapshot = await _transactionGet(
            transaction,
            robotTicketRef,
          );
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
          final museumTicketSnapshot = await _transactionGet(
            transaction,
            museumTicketRef,
          );
          if (!museumTicketSnapshot.exists ||
              !_isActiveMuseumTicket(museumTicketSnapshot.data(), userId)) {
            throw RobotPairingException(
              _ticketFailureCode(museumTicketSnapshot.data()),
            );
          }

          final robotSnapshot = await _transactionGet(transaction, robotRef);
          if (!robotSnapshot.exists) {
            throw const RobotPairingException(
              RobotPairingFailureCode.robotNotFound,
            );
          }

          final robotData = robotSnapshot.data() ?? {};
          final activeSessionId = _activeSessionIdValue(
            robotData['activeSessionId'],
          );
          if (activeSessionId != null) {
            throw const RobotPairingException(RobotPairingFailureCode.robotBusy);
          }

          _validateRobotBridgeOnline(robotData);

          final now = FieldValue.serverTimestamp();

          _transactionSet(
            transaction,
            sessionRef,
            {
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
            },
            transactionWrites,
          );

          _transactionUpdate(
            transaction,
            robotTicketRef,
            {
              'status': 'in_progress',
              'paired_robot_id': robotId,
              'session_id': sessionId,
              'paired_at': now,
              'updated_at': now,
            },
            transactionWrites,
          );

          _transactionUpdate(
            transaction,
            robotRef,
            {
              'activeSessionId': sessionId,
            },
            transactionWrites,
          );

          _logPairing(
            'firestore transaction queued writes final',
            {
              'queuedWriteCount': transactionWrites.length,
              'queuedWrites': transactionWrites
                  .map((entry) => entry.toLogMap())
                  .toList(growable: false),
            },
          );
        });
      } catch (e, stackTrace) {
        _logFirestoreTransactionFailure(transactionWrites, e, stackTrace);
        rethrow;
      }
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
    } on RobotPairingException catch (e, stackTrace) {
      if (passedAvailabilityBeforeTransaction) {
        _logPairing(
          'exception between robot availability and transaction starting',
          {
            'failureCode': e.code.name,
            'detail': e.detail,
            'stackTrace': stackTrace.toString(),
          },
        );
      }
      rethrow;
    } on FirebaseException catch (e, stackTrace) {
      if (passedAvailabilityBeforeTransaction) {
        _logPairing(
          'exception between robot availability and transaction starting',
          _firestoreExceptionLog(e, stackTrace),
        );
      }
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
    } catch (e, stackTrace) {
      if (passedAvailabilityBeforeTransaction) {
        _logPairing(
          'exception between robot availability and transaction starting',
          _firestoreExceptionLog(e, stackTrace),
        );
      }
      rethrow;
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
    final robotCode = robotCodeForParsedId(parsedRobotId);
    if (robotCode == null) return null;
    final ref = _firestore.collection('robots').doc(robotCode);
    _logPairing(
      'robot document path',
      {
        'path': ref.path,
        'expectedPath': 'robots/ROBOT-HORUS-001',
        'robotIdExact': robotCode,
      },
    );
    final snapshot = await ref.get(const GetOptions(source: Source.server));
    _logPairing(
      'robot document checked',
      {
        'path': ref.path,
        'exists': snapshot.exists,
        'isFromCache': snapshot.metadata.isFromCache,
      },
    );
    return snapshot.exists ? ref : null;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _readRobotSnapshotFromServerWithRetry(
    DocumentReference<Map<String, dynamic>> robotRef,
  ) async {
    DocumentSnapshot<Map<String, dynamic>>? lastSnapshot;
    for (var attempt = 1; attempt <= 3; attempt += 1) {
      final snapshot = await robotRef.get(
        const GetOptions(source: Source.server),
      );
      lastSnapshot = snapshot;
      _logRobotServerSnapshot(robotRef, snapshot, attempt);
      if (!snapshot.exists) {
        throw const RobotPairingException(
          RobotPairingFailureCode.robotNotFound,
        );
      }
      final data = snapshot.data() ?? {};
      if (data['mqttEnabled'] == true) return snapshot;
      if (attempt < 3) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    return lastSnapshot!;
  }

  void _logRobotServerSnapshot(
    DocumentReference<Map<String, dynamic>> robotRef,
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    int attempt,
  ) {
    final data = snapshot.data();
    _logPairing(
      'robot server snapshot raw availability fields',
      {
        'attempt': attempt,
        'path': robotRef.path,
        'exists': snapshot.exists,
        'isFromCache': snapshot.metadata.isFromCache,
        'robotConnectionState': data?['robotConnectionState'],
        'mqttEnabled': data?['mqttEnabled'],
        'lastSeenAt': data?['lastSeenAt'],
        'activeSessionId': data?['activeSessionId'],
        'status': data?['status'],
      },
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _transactionGet(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    _logPairing(
      'firestore transaction get starting',
      {
        'collectionPath': ref.parent.path,
        'documentId': ref.id,
        'documentPath': ref.path,
        'operationType': 'transaction.get',
      },
    );
    try {
      final snapshot = await transaction.get(ref);
      _logPairing(
        'firestore transaction get succeeded',
        {
          'collectionPath': ref.parent.path,
          'documentId': ref.id,
          'documentPath': ref.path,
          'operationType': 'transaction.get',
          'exists': snapshot.exists,
          'data': snapshot.data(),
        },
      );
      return snapshot;
    } catch (e, stackTrace) {
      _logPairing(
        'firestore transaction get failed',
        {
          'collectionPath': ref.parent.path,
          'documentId': ref.id,
          'documentPath': ref.path,
          'operationType': 'transaction.get',
          ..._firestoreExceptionLog(e, stackTrace),
        },
      );
      rethrow;
    }
  }

  void _transactionSet(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> payload,
    List<_FirestoreWriteDebugEntry> queuedWrites,
  ) {
    final entry = _FirestoreWriteDebugEntry(
      operationType: 'transaction.set',
      collectionPath: ref.parent.path,
      documentId: ref.id,
      documentPath: ref.path,
      payload: payload,
    );
    queuedWrites.add(entry);
    _logFirestoreWriteAttempt(entry);
    try {
      transaction.set(ref, payload);
    } catch (e, stackTrace) {
      _logFirestoreWriteFailure(entry, e, stackTrace);
      rethrow;
    }
  }

  void _transactionUpdate(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> payload,
    List<_FirestoreWriteDebugEntry> queuedWrites,
  ) {
    final entry = _FirestoreWriteDebugEntry(
      operationType: 'transaction.update',
      collectionPath: ref.parent.path,
      documentId: ref.id,
      documentPath: ref.path,
      payload: payload,
    );
    queuedWrites.add(entry);
    _logFirestoreWriteAttempt(entry);
    try {
      transaction.update(ref, payload);
    } catch (e, stackTrace) {
      _logFirestoreWriteFailure(entry, e, stackTrace);
      rethrow;
    }
  }

  Future<void> _updateDocumentWithDebugLogging(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> payload,
  ) async {
    final entry = _FirestoreWriteDebugEntry(
      operationType: 'update',
      collectionPath: ref.parent.path,
      documentId: ref.id,
      documentPath: ref.path,
      payload: payload,
    );
    _logFirestoreWriteAttempt(entry);
    try {
      await ref.update(payload);
    } catch (e, stackTrace) {
      _logFirestoreWriteFailure(entry, e, stackTrace);
      rethrow;
    }
  }

  void _logFirestoreWriteAttempt(_FirestoreWriteDebugEntry entry) {
    _logPairing('firestore write attempt', entry.toLogMap());
  }

  void _logFirestoreWriteFailure(
    _FirestoreWriteDebugEntry entry,
    Object exception,
    StackTrace stackTrace,
  ) {
    _logPairing(
      'firestore write failed',
      {
        ...entry.toLogMap(),
        ..._firestoreExceptionLog(exception, stackTrace),
      },
    );
  }

  void _logFirestoreTransactionFailure(
    List<_FirestoreWriteDebugEntry> queuedWrites,
    Object exception,
    StackTrace stackTrace,
  ) {
    _logPairing(
      'firestore transaction failed',
      {
        'operationType': 'transaction.commit',
        'queuedWriteCount': queuedWrites.length,
        'queuedWrites': queuedWrites
            .map((entry) => entry.toLogMap())
            .toList(growable: false),
        ..._firestoreExceptionLog(exception, stackTrace),
      },
    );
  }

  Map<String, Object?> _firestoreExceptionLog(
    Object exception,
    StackTrace stackTrace,
  ) {
    final firebaseException = exception is FirebaseException ? exception : null;
    return {
      'exceptionType': exception.runtimeType.toString(),
      'firebaseCode': firebaseException?.code,
      'firebaseMessage': firebaseException?.message,
      'firebasePlugin': firebaseException?.plugin,
      'exception': exception.toString(),
      'stackTrace': stackTrace.toString(),
    };
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
    await _updateDocumentWithDebugLogging(
      _firestore.collection('tourSessions').doc(sessionId),
      updates,
    );
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

  String? _activeSessionIdValue(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  bool? _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
    return null;
  }

  void _validateRobotBridgeOnline(
    Map<String, dynamic> robotData, {
    bool requireNoActiveSession = true,
  }) {
    final status = _stringValue(robotData['status']);
    if (status != 'available') {
      throw const RobotPairingException(
        RobotPairingFailureCode.robotUnavailable,
      );
    }

    final connectionState = _stringValue(robotData['robotConnectionState']);
    if (connectionState != 'connected') {
      throw RobotPairingException(
        RobotPairingFailureCode.robotConnectionStateNotConnected,
        detail: connectionState ?? 'missing',
      );
    }

    final mqttEnabled = robotData['mqttEnabled'];
    if (mqttEnabled != true) {
      throw RobotPairingException(
        RobotPairingFailureCode.robotMqttDisabled,
        detail: _rawValue(mqttEnabled),
      );
    }

    final lastSeenAt = _dateValue(robotData['lastSeenAt']);
    if (lastSeenAt == null) {
      throw const RobotPairingException(
        RobotPairingFailureCode.robotLastSeenMissing,
      );
    }
    final secondsSinceLastSeen = DateTime.now()
        .toUtc()
        .difference(lastSeenAt.toUtc())
        .inSeconds;
    if (secondsSinceLastSeen > 45) {
      throw RobotPairingException(
        RobotPairingFailureCode.robotLastSeenStale,
        detail: secondsSinceLastSeen.toString(),
      );
    }

    if (requireNoActiveSession &&
        _activeSessionIdValue(robotData['activeSessionId']) != null) {
      throw const RobotPairingException(RobotPairingFailureCode.robotBusy);
    }
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

  String _rawValue(Object? value) {
    if (value == null) return 'null';
    if (value is String) return value;
    return value.toString();
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

class _FirestoreWriteDebugEntry {
  const _FirestoreWriteDebugEntry({
    required this.operationType,
    required this.collectionPath,
    required this.documentId,
    required this.documentPath,
    required this.payload,
  });

  final String operationType;
  final String collectionPath;
  final String documentId;
  final String documentPath;
  final Map<String, dynamic> payload;

  Map<String, Object?> toLogMap() {
    return {
      'collectionPath': collectionPath,
      'documentId': documentId,
      'documentPath': documentPath,
      'operationType': operationType,
      'payload': payload,
    };
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
  final String? detail;

  const RobotPairingException(this.code, {this.detail});
}
