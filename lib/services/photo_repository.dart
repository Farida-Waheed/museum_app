import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/tour_photo.dart';

class PhotoRepository {
  PhotoRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _photos =>
      _firestore.collection('photos');

  Stream<List<TourPhoto>> watchSessionPhotos(String sessionId) {
    if (sessionId.trim().isEmpty) return const Stream.empty();
    return _photos
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map(_photosFromSnapshot);
  }

  Stream<List<TourPhoto>> watchUserPhotos(String userId) {
    if (userId.trim().isEmpty) return const Stream.empty();
    return _photos
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(_photosFromSnapshot);
  }

  Future<List<TourPhoto>> loadSessionPhotos(String sessionId) async {
    if (sessionId.trim().isEmpty) return const [];
    try {
      final snapshot = await _photos
          .where('sessionId', isEqualTo: sessionId)
          .get();
      return _photosFromSnapshot(snapshot);
    } on FirebaseException catch (e) {
      throw PhotoRepositoryException(_friendlyError(e));
    }
  }

  Future<TourPhoto> uploadRobotCapture({
    required Uint8List bytes,
    required String userId,
    required String sessionId,
    required String robotId,
    String? exhibitId,
  }) async {
    if (userId.trim().isEmpty || sessionId.trim().isEmpty) {
      throw const PhotoRepositoryException('No active tour session.');
    }

    final doc = _photos.doc();
    final storageRef = _storage.ref('tourPhotos/$sessionId/${doc.id}.jpg');

    try {
      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await storageRef.getDownloadURL();
      final photo = TourPhoto(
        photoId: doc.id,
        userId: userId,
        sessionId: sessionId,
        robotId: robotId,
        exhibitId: exhibitId,
        photoUrl: url,
        thumbnailUrl: url,
        createdAt: null,
        type: 'robot_capture',
      );
      await doc.set(photo.toCreateFirestore());
      return photo;
    } on FirebaseException catch (e) {
      throw PhotoRepositoryException(_friendlyError(e));
    }
  }

  List<TourPhoto> _photosFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final photos =
        snapshot.docs
            .map((doc) => TourPhoto.fromFirestore(doc.id, doc.data()))
            .where((photo) => photo.photoUrl.isNotEmpty)
            .toList()
          ..sort((a, b) {
            final left = a.createdAt ?? DateTime(0);
            final right = b.createdAt ?? DateTime(0);
            return right.compareTo(left);
          });
    return photos;
  }

  String _friendlyError(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'This content is currently unavailable.';
    }
    if (e.code == 'unavailable' ||
        e.code == 'deadline-exceeded' ||
        e.code == 'network-request-failed') {
      return 'Connection issue. Please check your internet connection and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}

class PhotoRepositoryException implements Exception {
  final String message;

  const PhotoRepositoryException(this.message);

  @override
  String toString() => message;
}
