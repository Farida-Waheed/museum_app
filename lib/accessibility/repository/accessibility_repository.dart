import '../models/accessibility_profile.dart';

/// Abstraction over cloud persistence of the accessibility profile (SOLID / DIP).
///
/// The service depends on this interface, never on Firebase directly, so:
/// * widgets and the controller stay Firebase-agnostic (spec #5),
/// * the cloud backend can be swapped or faked in tests without touching callers.
///
/// Implementations are responsible ONLY for the remote copy; the local cache is
/// handled separately by [AccessibilityLocalStore].
abstract class AccessibilityRepository {
  /// Loads the profile for [uid], or `null` if the account has none stored yet.
  /// Must not throw for "not found"; throws only on genuine backend errors so
  /// the service can decide how to degrade.
  Future<AccessibilityProfile?> fetch(String uid);

  /// Persists [profile] for [uid]. Implementations must be idempotent and safe
  /// to call repeatedly (merge semantics).
  Future<void> save(String uid, AccessibilityProfile profile);
}
