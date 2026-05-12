import 'package:cloud_firestore/cloud_firestore.dart';

class TourPhoto {
  final String photoId;
  final String userId;
  final String sessionId;
  final String? robotId;
  final String? exhibitId;
  final String photoUrl;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final String type;

  const TourPhoto({
    required this.photoId,
    required this.userId,
    required this.sessionId,
    required this.robotId,
    required this.exhibitId,
    required this.photoUrl,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.type,
  });

  factory TourPhoto.fromFirestore(String docId, Map<String, dynamic> data) {
    return TourPhoto(
      photoId: _stringValue(data['photoId']) ?? docId,
      userId: _stringValue(data['userId']) ?? '',
      sessionId: _stringValue(data['sessionId']) ?? '',
      robotId: _stringValue(data['robotId']),
      exhibitId: _stringValue(data['exhibitId']),
      photoUrl: _stringValue(data['photoUrl']) ?? '',
      thumbnailUrl: _stringValue(data['thumbnailUrl']),
      createdAt: _dateValue(data['createdAt']),
      type: _stringValue(data['type']) ?? 'robot_capture',
    );
  }

  Map<String, dynamic> toCreateFirestore() {
    return {
      'photoId': photoId,
      'userId': userId,
      'sessionId': sessionId,
      'robotId': robotId,
      'exhibitId': exhibitId,
      'photoUrl': photoUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'type': type,
    };
  }

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static DateTime? _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
