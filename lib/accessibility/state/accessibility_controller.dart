import 'package:flutter/foundation.dart';

import '../../models/auth_provider.dart';
import '../../models/user_preferences.dart';
import '../enums/accessibility_enums.dart';
import '../models/accessibility_profile.dart';
import '../models/accessibility_tour_preferences.dart';
import '../models/display_settings.dart';
import '../models/emergency_settings.dart';
import '../models/interaction_settings.dart';
import '../models/navigation_settings.dart';
import '../models/voice_settings.dart';
import '../services/accessibility_service.dart';

/// The reactive, app-wide source of truth for the current visitor's
/// [AccessibilityProfile] (spec #6). A `ChangeNotifier` to stay consistent with
/// every other provider in the app (Auth, Tour, Chat, Robot, Tickets).
///
/// Responsibilities:
/// 1. Own the active profile and notify listeners on any change.
/// 2. Expose each settings group reactively (display / voice / navigation /
///    interaction / emergency / tour) plus convenience getters.
/// 3. Bridge display fields into the existing [UserPreferencesModel] so the
///    current MaterialApp theming pipeline keeps working untouched.
/// 4. Delegate ALL persistence to [AccessibilityService] — it never touches
///    Firebase or SharedPreferences itself (spec #5).
/// 5. Reconcile on auth transitions: adopt the account's cloud profile on login.
///
/// It deliberately does NOT publish to the robot or inject into the AI prompt —
/// those are owned by later phases, which read [profile] and its contracts.
class AccessibilityController extends ChangeNotifier {
  final UserPreferencesModel _preferences;
  final AuthProvider _auth;
  final AccessibilityService _service;

  AccessibilityProfile _profile;
  bool _isSyncing = false;
  bool _isCloudStale = false;
  String? _lastReconciledUid;

  AccessibilityController({
    required UserPreferencesModel preferences,
    required AuthProvider auth,
    required AccessibilityService service,
    required AccessibilityProfile initialProfile,
    bool initialCloudStale = false,
  })  : _preferences = preferences,
        _auth = auth,
        _service = service,
        _profile = initialProfile,
        _isCloudStale = initialCloudStale {
    _bridgeToPreferences(_profile);
    _lastReconciledUid = _auth.currentUser?.uid;
    _auth.addListener(_onAuthChanged);
  }

  // --- Reactive reads ---
  AccessibilityProfile get profile => _profile;
  Set<AccessibilityCategory> get categories => _profile.categories;
  AccessibilityCategory get primaryCategory => _profile.primaryCategory;
  bool hasCategory(AccessibilityCategory c) => _profile.hasCategory(c);
  DisplaySettings get display => _profile.display;
  VoiceSettings get voice => _profile.voice;
  NavigationSettings get navigation => _profile.navigation;
  InteractionSettings get interaction => _profile.interaction;
  EmergencySettings get emergency => _profile.emergency;
  AccessibilityTourPreferences get tour => _profile.tour;

  bool get isSyncing => _isSyncing;

  /// True when the local profile has changes not yet confirmed in the cloud
  /// (offline edit or a failed sync). UI can show a subtle "will sync" hint.
  bool get isCloudStale => _isCloudStale;

  bool get hasActiveNeeds => !_profile.isNeutral;
  bool get reduceMotion => _profile.display.reduceMotion;
  bool get captionsEnabled => _profile.interaction.captionsEnabled;

  /// Minimum interactive target size (dp) implied by the current profile.
  double get minTapTargetSize => _profile.display.largeTapTargets ? 56 : 48;

  // --- Mutators ---

  /// Apply a single category in one action ("configure everything at once").
  Future<void> selectCategory(AccessibilityCategory category) =>
      _commit(AccessibilityProfile.forCategory(category));

  /// Apply ANY combination of categories (Phase 2 multi-select). Preserves the
  /// visitor's later granular tweaks is the caller's responsibility; this maps
  /// the chosen needs to a coherent merged bundle.
  Future<void> selectCategories(Set<AccessibilityCategory> categories) =>
      _commit(AccessibilityProfile.forCategories(categories));

  /// Replace the entire profile (e.g. from the Phase 2 setup screen).
  Future<void> updateProfile(AccessibilityProfile next) => _commit(next);

  /// Group-level updates keep call sites clean and intention-revealing.
  Future<void> updateDisplay(DisplaySettings display) =>
      _commit(_profile.copyWith(display: display));
  Future<void> updateVoice(VoiceSettings voice) =>
      _commit(_profile.copyWith(voice: voice));
  Future<void> updateNavigation(NavigationSettings navigation) =>
      _commit(_profile.copyWith(navigation: navigation));
  Future<void> updateInteraction(InteractionSettings interaction) =>
      _commit(_profile.copyWith(interaction: interaction));
  Future<void> updateEmergency(EmergencySettings emergency) =>
      _commit(_profile.copyWith(emergency: emergency));
  Future<void> updateTour(AccessibilityTourPreferences tour) =>
      _commit(_profile.copyWith(tour: tour));

  Future<void> markSetupCompleted() =>
      _commit(_profile.copyWith(hasCompletedSetup: true));

  // ---------------------------------------------------------------------------
  // Core commit: memory → bridge → notify → persist (local always, cloud best).
  // ---------------------------------------------------------------------------
  Future<void> _commit(AccessibilityProfile next) async {
    final stamped = next.copyWith(
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    if (stamped.copyWith(updatedAtMs: _profile.updatedAtMs) == _profile) {
      return; // no semantic change; ignore timestamp-only diffs
    }
    _profile = stamped;
    _bridgeToPreferences(stamped);
    _isSyncing = true;
    _isCloudStale = _auth.isLoggedIn; // will clear if cloud write succeeds
    notifyListeners();

    final synced = await _service.persist(
      uid: _auth.isLoggedIn ? _auth.currentUser?.uid : null,
      profile: stamped,
    );
    _isSyncing = false;
    if (synced) _isCloudStale = false;
    notifyListeners();
  }

  /// Mirror display-relevant fields into the legacy [UserPreferencesModel],
  /// which the existing MaterialApp already consumes for font scaling and the
  /// high-contrast theme. This is what makes accessibility affect the WHOLE app
  /// without rewiring any existing screen. One-directional (profile → prefs);
  /// the controller never listens back, so there is no update loop.
  void _bridgeToPreferences(AccessibilityProfile profile) {
    if ((_preferences.fontScale - profile.display.textScale).abs() > 0.001) {
      _preferences.setFontScale(profile.display.textScale);
    }
    if (_preferences.isHighContrast != profile.display.highContrast) {
      _preferences.toggleHighContrast(profile.display.highContrast);
    }
  }

  // ---------------------------------------------------------------------------
  // Auth reconciliation — only on an actual login/logout transition.
  // ---------------------------------------------------------------------------
  Future<void> _onAuthChanged() async {
    final uid = _auth.currentUser?.uid;
    if (uid == _lastReconciledUid) return;
    _lastReconciledUid = uid;
    if (uid == null) return; // logout: keep current profile (shared-device safe)

    _isSyncing = true;
    notifyListeners();
    final result = await _service.reconcileForUser(uid, cached: _profile);
    _profile = result.profile;
    _isCloudStale = result.cloudFailed;
    _bridgeToPreferences(_profile);
    _isSyncing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
