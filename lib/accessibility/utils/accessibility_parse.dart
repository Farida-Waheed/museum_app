/// Null-safe, forward-compatible parsing helpers for accessibility storage maps.
///
/// Every value read from SharedPreferences or Firestore passes through here so
/// that corrupt, partial, or newer-version data can never throw — it degrades
/// to a safe default instead. This is the backbone of the module's
/// "no accessibility fault ever crashes the app" guarantee.
library;

class AccessibilityParse {
  const AccessibilityParse._();

  static bool asBool(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = value?.toString().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fallback;
  }

  static int asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double asDouble(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed == null || parsed.isNaN) return fallback;
    return parsed;
  }

  static double asClampedDouble(
    Object? value, {
    required double min,
    required double max,
    required double fallback,
  }) {
    final d = asDouble(value, fallback: fallback);
    return d.clamp(min, max).toDouble();
  }

  static String asString(Object? value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  /// Safely extracts a nested settings sub-map (e.g. `display_settings`).
  static Map<String, dynamic> asMap(Object? value) {
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }
}
