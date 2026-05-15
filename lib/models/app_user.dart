import 'package:cloud_firestore/cloud_firestore.dart';

/// User account model.
///
/// Keeps the existing app-facing API while mapping to the Firebase users/{uid}
/// profile shape shared with the website.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? nationality;
  final String preferredLanguage;
  final String? avatarUrl;
  final int visitCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.nationality,
    required this.preferredLanguage,
    this.avatarUrl,
    this.visitCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy of this user with optional field overrides.
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? nationality,
    String? preferredLanguage,
    String? avatarUrl,
    int? visitCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      visitCount: visitCount ?? this.visitCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert user to legacy/local JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'nationality': nationality,
      'preferredLanguage': preferredLanguage,
      'avatarUrl': avatarUrl,
      'visitCount': visitCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert user to Firestore users/{uid} profile fields.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'display_name': name,
      'full_name': name,
      'email': email,
      'phone_number': phone,
      'nationality': nationality,
      'preferred_language': preferredLanguage,
      'avatar_url': avatarUrl,
      'accessibility_defaults': <String, dynamic>{},
      'marketing_opt_in': false,
    };
  }

  /// Create user from legacy/local JSON.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      nationality: json['nationality'] as String?,
      preferredLanguage: _normalizedLanguage(json['preferredLanguage']) ?? 'english',
      avatarUrl: json['avatarUrl'] as String?,
      visitCount: json['visitCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create user from Firestore users/{uid}.
  factory AppUser.fromFirestore(
    Map<String, dynamic> json, {
    required String fallbackUid,
  }) {
    final id = _stringValue(json['uid']) ?? fallbackUid;
    final email = _stringValue(json['email']) ?? '';
    final name =
        _stringValue(json['display_name']) ??
        _stringValue(json['full_name']) ??
        _nameFromEmail(email);

    return AppUser(
      id: id,
      name: name,
      email: email,
      phone: _stringValue(json['phone_number']),
      nationality: _stringValue(json['nationality']),
      preferredLanguage:
          _normalizedLanguage(json['preferred_language']) ?? 'english',
      avatarUrl: _stringValue(json['avatar_url']),
      visitCount: _intValue(json['visit_count']),
      createdAt: _dateValue(json['created_at']) ?? DateTime.now(),
      updatedAt: _dateValue(json['updated_at']),
    );
  }

  static String? _stringValue(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  static int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
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

  static String? _normalizedLanguage(Object? value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    switch (raw.toLowerCase().replaceAll('-', '_')) {
      case 'en':
      case 'english':
        return 'english';
      case 'ar':
      case 'arabic':
        return 'arabic';
      case 'egyptian_arabic':
        return 'egyptian_arabic';
      default:
        return raw.toLowerCase().replaceAll('-', '_');
    }
  }

  @override
  String toString() => 'AppUser(id: $id, name: $name, email: $email)';
}
