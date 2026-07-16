import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/accessibility_constants.dart';
import '../models/accessibility_profile.dart';
import 'accessibility_repository.dart';

/// Firestore-backed [AccessibilityRepository].
///
/// The profile lives inside the existing `users/{uid}` document under the
/// `accessibility_defaults` field — already modelled by AppUser and already
/// whitelisted in firestore.rules (`ownedUserProfileUpdate`). We therefore
/// introduce NO new collection and NO rules change.
///
/// Writes touch only `accessibility_defaults` + `updated_at` with merge
/// semantics, so they satisfy the rule's `affectedKeys().hasOnly([...])`
/// constraint and never disturb other profile fields.
class FirebaseAccessibilityRepository implements AccessibilityRepository {
  final FirebaseFirestore _firestore;

  FirebaseAccessibilityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Future<AccessibilityProfile?> fetch(String uid) async {
    final snap = await _userDoc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    final field = data[AccessibilityConstants.firestoreField];
    if (field is! Map) return null;
    final map = field.map((k, v) => MapEntry(k.toString(), v));
    if (map.isEmpty) return null;
    return AccessibilityProfile.fromStorageMap(map);
  }

  @override
  Future<void> save(String uid, AccessibilityProfile profile) async {
    await _userDoc(uid).set(
      {
        AccessibilityConstants.firestoreField: profile.toStorageMap(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
