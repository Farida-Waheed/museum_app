import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/payment_record.dart';

/// Firebase-backed authentication and user profile service.
class AuthService {
  static const String _kUserPayments = 'user_payments';
  static const String _kUserTickets = 'user_tickets';

  final SharedPreferences _prefs;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService(
    this._prefs, {
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create instance of AuthService.
  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthService(prefs);
  }

  /// Firebase auth state stream for app startup/session restoration.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Log in with email and password, then load the Firestore profile.
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthServiceException(
          'Unable to sign in. Please try again.',
        );
      }

      return await _loadOrCreateUserProfile(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_friendlyAuthError(e));
    } on FirebaseException catch (e) {
      throw AuthServiceException(_friendlyFirebaseError(e));
    }
  }

  /// Register with Firebase Auth, then create users/{uid}.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String preferredLanguage = 'en',
  }) async {
    try {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) {
        throw const AuthServiceException('Name is required.');
      }

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthServiceException(
          'Unable to create your account. Please try again.',
        );
      }

      await firebaseUser.updateDisplayName(trimmedName);

      final user = AppUser(
        id: firebaseUser.uid,
        name: trimmedName,
        email: firebaseUser.email ?? email.trim(),
        phone: phone,
        preferredLanguage: preferredLanguage,
        createdAt: DateTime.now(),
      );

      await _userDoc(firebaseUser.uid).set({
        ...user.toFirestore(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_friendlyAuthError(e));
    } on FirebaseException catch (e) {
      throw AuthServiceException(_friendlyFirebaseError(e));
    }
  }

  /// Restore the current Firebase user, if one is already signed in.
  Future<AppUser?> restoreCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      return await _loadOrCreateUserProfile(firebaseUser);
    } on FirebaseException catch (e) {
      throw AuthServiceException(_friendlyFirebaseError(e));
    }
  }

  /// Synchronous Firebase login check.
  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Log out current Firebase user.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Update users/{uid} profile fields.
  Future<AppUser> updateProfile({String? name, String? phone}) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw const AuthServiceException('No user is logged in.');
    }

    try {
      final updates = <String, dynamic>{
        'updated_at': FieldValue.serverTimestamp(),
      };

      final trimmedName = name?.trim();
      if (trimmedName != null && trimmedName.isNotEmpty) {
        updates['display_name'] = trimmedName;
        updates['full_name'] = trimmedName;
        await firebaseUser.updateDisplayName(trimmedName);
      }

      if (phone != null) {
        final trimmedPhone = phone.trim();
        updates['phone_number'] = trimmedPhone.isEmpty ? null : trimmedPhone;
      }

      await _userDoc(firebaseUser.uid).set(updates, SetOptions(merge: true));
      return await _loadOrCreateUserProfile(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_friendlyAuthError(e));
    } on FirebaseException catch (e) {
      throw AuthServiceException(_friendlyFirebaseError(e));
    }
  }

  /// Simulate loading a website account into the app.
  ///
  /// The website and mobile app now share Firebase Auth credentials.
  Future<AppUser> mockLoadWebsiteAccount({
    required String email,
    required String password,
  }) async {
    return login(email: email, password: password);
  }

  /// Clear user-local cached data and sign out.
  Future<void> clearUser() async {
    await logout();
    await _prefs.remove(_kUserPayments);
    await _prefs.remove(_kUserTickets);
  }

  /// Save payment history for current user.
  ///
  /// This remains local mock storage until payment/ticket persistence is moved
  /// in a later phase.
  Future<void> savePaymentRecord(PaymentRecord payment) async {
    if (_firebaseAuth.currentUser == null) {
      throw const AuthServiceException('No user logged in.');
    }

    final paymentsJson = _prefs.getString(_kUserPayments) ?? '[]';
    final List<dynamic> payments = jsonDecode(paymentsJson) as List<dynamic>;

    payments.add(payment.toJson());
    await _prefs.setString(_kUserPayments, jsonEncode(payments));
  }

  /// Get all locally cached payments for current user.
  Future<List<PaymentRecord>> getUserPayments() async {
    if (_firebaseAuth.currentUser == null) return [];

    final paymentsJson = _prefs.getString(_kUserPayments) ?? '[]';
    final List<dynamic> payments = jsonDecode(paymentsJson) as List<dynamic>;

    return payments
        .map((p) => PaymentRecord.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<AppUser> _loadOrCreateUserProfile(User firebaseUser) async {
    final doc = await _userDoc(firebaseUser.uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromFirestore(doc.data()!, fallbackUid: firebaseUser.uid);
    }

    final user = AppUser(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? _nameFromEmail(firebaseUser.email),
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber,
      preferredLanguage: 'en',
      createdAt: DateTime.now(),
      avatarUrl: firebaseUser.photoURL,
    );

    await _userDoc(firebaseUser.uid).set({
      ...user.toFirestore(),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    return user;
  }

  String _nameFromEmail(String? email) {
    final localPart = email?.split('@').first.trim();
    return localPart == null || localPart.isEmpty
        ? 'Museum Visitor'
        : localPart;
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'user-not-found':
        return 'No account was found for that email.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _friendlyFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
      case 'deadline-exceeded':
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'permission-denied':
        return 'You do not have permission to update this profile.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

class AuthServiceException implements Exception {
  final String message;

  const AuthServiceException(this.message);

  @override
  String toString() => message;
}
