import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared account profile for Firebase Auth users/{uid}.
///
/// The Firestore document id must be the Firebase Auth uid. Legacy getters
/// remain so existing app screens can keep reading `id`, `name`, and `phone`.
class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final String displayName;
  final String? phoneNumber;
  final String? nationality;
  final String preferredLanguage;
  final String? avatarUrl;
  final Map<String, dynamic> accessibilityDefaults;
  final bool marketingOptIn;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSeenAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.displayName,
    this.phoneNumber,
    this.nationality,
    required this.preferredLanguage,
    this.avatarUrl,
    Map<String, dynamic>? accessibilityDefaults,
    this.marketingOptIn = false,
    required this.createdAt,
    this.updatedAt,
    this.lastSeenAt,
  }) : accessibilityDefaults = accessibilityDefaults ?? <String, dynamic>{};

  String get id => uid;
  String get name => displayName.isNotEmpty ? displayName : fullName;
  String? get phone => phoneNumber;
  int get visitCount => 0;

  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? displayName,
    String? phoneNumber,
    String? nationality,
    String? preferredLanguage,
    String? avatarUrl,
    Map<String, dynamic>? accessibilityDefaults,
    bool? marketingOptIn,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeenAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationality: nationality ?? this.nationality,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accessibilityDefaults:
          accessibilityDefaults ?? Map<String, dynamic>.from(this.accessibilityDefaults),
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  /// Convert user to legacy/local JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'uid': uid,
      'name': name,
      'email': email,
      'fullName': fullName,
      'displayName': displayName,
      'phone': phoneNumber,
      'phoneNumber': phoneNumber,
      'nationality': nationality,
      'preferredLanguage': preferredLanguage,
      'avatarUrl': avatarUrl,
      'accessibilityDefaults': accessibilityDefaults,
      'marketingOptIn': marketingOptIn,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastSeenAt': lastSeenAt?.toIso8601String(),
    };
  }

  /// Convert user to Firestore users/{uid} profile fields.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'full_name': fullName,
      'display_name': displayName,
      'phone_number': phoneNumber,
      'nationality': nationality,
      'preferred_language': normalizeAccountLanguage(preferredLanguage),
      'avatar_url': avatarUrl,
      'accessibility_defaults': accessibilityDefaults,
      'marketing_opt_in': marketingOptIn,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final email = _stringValue(json['email']) ?? '';
    final fullName =
        _stringValue(json['fullName']) ??
        _stringValue(json['full_name']) ??
        _stringValue(json['name']) ??
        _nameFromEmail(email);
    final displayName =
        _stringValue(json['displayName']) ??
        _stringValue(json['display_name']) ??
        _stringValue(json['name']) ??
        fullName;

    return AppUser(
      uid: _stringValue(json['uid']) ?? _stringValue(json['id']) ?? '',
      email: email,
      fullName: fullName,
      displayName: displayName,
      phoneNumber:
          _stringValue(json['phoneNumber']) ??
          _stringValue(json['phone_number']) ??
          _stringValue(json['phone']),
      nationality: _stringValue(json['nationality']),
      preferredLanguage: normalizeAccountLanguage(
        json['preferredLanguage'] ?? json['preferred_language'],
      ),
      avatarUrl:
          _stringValue(json['avatarUrl']) ?? _stringValue(json['avatar_url']),
      accessibilityDefaults: _mapValue(
        json['accessibilityDefaults'] ?? json['accessibility_defaults'],
      ),
      marketingOptIn:
          json['marketingOptIn'] is bool
              ? json['marketingOptIn'] as bool
              : json['marketing_opt_in'] == true,
      createdAt:
          _dateValue(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
      updatedAt: _dateValue(json['updatedAt'] ?? json['updated_at']),
      lastSeenAt: _dateValue(json['lastSeenAt'] ?? json['last_seen_at']),
    );
  }

  factory AppUser.fromFirestore(
    Map<String, dynamic> json, {
    required String fallbackUid,
  }) {
    final email = _stringValue(json['email']) ?? '';
    final fullName =
        _stringValue(json['full_name']) ??
        _stringValue(json['display_name']) ??
        _stringValue(json['name']) ??
        _nameFromEmail(email);
    final displayName =
        _stringValue(json['display_name']) ??
        _stringValue(json['full_name']) ??
        fullName;

    return AppUser(
      uid: fallbackUid,
      email: email,
      fullName: fullName,
      displayName: displayName,
      phoneNumber: _stringValue(json['phone_number']),
      nationality: _stringValue(json['nationality']),
      preferredLanguage: normalizeAccountLanguage(json['preferred_language']),
      avatarUrl: _stringValue(json['avatar_url']),
      accessibilityDefaults: _mapValue(json['accessibility_defaults']),
      marketingOptIn: json['marketing_opt_in'] == true,
      createdAt: _dateValue(json['created_at']) ?? DateTime.now(),
      updatedAt: _dateValue(json['updated_at']),
      lastSeenAt: _dateValue(json['last_seen_at']),
    );
  }

  static String normalizeAccountLanguage(Object? value) {
    final raw = value?.toString().trim().toLowerCase().replaceAll('-', '_');
    switch (raw) {
      case 'ar':
      case 'arabic':
        return 'arabic';
      case 'en':
      case 'english':
        return 'english';
      default:
        return 'english';
    }
  }

  static String languageCodeFromAccount(String preferredLanguage) {
    return normalizeAccountLanguage(preferredLanguage) == 'arabic' ? 'ar' : 'en';
  }

  static String accountLanguageFromCode(String languageCode) {
    return languageCode.toLowerCase().startsWith('ar') ? 'arabic' : 'english';
  }

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static Map<String, dynamic> _mapValue(Object? value) {
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  static DateTime? _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String _nameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    return localPart.isEmpty ? 'Museum Visitor' : localPart;
  }

  @override
  String toString() => 'AppUser(uid: $uid, displayName: $displayName, email: $email)';
}
