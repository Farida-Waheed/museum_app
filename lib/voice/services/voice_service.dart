import 'dart:async';

import 'package:museum_app/accessibility/accessibility.dart';

import '../enums/voice_enums.dart';
import '../models/speech_config.dart';
import '../models/voice_command.dart';
import '../models/voice_content.dart';
import '../models/voice_message.dart';
import '../models/voice_status_snapshot.dart';
import 'voice_coordinator.dart';
import 'voice_queue_manager.dart';
import 'voice_settings_repository.dart';

/// The high-level, intention-revealing entry point to the Voice Communication
/// Engine for the rest of the app and for the AI / navigation adapters.
///
/// It is the seam that binds the personalization layer to playback: it turns an
/// [AccessibilityProfile] + session [VoicePreferences] into a [SpeechConfig] via
/// [VoiceSettingsRepository] and pushes it to the [VoiceCoordinator], then offers
/// a small verb-based API (speak / announce / listen / mute / pause / replay).
///
/// Everything above this line (screens, adapters, the reactive controller) talks
/// to [VoiceService]; everything below (queue, engines, robot floor) is hidden.
/// No consumer ever touches a TTS/STT plugin or the queue directly.
class VoiceService {
  VoiceService({
    required VoiceCoordinator coordinator,
    VoiceSettingsRepository? settings,
  })  : _coordinator = coordinator,
        _settings = settings ?? VoiceSettingsRepository() {
    // Persist engine-scoped nudges (louder/slower via voice command) back into
    // the durable session preferences so they survive the next launch.
    _coordinator.onConfigChanged = _persistNudge;
  }

  final VoiceCoordinator _coordinator;
  final VoiceSettingsRepository _settings;

  AccessibilityProfile _profile = AccessibilityProfile.initial;
  VoiceLanguage _language = VoiceLanguage.english;

  // --- Reactive plumbing exposed for the controller ---
  set onStatusChanged(void Function(VoiceStatusSnapshot status)? handler) =>
      _coordinator.onStatusChanged = handler;
  set onPartialTranscript(void Function(String partial)? handler) =>
      _coordinator.onPartialTranscript = handler;

  VoiceStatusSnapshot get status => _coordinator.status;
  SpeechConfig get config => _coordinator.config;
  VoicePreferences get preferences => _settings.preferences;
  VoiceLanguage get language => _language;
  bool get isMuted => _coordinator.isMuted;
  bool get isEnabled => _coordinator.config.enabled;

  // ---------------------------------------------------------------------------
  // Lifecycle & personalization
  // ---------------------------------------------------------------------------
  /// Load saved preferences, resolve the initial config from the profile, and
  /// bring up the engines. Safe to call once at startup.
  Future<void> initialize({
    required AccessibilityProfile profile,
    VoiceLanguage language = VoiceLanguage.english,
  }) async {
    _profile = profile;
    _language = language;
    await _settings.load();
    _pushConfig();
    await _coordinator.initialize();
    // Restore persisted mute without speaking anything.
    if (_settings.preferences.muted) {
      await _coordinator.setMuted(true);
    }
  }

  /// Re-resolve the speech config when the accessibility profile changes. This
  /// is what makes voice behavior track the Phase-2 profile automatically.
  void applyProfile(AccessibilityProfile profile) {
    _profile = profile;
    _pushConfig();
  }

  /// Switch the spoken language (follows the app locale by default).
  void setLanguage(VoiceLanguage language) {
    if (_language == language) return;
    _language = language;
    _pushConfig();
  }

  void _pushConfig() {
    final resolved = VoiceSettingsRepository.resolve(
      _profile,
      _settings.preferences,
      language: _language,
    );
    _coordinator.updateConfig(resolved);
  }

  // ---------------------------------------------------------------------------
  // Output
  // ---------------------------------------------------------------------------
  /// Speak already-structured content (the shape the AI/exhibit layer produces).
  VoiceEnqueueResult speakContent(
    VoiceContent content, {
    VoiceEventType event = VoiceEventType.genericNotice,
    VoicePriority? priority,
    VoiceLanguage? language,
  }) =>
      _coordinator.speak(VoiceMessage(
        content: content,
        event: event,
        priority: priority ?? event.defaultPriority,
        language: language ?? _language,
      ));

  /// Speak plain text (convenience for simple announcements).
  VoiceEnqueueResult announce(
    String text, {
    VoiceEventType event = VoiceEventType.genericNotice,
    VoicePriority? priority,
    VoiceLanguage? language,
  }) =>
      _coordinator.announce(
        text,
        event: event,
        priority: priority,
        language: language ?? _language,
      );

  /// Speak a fully-built message (used by adapters that construct their own).
  VoiceEnqueueResult speak(VoiceMessage message) => _coordinator.speak(message);

  // ---------------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------------
  /// Listen for one command. Engine-scoped commands (stop/louder/slower/repeat)
  /// are applied here; the parsed command is still returned so the app can react
  /// to app-scoped ones (start/next/previous tour, assistance).
  Future<VoiceCommand> listen() async {
    final command = await _coordinator.listenForCommand();
    await _coordinator.handleEngineCommand(command);
    return command;
  }

  Future<void> stopListening() => _coordinator.stopListening();

  // ---------------------------------------------------------------------------
  // Transport
  // ---------------------------------------------------------------------------
  Future<void> stop() => _coordinator.stopSpeaking();
  Future<void> pause() => _coordinator.pause();
  Future<void> resume() => _coordinator.resume();
  VoiceEnqueueResult replay() => _coordinator.replayLast();

  Future<void> setMuted(bool muted) async {
    await _coordinator.setMuted(muted);
    await _settings.update(_settings.preferences.copyWith(muted: muted));
  }

  Future<void> toggleMute() => setMuted(!_coordinator.isMuted);

  /// Explicit runtime setters (the controls bar) — persisted and re-pushed.
  Future<void> setVolume(double volume) async {
    await _settings.update(_settings.preferences.copyWith(volume: volume));
    _pushConfig();
  }

  Future<void> setSpeechRateBias(double rateBias) async {
    await _settings.update(_settings.preferences.copyWith(rateBias: rateBias));
    _pushConfig();
  }

  Future<void> setGender(VoiceGender gender) async {
    await _settings.update(_settings.preferences.copyWith(gender: gender));
    _pushConfig();
  }

  Future<void> _persistNudge(SpeechConfig config) async {
    final base = VoiceSettingsRepository.deriveFromProfile(
      _profile,
      language: _language,
    );
    await _settings.update(_settings.preferences.copyWith(
      volume: config.volume,
      rateBias: config.rate - base.rate,
    ));
  }

  Future<void> dispose() => _coordinator.dispose();
}
