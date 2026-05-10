import 'package:flutter/material.dart';
import 'app_user.dart';
import '../services/auth_service.dart';

/// Authentication state
enum AuthState { guest, loggedOut, loading, loggedIn, error }

/// Manages user account and authentication state
///
/// This provider handles:
/// - User login and registration
/// - Session persistence
/// - Account state changes
/// - Error handling
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthState _authState = AuthState.guest;
  AppUser? _currentUser;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _loadSavedSession();
  }

  // ========================
  // GETTERS
  // ========================

  AuthState get authState => _authState;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage;

  bool get isLoggedIn => _authState == AuthState.loggedIn;
  bool get isGuest => _authState == AuthState.guest;
  bool get isLoading => _authState == AuthState.loading;
  bool get hasError => _authState == AuthState.error;

  // ========================
  // ACTIONS
  // ========================

  /// Load current Firebase Auth session on app startup.
  Future<void> _loadSavedSession() async {
    try {
      final user = await _authService.restoreCurrentUser();
      if (user != null) {
        _currentUser = user;
        _authState = AuthState.loggedIn;
        _errorMessage = null;
      } else {
        _authState = AuthState.loggedOut;
      }
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = _messageFromError(e);
    }
    notifyListeners();
  }

  /// Continue as guest (no account)
  void continueAsGuest() {
    _authState = AuthState.guest;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Log in with email and password
  Future<bool> login({required String email, required String password}) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email: email, password: password);
      _currentUser = user;
      _authState = AuthState.loggedIn;
      notifyListeners();
      return true;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = _messageFromError(e);
      notifyListeners();
      return false;
    }
  }

  /// Register a new account
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _currentUser = user;
      _authState = AuthState.loggedIn;
      notifyListeners();
      return true;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = _messageFromError(e);
      notifyListeners();
      return false;
    }
  }

  /// Log out current user
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _authState = AuthState.loggedOut;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = _messageFromError(e);
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user profile.
  Future<void> updateProfile({String? name, String? phone}) async {
    if (_currentUser == null) return;

    try {
      _currentUser = await _authService.updateProfile(name: name, phone: phone);
      notifyListeners();
    } catch (e) {
      _errorMessage = _messageFromError(e);
      notifyListeners();
    }
  }

  /// Simulate loading account from website
  Future<bool> loadWebsiteAccount({
    required String email,
    required String password,
  }) async {
    return await login(email: email, password: password);
  }

  String _messageFromError(Object error) {
    if (error is AuthServiceException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
