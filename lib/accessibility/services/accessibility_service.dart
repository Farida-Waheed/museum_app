import 'package:flutter/foundation.dart';

import '../models/accessibility_profile.dart';
import '../repository/accessibility_local_store.dart';
import '../repository/accessibility_repository.dart';

/// Outcome of a profile load, so callers can react to degraded states.
enum AccessibilitySource { cloud, cache, seeded, defaults }

@immutable
class AccessibilityLoadResult {
  final AccessibilityProfile profile;
  final AccessibilitySource source;
  final bool cloudFailed;

  const AccessibilityLoadResult({
    required this.profile,
    required this.source,
    this.cloudFailed = false,
  });
}

/// Global accessibility service (spec #5).
///
/// The single place that knows HOW to load, cache, and sync a profile. It hides
/// the local store and the cloud repository behind one API so the controller —
/// and therefore every widget — is storage-agnostic. No widget ever touches
/// Firebase or SharedPreferences directly.
///
/// Design points:
/// * Offline-first: the local cache is always written and is the fallback when
///   the cloud is unreachable.
/// * Best-effort cloud: cloud failures never propagate as crashes; they are
///   reported via flags so the UI can show a subtle "not synced" hint.
/// * Last-writer reconciliation: on login, the newer of {cloud, cache} wins
///   (by `updatedAtMs`), so a change made offline is not clobbered by an older
///   cloud copy, and vice-versa.
class AccessibilityService {
  final AccessibilityRepository _repository;
  final AccessibilityLocalStore _localStore;

  AccessibilityService({
    required AccessibilityRepository repository,
    AccessibilityLocalStore localStore = const AccessibilityLocalStore(),
  })  : _repository = repository,
        _localStore = localStore;

  /// Resolve the profile to apply at startup for a (possibly null) user.
  ///
  /// [legacyFallback] lets the caller seed from the app's pre-existing display
  /// preferences on first run so returning users lose nothing.
  Future<AccessibilityLoadResult> loadInitial({
    String? uid,
    AccessibilityProfile? legacyFallback,
  }) async {
    final cached = await _localStore.readOrNull();

    // Guest / offline: cache or seed.
    if (uid == null) {
      if (cached != null) {
        return AccessibilityLoadResult(
            profile: cached, source: AccessibilitySource.cache);
      }
      if (legacyFallback != null) {
        await _localStore.write(legacyFallback);
        return AccessibilityLoadResult(
            profile: legacyFallback, source: AccessibilitySource.seeded);
      }
      return AccessibilityLoadResult(
          profile: AccessibilityProfile.initial,
          source: AccessibilitySource.defaults);
    }

    // Logged in: reconcile cloud with cache.
    return reconcileForUser(uid, cached: cached, legacyFallback: legacyFallback);
  }

  /// Adopt the correct profile for [uid] on login, reconciling with any local
  /// [cached] copy. Never throws — cloud failure degrades to cache/defaults.
  Future<AccessibilityLoadResult> reconcileForUser(
    String uid, {
    AccessibilityProfile? cached,
    AccessibilityProfile? legacyFallback,
  }) async {
    final localCache = cached ?? await _localStore.readOrNull();
    AccessibilityProfile? cloud;
    var cloudFailed = false;
    try {
      cloud = await _repository.fetch(uid);
    } catch (_) {
      cloudFailed = true; // offline or permission hiccup; degrade gracefully
    }

    // Cloud has a profile: newer of cloud/cache wins.
    if (cloud != null) {
      final winner = (localCache != null &&
              localCache.updatedAtMs > cloud.updatedAtMs)
          ? localCache
          : cloud;
      await _localStore.write(winner);
      // If the local copy was newer, push it up so the cloud catches up.
      if (identical(winner, localCache) && !cloudFailed) {
        await _trySave(uid, winner);
      }
      return AccessibilityLoadResult(
        profile: winner,
        source: AccessibilitySource.cloud,
        cloudFailed: cloudFailed,
      );
    }

    // Account has no cloud profile yet. Use cache or seed, and back it up.
    final resolved = localCache ?? legacyFallback ?? AccessibilityProfile.initial;
    await _localStore.write(resolved);
    if (!resolved.isNeutral && !cloudFailed) {
      await _trySave(uid, resolved);
    }
    return AccessibilityLoadResult(
      profile: resolved,
      source: localCache != null
          ? AccessibilitySource.cache
          : (legacyFallback != null
              ? AccessibilitySource.seeded
              : AccessibilitySource.defaults),
      cloudFailed: cloudFailed,
    );
  }

  /// Persist a changed profile: local first (always), cloud best-effort.
  /// Returns true if the cloud write succeeded (false when guest or offline).
  Future<bool> persist({
    String? uid,
    required AccessibilityProfile profile,
  }) async {
    await _localStore.write(profile);
    if (uid == null) return false;
    return _trySave(uid, profile);
  }

  Future<bool> _trySave(String uid, AccessibilityProfile profile) async {
    try {
      await _repository.save(uid, profile);
      return true;
    } catch (_) {
      return false; // stays cached; next successful mutation re-syncs
    }
  }
}
