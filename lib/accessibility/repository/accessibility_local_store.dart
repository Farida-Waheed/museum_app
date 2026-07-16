import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/accessibility_constants.dart';
import '../models/accessibility_profile.dart';

/// Device-local persistence for the accessibility profile (offline-first layer).
///
/// This is the durable store and the *only* store for guests (who have no
/// Firestore document). For logged-in users it is an instant cache so the
/// correct profile applies on the very first frame — before any network
/// round-trip — and continues to work fully offline.
///
/// The profile is one versioned JSON blob under a single key, mirroring exactly
/// the nested map used in Firestore, so both layers share one serialization path.
/// All methods swallow storage errors: a persistence fault must never crash
/// start-up; the in-memory profile stays authoritative.
class AccessibilityLocalStore {
  const AccessibilityLocalStore();

  Future<AccessibilityProfile> read() async =>
      await readOrNull() ?? AccessibilityProfile.initial;

  /// Returns `null` when NOTHING is stored (so the caller can distinguish
  /// "first run" → seed from legacy prefs, from "an explicitly-saved neutral
  /// profile"). A corrupt blob also returns null.
  Future<AccessibilityProfile?> readOrNull() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AccessibilityConstants.localCacheKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return AccessibilityProfile.fromStorageMap(
          decoded.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(AccessibilityProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AccessibilityConstants.localCacheKey,
        jsonEncode(profile.toStorageMap()),
      );
    } catch (_) {
      // Intentionally ignored (see class doc).
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AccessibilityConstants.localCacheKey);
    } catch (_) {
      // Intentionally ignored.
    }
  }
}
