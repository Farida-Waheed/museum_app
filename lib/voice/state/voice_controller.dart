import 'package:flutter/foundation.dart';
import 'package:museum_app/accessibility/accessibility.dart';

import '../enums/voice_enums.dart';
import '../integration/ai_voice_adapter.dart';
import '../integration/voice_feature_registration.dart';
import '../integration/voice_navigation_announcer.dart';
import '../models/voice_command.dart';
import '../models/voice_status_snapshot.dart';
import '../services/voice_service.dart';

/// The reactive, app-wide face of the Voice Communication Engine — a
/// `ChangeNotifier`, consistent with every other provider in the app (Auth,
/// Tour, Chat, Robot, Accessibility) and with the Phase 1 decision to avoid a
/// second state paradigm.
///
/// Responsibilities:
/// 1. Own the live [VoiceStatusSnapshot] and notify the UI on every change.
/// 2. Bridge the [AccessibilityController] into the engine — when the profile
///    changes, re-resolve the speech config so voice behavior tracks the
///    Phase-2 profile with no per-screen wiring.
/// 3. Track the app language so speech follows the locale.
/// 4. Expose intention-revealing actions (speak / listen / mute / pause /
///    replay) and the navigation + AI adapters, so screens never reach into the
///    coordinator, queue, or plugins.
///
/// All speech still flows through the single [VoiceService]/coordinator; this
/// class only adapts it to Flutter's listenable model.
class VoiceController extends ChangeNotifier {
  VoiceController({
    required VoiceService service,
    required AccessibilityController accessibility,
    String initialLanguage = 'en',
  })  : _service = service,
        _accessibility = accessibility,
        _language = VoiceLanguage.fromCode(initialLanguage) {
    navigation = VoiceNavigationAnnouncer(_service);
    ai = AiVoiceAdapter(_service);
    VoiceFeatureRegistration.register();

    _service.onStatusChanged = _onStatusChanged;
    _service.onPartialTranscript = _onPartial;
    _accessibility.addListener(_onAccessibilityChanged);
  }

  final VoiceService _service;
  final AccessibilityController _accessibility;

  /// Guidance seam for navigation/tour/robot producers.
  late final VoiceNavigationAnnouncer navigation;

  /// Voice-enable AI/exhibit responses.
  late final AiVoiceAdapter ai;

  VoiceLanguage _language;
  VoiceStatusSnapshot _status = VoiceStatusSnapshot.initial;
  String _partialTranscript = '';
  bool _initialized = false;

  // --- Reactive reads -------------------------------------------------------
  VoiceStatusSnapshot get status => _status;
  VoiceStatus get state => _status.status;
  bool get isSpeaking => _status.isSpeaking;
  bool get isListening => _status.isListening;
  bool get isPaused => _status.isPaused;
  bool get isMuted => _status.muted;
  bool get isEnabled => _service.isEnabled;
  bool get micAvailable => _status.micAvailable;
  bool get ttsAvailable => _status.ttsAvailable;
  int get pending => _status.pending;
  String? get nowSpeaking => _status.nowSpeaking;
  String get partialTranscript => _partialTranscript;
  VoiceLanguage get language => _language;

  /// Bring up the engine with the current profile + language. Call once after
  /// providers are ready (e.g. from the first screen or app bootstrap).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _service.initialize(
      profile: _accessibility.profile,
      language: _language,
    );
    notifyListeners();
  }

  /// Follow the app locale for spoken output.
  void setLanguageCode(String code) {
    final next = VoiceLanguage.fromCode(code);
    if (next == _language) return;
    _language = next;
    _service.setLanguage(next);
    notifyListeners();
  }

  // --- Activity (drives context-aware gating in the announcer) --------------
  void setActivity(VoiceActivity activity) =>
      navigation.setActivity(activity);

  // --- Transport / controls -------------------------------------------------
  Future<void> stop() => _service.stop();
  Future<void> pause() => _service.pause();
  Future<void> resume() => _service.resume();
  void replay() => _service.replay();
  Future<void> toggleMute() => _service.toggleMute();
  Future<void> setMuted(bool muted) => _service.setMuted(muted);
  Future<void> setVolume(double v) => _service.setVolume(v);
  Future<void> setSpeechRateBias(double bias) => _service.setSpeechRateBias(bias);
  Future<void> setGender(VoiceGender g) => _service.setGender(g);

  /// Speak a plain announcement (screens that just need a quick spoken notice).
  void announce(String text, {VoiceLanguage? language}) =>
      _service.announce(text, language: language ?? _language);

  /// Listen for one command; engine-scoped ones are handled inside the service,
  /// app-scoped ones are returned for the caller to act on.
  Future<VoiceCommand> listen() async {
    final command = await _service.listen();
    _partialTranscript = '';
    notifyListeners();
    return command;
  }

  Future<void> stopListening() => _service.stopListening();

  // --- Internal reactions ---------------------------------------------------
  void _onStatusChanged(VoiceStatusSnapshot status) {
    if (status == _status) return;
    _status = status;
    notifyListeners();
  }

  void _onPartial(String partial) {
    _partialTranscript = partial;
    notifyListeners();
  }

  void _onAccessibilityChanged() {
    // Re-resolve speech parameters from the updated profile. Cheap and
    // idempotent — the coordinator no-ops if the resolved config is unchanged.
    _service.applyProfile(_accessibility.profile);
  }

  @override
  void dispose() {
    _accessibility.removeListener(_onAccessibilityChanged);
    _service.onStatusChanged = null;
    _service.onPartialTranscript = null;
    _service.dispose();
    super.dispose();
  }
}
