/// User account model
/// Represents a logged-in user's account information
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String preferredLanguage;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.preferredLanguage,
    required this.createdAt,
  });

  /// Create a copy of this user with optional field overrides
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? preferredLanguage,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create user from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() => 'AppUser(id: $id, name: $name, email: $email)';
}
