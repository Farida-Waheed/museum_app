import 'package:flutter/material.dart';
import 'app_user.dart';
import 'user_preferences.dart';
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
  final UserPreferencesModel? _preferences;

  AuthState _authState = AuthState.guest;
  AppUser? _currentUser;
  String? _errorMessage;

  AuthProvider(this._authService, {UserPreferencesModel? preferences})
    : _preferences = preferences {
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
        await _restoreLanguageFromAccount(user);
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
      await _restoreLanguageFromAccount(user);
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
        preferredLanguage: _accountLanguageFromPrefs(),
      );
      _currentUser = user;
      _authState = AuthState.loggedIn;
      await _restoreLanguageFromAccount(user);
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
  Future<void> updateProfile({
    String? fullName,
    String? displayName,
    String? phoneNumber,
    String? nationality,
    String? preferredLanguage,
    String? avatarUrl,
    Map<String, dynamic>? accessibilityDefaults,
    bool? marketingOptIn,
  }) async {
    if (_currentUser == null) return;

    try {
      _currentUser = await _authService.updateProfile(
        fullName: fullName,
        displayName: displayName,
        phoneNumber: phoneNumber,
        nationality: nationality,
        preferredLanguage: preferredLanguage,
        avatarUrl: avatarUrl,
        accessibilityDefaults: accessibilityDefaults,
        marketingOptIn: marketingOptIn,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = _messageFromError(e);
      notifyListeners();
    }
  }

  /// Sign in to the same Firebase account used by the web app.
  Future<bool> loadWebsiteAccount({
    required String email,
    required String password,
  }) async {
    return await login(email: email, password: password);
  }

  Future<void> updatePreferredLanguageFromUi(String languageCode) async {
    if (_currentUser == null) return;
    await updateProfile(
      preferredLanguage: AppUser.accountLanguageFromCode(languageCode),
    );
  }

  Future<void> _restoreLanguageFromAccount(AppUser user) async {
    final preferences = _preferences;
    if (preferences == null) return;
    await preferences.setLanguage(
      AppUser.languageCodeFromAccount(user.preferredLanguage),
    );
  }

  String _accountLanguageFromPrefs() {
    return AppUser.accountLanguageFromCode(_preferences?.language ?? 'en');
  }

  String _messageFromError(Object error) {
    if (error is AuthServiceException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
