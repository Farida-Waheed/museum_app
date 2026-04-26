import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_user.dart';
import '../models/payment_record.dart';

/// Mock authentication service
///
/// This service handles account creation, login, and session management.
/// For now, it uses SharedPreferences for local storage and mock validation.
///
/// TODO: Replace with real backend API / Firebase authentication when available.
class AuthService {
  static const String _kCurrentUser = 'current_user';
  static const String _kUserPayments = 'user_payments';
  static const String _kUserTickets = 'user_tickets';

  /// Mock user database (in-memory for development)
  /// In production, this would be replaced by backend API calls
  static final Map<String, Map<String, dynamic>> _mockUserDatabase = {
    'demo@example.com': {
      'password': 'demo123',
      'name': 'Demo User',
      'phone': '+20 123 456 7890',
    },
    'test@museum.com': {
      'password': 'test123',
      'name': 'Test Visitor',
      'phone': '+20 987 654 3210',
    },
  };

  final SharedPreferences _prefs;

  AuthService(this._prefs);

  /// Create instance of AuthService
  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthService(prefs);
  }

  /// Log in with email and password
  ///
  /// Returns the logged-in user or throws exception if credentials invalid
  /// In production, this would call a real backend API
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Validate inputs
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Check mock database
    final mockUser = _mockUserDatabase[email];
    if (mockUser == null || mockUser['password'] != password) {
      throw Exception('Invalid email or password');
    }

    // Create user object
    final user = AppUser(
      id: 'user_${email.split('@')[0]}',
      name: mockUser['name'] as String,
      email: email,
      phone: mockUser['phone'] as String?,
      preferredLanguage: 'en', // TODO: Get from device locale
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    // Save session
    await _prefs.setString(_kCurrentUser, jsonEncode(user.toJson()));
    return user;
  }

  /// Register a new account
  ///
  /// Creates a new user and saves to mock database
  /// In production, this would call backend API
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String preferredLanguage = 'en',
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Validate inputs
    if (name.trim().isEmpty) {
      throw Exception('Name is required');
    }
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Check if email already exists
    if (_mockUserDatabase.containsKey(email)) {
      throw Exception('Email already registered');
    }

    // Add to mock database
    _mockUserDatabase[email] = {
      'password': password,
      'name': name,
      'phone': phone,
    };

    // Create user object
    final user = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      preferredLanguage: preferredLanguage,
      createdAt: DateTime.now(),
    );

    // Save session
    await _prefs.setString(_kCurrentUser, jsonEncode(user.toJson()));
    return user;
  }

  /// Get currently logged-in user if any
  AppUser? getCurrentUser() {
    final userJson = _prefs.getString(_kCurrentUser);
    if (userJson == null) return null;

    try {
      return AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Log out current user
  Future<void> logout() async {
    await _prefs.remove(_kCurrentUser);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getString(_kCurrentUser) != null;
  }

  /// Simulate loading a website account into the app
  /// (For scenario where user already has website account)
  Future<AppUser> mockLoadWebsiteAccount({
    required String email,
    required String password,
  }) async {
    // In production, this would authenticate against real backend
    return await login(email: email, password: password);
  }

  /// Clear all user data (for logout)
  Future<void> clearUser() async {
    await _prefs.remove(_kCurrentUser);
    await _prefs.remove(_kUserPayments);
    await _prefs.remove(_kUserTickets);
  }

  /// Save payment history for current user
  /// (Mock implementation - in production, backend would store this)
  Future<void> savePaymentRecord(PaymentRecord payment) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('No user logged in');

    final paymentsJson = _prefs.getString(_kUserPayments) ?? '[]';
    final List<dynamic> payments = jsonDecode(paymentsJson) as List<dynamic>;

    payments.add(payment.toJson());
    await _prefs.setString(_kUserPayments, jsonEncode(payments));
  }

  /// Get all payments for current user
  Future<List<PaymentRecord>> getUserPayments() async {
    final user = getCurrentUser();
    if (user == null) return [];

    final paymentsJson = _prefs.getString(_kUserPayments) ?? '[]';
    final List<dynamic> payments = jsonDecode(paymentsJson) as List<dynamic>;

    return payments
        .map((p) => PaymentRecord.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
