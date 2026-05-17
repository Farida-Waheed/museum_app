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
    String? nationality,
    String preferredLanguage = 'english',
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
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email.trim(),
        fullName: trimmedName,
        displayName: trimmedName,
        phoneNumber: _nullableTrimmed(phone),
        nationality: _nullableTrimmed(nationality),
        preferredLanguage: _normalizedLanguage(preferredLanguage),
        createdAt: DateTime.now(),
      );

      await _userDoc(firebaseUser.uid).set({
        ...user.toFirestore(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'last_seen_at': FieldValue.serverTimestamp(),
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
  Future<AppUser> updateProfile({
    String? fullName,
    String? displayName,
    String? phoneNumber,
    String? nationality,
    String? preferredLanguage,
    String? avatarUrl,
    Map<String, dynamic>? accessibilityDefaults,
    bool? marketingOptIn,
  }) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw const AuthServiceException('No user is logged in.');
    }

    try {
      final updates = <String, dynamic>{};

      final trimmedFullName = fullName?.trim();
      if (trimmedFullName != null && trimmedFullName.isNotEmpty) {
        updates['full_name'] = trimmedFullName;
      }

      final trimmedDisplayName = displayName?.trim();
      if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
        updates['display_name'] = trimmedDisplayName;
        await firebaseUser.updateDisplayName(trimmedDisplayName);
      } else if (trimmedFullName != null && trimmedFullName.isNotEmpty) {
        updates['display_name'] = trimmedFullName;
        await firebaseUser.updateDisplayName(trimmedFullName);
      }

      if (phoneNumber != null) {
        updates['phone_number'] = _nullableTrimmed(phoneNumber);
      }
      if (nationality != null) {
        updates['nationality'] = _nullableTrimmed(nationality);
      }
      if (preferredLanguage != null) {
        updates['preferred_language'] = _normalizedLanguage(preferredLanguage);
      }
      if (avatarUrl != null) {
        updates['avatar_url'] = _nullableTrimmed(avatarUrl);
      }
      if (accessibilityDefaults != null) {
        updates['accessibility_defaults'] = accessibilityDefaults;
      }
      if (marketingOptIn != null) {
        updates['marketing_opt_in'] = marketingOptIn;
      }

      if (updates.isNotEmpty) {
        updates['updated_at'] = FieldValue.serverTimestamp();
        await _userDoc(firebaseUser.uid).set(updates, SetOptions(merge: true));
      }
      return await _loadOrCreateUserProfile(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(_friendlyAuthError(e));
    } on FirebaseException catch (e) {
      throw AuthServiceException(_friendlyFirebaseError(e));
    }
  }

  /// Sign in to the same Firebase account used by the web app.
  Future<AppUser> loadWebsiteAccount({
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
      final data = doc.data()!;
      await _userDoc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'display_name':
            data['display_name'] ?? data['name'] ?? firebaseUser.displayName,
        'full_name':
            data['full_name'] ?? data['name'] ?? firebaseUser.displayName,
        'phone_number':
            data['phone_number'] ?? data['phone'] ?? firebaseUser.phoneNumber,
        'nationality': data['nationality'],
        'preferred_language': _normalizedLanguage(
          data['preferred_language'] ?? data['preferredLanguage'],
        ),
        'avatar_url': data['avatar_url'] ?? firebaseUser.photoURL,
        'accessibility_defaults':
            data['accessibility_defaults'] ?? <String, dynamic>{},
        'marketing_opt_in': data['marketing_opt_in'] ?? false,
        'created_at': data['created_at'] ?? FieldValue.serverTimestamp(),
        'last_seen_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return AppUser.fromFirestore({
        ...data,
        'uid': firebaseUser.uid,
        'preferred_language': _normalizedLanguage(
          data['preferred_language'] ?? data['preferredLanguage'],
        ),
      }, fallbackUid: firebaseUser.uid);
    }

    final user = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? _nameFromEmail(firebaseUser.email),
      displayName: firebaseUser.displayName ?? _nameFromEmail(firebaseUser.email),
      phoneNumber: firebaseUser.phoneNumber,
      preferredLanguage: 'english',
      createdAt: DateTime.now(),
      avatarUrl: firebaseUser.photoURL,
    );

    await _userDoc(firebaseUser.uid).set({
      ...user.toFirestore(),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'last_seen_at': FieldValue.serverTimestamp(),
    });

    return user;
  }

  String _nameFromEmail(String? email) {
    final localPart = email?.split('@').first.trim();
    return localPart == null || localPart.isEmpty
        ? 'Museum Visitor'
        : localPart;
  }

  String _normalizedLanguage(Object? value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return 'english';
    switch (raw.toLowerCase().replaceAll('-', '_')) {
      case 'en':
      case 'english':
        return 'english';
      case 'ar':
      case 'arabic':
        return 'arabic';
      default:
        return 'english';
    }
  }

  String? _nullableTrimmed(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
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
        return 'Connection issue. Please check your internet connection and try again.';
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
        return 'Connection issue. Please check your internet connection and try again.';
      case 'permission-denied':
        return 'This content is currently unavailable.';
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
