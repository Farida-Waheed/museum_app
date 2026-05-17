import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/robot_command.dart';
import '../models/robot_command_ack.dart';
import '../models/robot_event.dart';
import '../models/tour_session.dart';

class TourSessionRepository {
  TourSessionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<TourSession?> watchSession(String sessionId) {
    return _sessionDoc(sessionId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return TourSession.fromFirestore(snapshot.id, data);
    });
  }

  Future<TourSession?> findLatestRestorableSession(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tourSessions')
          .where('userId', isEqualTo: userId)
          .get();
      final sessions =
          snapshot.docs
              .map((doc) => TourSession.fromFirestore(doc.id, doc.data()))
              .where((session) => _isRestorableStatus(session.status))
              .toList()
            ..sort((a, b) {
              final left = a.updatedAt ?? a.startedAt ?? DateTime(0);
              final right = b.updatedAt ?? b.startedAt ?? DateTime(0);
              return right.compareTo(left);
            });

      for (final session in sessions) {
        if (await _isRobotStillPairedToSession(session)) {
          return session;
        }
      }
      return null;
    } on FirebaseException catch (e) {
      throw TourSessionRepositoryException(_friendlyError(e));
    }
  }

  Future<void> startSession({
    required String sessionId,
    required String currentExhibitId,
    required String? nextExhibitId,
    required List<String> visitedExhibitIds,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final sessionRef = _sessionDoc(sessionId);
        final sessionSnapshot = await transaction.get(sessionRef);
        final sessionData = sessionSnapshot.data();
        if (!sessionSnapshot.exists || sessionData == null) {
          throw const TourSessionRepositoryException(
            'Tour session was not found.',
          );
        }
        final robotId = _stringValue(sessionData['robotId']);
        final robotTourTicketId =
            _stringValue(sessionData['robot_tour_ticket_id']) ??
            _stringValue(sessionData['robotTourTicketId']);
        if (robotId == null || robotTourTicketId == null) {
          throw const TourSessionRepositoryException(
            'Tour session is missing robot assignment.',
          );
        }
        final selectedExhibits = _stringList(
          sessionData['selected_exhibits'] ?? sessionData['selectedExhibitIds'],
        );
        final currentIndex = _currentIndex(selectedExhibits, currentExhibitId);
        final now = FieldValue.serverTimestamp();

        transaction.update(sessionRef, {
          'status': 'active',
          'current_exhibit_id': currentExhibitId,
          'current_exhibit_index': currentIndex,
          'started_at': now,
          'updated_at': now,
          'robotState': nextExhibitId == null ? 'waiting' : 'moving',
          'visitedExhibitIds': visitedExhibitIds,
        });
        transaction.update(_robotTourTicketDoc(robotTourTicketId), {
          'status': 'in_progress',
          'updated_at': now,
        });
        transaction.update(_robotDoc(robotId), {
          'status': 'in_tour',
          'updated_at': now,
        });
      });
    } on FirebaseException catch (e) {
      throw TourSessionRepositoryException(_friendlyError(e));
    }
  }

  Future<void> pauseSession(String sessionId) async {
    await _updateSession(sessionId, {'status': 'paused'});
  }

  Future<void> resumeSession(String sessionId) async {
    await _updateSession(sessionId, {'status': 'active'});
  }

  Future<void> updateStop({
    required String sessionId,
    required String currentExhibitId,
    required String? nextExhibitId,
    required List<String> visitedExhibitIds,
  }) async {
    try {
      final sessionSnapshot = await _sessionDoc(sessionId).get();
      final sessionData = sessionSnapshot.data() ?? {};
      final selectedExhibits = _stringList(
        sessionData['selected_exhibits'] ?? sessionData['selectedExhibitIds'],
      );
      await _updateSession(sessionId, {
        'current_exhibit_id': currentExhibitId,
        'current_exhibit_index': _currentIndex(
          selectedExhibits,
          currentExhibitId,
        ),
        'visitedExhibitIds': visitedExhibitIds,
        'robotState': nextExhibitId == null ? 'waiting' : 'moving',
      });
    } on FirebaseException catch (e) {
      throw TourSessionRepositoryException(_friendlyError(e));
    }
  }

  Future<void> completeAndReleaseRobot({
    required String sessionId,
    required String robotId,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final sessionRef = _sessionDoc(sessionId);
        final sessionSnapshot = await transaction.get(sessionRef);
        final sessionData = sessionSnapshot.data();
        if (!sessionSnapshot.exists || sessionData == null) {
          throw const TourSessionRepositoryException(
            'Tour session was not found.',
          );
        }
        final resolvedRobotId =
            _stringValue(sessionData['robotId']) ?? robotId;
        final robotTourTicketId =
            _stringValue(sessionData['robot_tour_ticket_id']) ??
            _stringValue(sessionData['robotTourTicketId']);
        final now = FieldValue.serverTimestamp();

        transaction.update(sessionRef, {
          'status': 'completed',
          'completed_at': now,
          'updated_at': now,
          'robotState': 'waiting',
        });
        if (robotTourTicketId != null) {
          transaction.update(_robotTourTicketDoc(robotTourTicketId), {
            'status': 'completed',
            'updated_at': now,
          });
        }
        transaction.update(_robotDoc(resolvedRobotId), {
          'status': 'available',
          'active_session_id': null,
          'active_user_id': null,
          'active_robot_tour_ticket_id': null,
          'updated_at': now,
        });
      });
    } on FirebaseException catch (e) {
      throw TourSessionRepositoryException(_friendlyError(e));
    }
  }

  Future<void> markCommandPending(
    String sessionId,
    RobotCommand command,
  ) async {
    await _updateSession(sessionId, {
      'commandStatus': 'pending',
      'lastCommandId': command.commandId,
      'lastCommandType': command.type.wireName,
      'lastCommandError': null,
      'lastCommandAt': FieldValue.serverTimestamp(),
      'mqttEnabled': true,
    });
  }

  Future<void> markCommandAcked(String sessionId, RobotCommandAck ack) async {
    final failed = ack.status == 'failed' || ack.status == 'rejected';
    await _updateSession(sessionId, {
      'commandStatus': failed ? 'failed' : 'acknowledged',
      'lastCommandId': ack.commandId,
      'lastCommandType': ack.commandType,
      'lastCommandError': failed ? ack.errorCode ?? ack.message : null,
      'lastAckAt': FieldValue.serverTimestamp(),
      'robotConnectionState': 'connected',
    });
  }

  Future<void> markCommandFailed(
    String sessionId,
    String commandId,
    String error,
  ) async {
    final mqttDisabled = error == 'mqtt_disabled';
    await _updateSession(sessionId, {
      'commandStatus': 'failed',
      'lastCommandId': commandId,
      'lastCommandError': error,
      'lastAckAt': FieldValue.serverTimestamp(),
      'mqttEnabled': !mqttDisabled,
      'robotConnectionState': mqttDisabled ? 'disabled' : 'unknown',
    });
  }

  Future<void> recordRobotEvent(String sessionId, RobotEvent event) async {
    final updates = <String, dynamic>{
      'lastRobotEvent': event.toJson(),
      'lastRobotEventAt': FieldValue.serverTimestamp(),
      'robotConnectionState': 'connected',
    };

    if (event.type == 'arrived_exhibit') {
      final currentExhibitId = _stringValue(event.payload['currentExhibitId']);
      final visitedExhibitIds = _stringList(event.payload['visitedExhibitIds']);
      if (currentExhibitId != null) {
        updates['current_exhibit_id'] = currentExhibitId;
        final sessionSnapshot = await _sessionDoc(sessionId).get();
        final sessionData = sessionSnapshot.data() ?? {};
        final selectedExhibits = _stringList(
          sessionData['selected_exhibits'] ?? sessionData['selectedExhibitIds'],
        );
        updates['current_exhibit_index'] = _currentIndex(
          selectedExhibits,
          currentExhibitId,
        );
      }
      if (visitedExhibitIds.isNotEmpty) {
        updates['visitedExhibitIds'] = visitedExhibitIds;
      }
      updates['robotState'] = 'waiting';
    }

    await _updateSession(sessionId, updates);
  }

  Future<void> _updateSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _sessionDoc(
        sessionId,
      ).update({...updates, 'updated_at': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      throw TourSessionRepositoryException(_friendlyError(e));
    }
  }

  DocumentReference<Map<String, dynamic>> _sessionDoc(String sessionId) {
    return _firestore.collection('tourSessions').doc(sessionId);
  }

  DocumentReference<Map<String, dynamic>> _robotDoc(String robotId) {
    return _firestore.collection('robots').doc(robotId);
  }

  DocumentReference<Map<String, dynamic>> _robotTourTicketDoc(
    String ticketId,
  ) {
    return _firestore.collection('robotTourTickets').doc(ticketId);
  }

  int _currentIndex(List<String> selectedExhibits, String currentExhibitId) {
    final index = selectedExhibits.indexOf(currentExhibitId);
    return index < 0 ? 0 : index;
  }

  bool _isRestorableStatus(String status) {
    return status == 'paired' ||
        status == 'ready' ||
        status == 'active' ||
        status == 'paused';
  }

  Future<bool> _isRobotStillPairedToSession(TourSession session) async {
    if (session.robotId.isEmpty || session.userId.isEmpty) return false;
    final snapshot = await _robotDoc(session.robotId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return false;
    final robotSessionId =
        _stringValue(data['active_session_id']) ??
        _stringValue(data['activeSessionId']);
    final robotUserId =
        _stringValue(data['active_user_id']) ??
        _stringValue(data['currentUserId']);
    final robotStatus = _stringValue(data['status']);
    return robotSessionId == session.sessionId &&
        robotUserId == session.userId &&
        robotStatus != 'available' &&
        robotStatus != 'offline';
  }

  String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  List<String> _stringList(Object? value) {
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }

  String _friendlyError(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'Firestore rules blocked the tour session update. For ending a tour, allow the paired user to update their tourSessions/{sessionId} to completed and release robots/{robotId} from paired to available.';
    }
    if (e.code == 'unavailable' ||
        e.code == 'deadline-exceeded' ||
        e.code == 'network-request-failed') {
      return 'Network error. Please check your connection and try again.';
    }
    return 'Unable to sync the tour session. Please try again.';
  }
}

class TourSessionRepositoryException implements Exception {
  final String message;

  const TourSessionRepositoryException(this.message);

  @override
  String toString() => message;
}
