import 'package:cloud_firestore/cloud_firestore.dart';

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
    await _updateSession(sessionId, {
      'status': 'active',
      'robotState': nextExhibitId == null ? 'waiting' : 'moving',
      'currentExhibitId': currentExhibitId,
      'nextExhibitId': nextExhibitId,
      'visitedExhibitIds': visitedExhibitIds,
    });
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
    await _updateSession(sessionId, {
      'currentExhibitId': currentExhibitId,
      'nextExhibitId': nextExhibitId,
      'visitedExhibitIds': visitedExhibitIds,
      'robotState': nextExhibitId == null ? 'waiting' : 'moving',
    });
  }

  Future<void> completeAndReleaseRobot({
    required String sessionId,
    required String robotId,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        transaction.update(_sessionDoc(sessionId), {
          'status': 'completed',
          'robotState': 'waiting',
          'completedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(_robotDoc(robotId), {
          'status': 'available',
          'activeSessionId': '',
          'currentUserId': '',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw TourSessionRepositoryException(_friendlyError(e));
    }
  }

  Future<void> _updateSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _sessionDoc(
        sessionId,
      ).update({...updates, 'updatedAt': FieldValue.serverTimestamp()});
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

  bool _isRestorableStatus(String status) {
    return status == 'ready' || status == 'active' || status == 'paused';
  }

  Future<bool> _isRobotStillPairedToSession(TourSession session) async {
    if (session.robotId.isEmpty || session.userId.isEmpty) return false;
    final snapshot = await _robotDoc(session.robotId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return false;
    final robotSessionId = _stringValue(data['activeSessionId']);
    final robotUserId = _stringValue(data['currentUserId']);
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
