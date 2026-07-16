import 'dart:async';

import 'package:flutter/foundation.dart';

import '../engine/audio_session_manager.dart';
import '../engine/speech_recognizer.dart';
import '../engine/tts_engine.dart';
import '../enums/voice_enums.dart';
import '../models/speech_config.dart';
import '../models/voice_command.dart';
import '../models/voice_message.dart';
import '../models/voice_status_snapshot.dart';
import 'robot_speech_coordinator.dart';
import 'voice_command_parser.dart';
import 'voice_queue_manager.dart';

/// The single arbiter of everything spoken and heard. EVERY producer — AI,
/// navigation, notifications, the robot bridge, future features — routes through
/// [speak]/[announce]; no widget or service ever calls a TTS/STT engine directly.
///
/// It composes the decoupled pieces built earlier:
/// * [VoiceQueueManager]        — ordering / dedup / interruption *policy*.
/// * [TtsEngine]                — synthesis *mechanism* (fake or plugin).
/// * [SpeechRecognizer]         — command capture (fake or plugin).
/// * [RobotSpeechCoordinator]   — the shared speaking-floor with the robot.
/// * [AudioSessionManager]      — focus/route (phone calls, headphones).
/// * [VoiceCommandParser]       — utterance → intent.
///
/// The coordinator only sequences those parts and holds transient runtime state
/// (config, mute/pause, status). It exposes plain callbacks rather than a
/// Flutter dependency so it stays testable head-lessly; the [VoiceController]
/// adapts it to `ChangeNotifier` for the UI.
class VoiceCoordinator {
  VoiceCoordinator({
    required TtsEngine tts,
    required SpeechRecognizer recognizer,
    VoiceQueueManager? queue,
    RobotSpeechCoordinator? robot,
    AudioSessionManager? audio,
    VoiceCommandParser parser = const VoiceCommandParser(),
    SpeechConfig config = SpeechConfig.disabled,
  })  : _tts = tts,
        _recognizer = recognizer,
        _queue = queue ?? VoiceQueueManager(),
        _robot = robot ?? RobotSpeechCoordinator(),
        _audio = audio ?? NoopAudioSessionManager(),
        _parser = parser,
        _config = config;

  final TtsEngine _tts;
  final SpeechRecognizer _recognizer;
  final VoiceQueueManager _queue;
  final RobotSpeechCoordinator _robot;
  final AudioSessionManager _audio;
  final VoiceCommandParser _parser;

  SpeechConfig _config;
  bool _muted = false;
  bool _paused = false;
  bool _draining = false;
  bool _initialized = false;
  VoiceMessage? _lastReplayable;
  int _replaySeq = 0;

  VoiceStatusSnapshot _status = VoiceStatusSnapshot.initial;

  // --- Callbacks (kept plugin/Flutter-free so this is head-lessly testable) ---
  void Function(VoiceStatusSnapshot status)? onStatusChanged;
  void Function(SpeechConfig config)? onConfigChanged;
  void Function(String partial)? onPartialTranscript;

  VoiceStatusSnapshot get status => _status;
  SpeechConfig get config => _config;
  bool get isMuted => _muted;
  bool get isPaused => _paused;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _audio.initialize();
    final ttsOk = await _tts.initialize();
    // Late mic init happens on first listen; report current availability.
    _tts.onComplete = null; // playback completion is awaited in _drain instead
    _robot.onRobotFreed = () => unawaited(_drain());
    _audio.onFocusChanged = _handleFocusChange;
    _emit(_status.copyWith(
      ttsAvailable: ttsOk,
      micAvailable: _recognizer.isAvailable,
      status: ttsOk ? VoiceStatus.ready : VoiceStatus.unavailable,
    ));
  }

  /// Update the resolved speech config (called by the controller when the
  /// accessibility profile or session preferences change).
  void updateConfig(SpeechConfig config) {
    _config = config;
    unawaited(_tts.applyConfig(config));
  }

  // ---------------------------------------------------------------------------
  // Speaking — the one entry point for all output.
  // ---------------------------------------------------------------------------
  /// Offer a message to the engine. Honours mute (non-critical suppressed),
  /// dedup, priority, and interruption. Returns how the queue handled it.
  VoiceEnqueueResult speak(VoiceMessage message) {
    // Master enable + mute: only critical (safety) speech survives.
    if ((!_config.enabled || _muted) && !message.isCritical) {
      return VoiceEnqueueResult.dropped;
    }

    final willInterrupt = _queue.wouldInterrupt(message);
    final result = _queue.enqueue(message);

    if (result == VoiceEnqueueResult.interrupt || willInterrupt) {
      // Cut off the current utterance; the awaited speak in _drain completes and
      // the loop picks the now-highest-priority head next.
      unawaited(_tts.stop());
    }
    if (result == VoiceEnqueueResult.queued ||
        result == VoiceEnqueueResult.interrupt) {
      _emit(_status.copyWith(pending: _queue.length));
      unawaited(_drain());
    }
    return result;
  }

  /// Convenience: speak plain text as an event.
  VoiceEnqueueResult announce(
    String text, {
    VoiceEventType event = VoiceEventType.genericNotice,
    VoicePriority? priority,
    VoiceLanguage? language,
  }) =>
      speak(VoiceMessage.text(
        text,
        event: event,
        priority: priority ?? event.defaultPriority,
        language: language ?? _config.language,
      ));

  Future<void> _drain() async {
    if (_draining || _paused) return;
    _draining = true;
    try {
      while (!_paused) {
        final head = _queue.pending.isEmpty ? null : _queue.pending.first;
        if (head == null) break;

        // Robot floor: essential messages silence the robot; non-essential wait.
        final gotFloor = await _robot.acquireFloor(head.priority);
        if (!gotFloor) break; // robot is speaking; onRobotFreed re-kicks drain

        // Audio focus: yield to phone calls / other media.
        final gotFocus = await _audio.requestFocus();
        if (!gotFocus) {
          await _robot.releaseFloor();
          break;
        }

        final message = _queue.takeNext();
        if (message == null) {
          await _robot.releaseFloor();
          break;
        }

        _emit(_status.copyWith(
          status: VoiceStatus.speaking,
          nowSpeaking: message.text,
          pending: _queue.length,
        ));

        await _tts.speak(message.content, _configForMessage(message));

        if (message.replayable) _lastReplayable = message;
        _queue.completeCurrent();
        await _robot.releaseFloor();
      }
    } finally {
      _draining = false;
      if (_queue.isEmpty && !_paused) {
        await _audio.abandonFocus();
        _emit(_status.copyWith(
          status: _muted ? VoiceStatus.muted : VoiceStatus.ready,
          clearNowSpeaking: true,
          pending: 0,
        ));
      }
    }
  }

  SpeechConfig _configForMessage(VoiceMessage message) =>
      message.language == _config.language
          ? _config
          : _config.copyWith(language: message.language);

  // ---------------------------------------------------------------------------
  // Transport controls
  // ---------------------------------------------------------------------------
  Future<void> stopSpeaking() async {
    _queue.clear();
    await _tts.stop();
    _queue.completeCurrent();
    await _robot.releaseFloor();
    await _audio.abandonFocus();
    _emit(_status.copyWith(
      status: _muted ? VoiceStatus.muted : VoiceStatus.ready,
      clearNowSpeaking: true,
      pending: 0,
    ));
  }

  Future<void> pause() async {
    if (_paused) return;
    _paused = true;
    await _tts.pause();
    _emit(_status.copyWith(status: VoiceStatus.paused));
  }

  Future<void> resume() async {
    if (!_paused) return;
    _paused = false;
    await _tts.resume();
    _emit(_status.copyWith(status: VoiceStatus.ready));
    unawaited(_drain());
  }

  Future<void> setMuted(bool muted) async {
    if (_muted == muted) return;
    _muted = muted;
    if (muted) {
      _queue.clear();
      await _tts.stop();
      _queue.completeCurrent();
      await _robot.releaseFloor();
      _emit(_status.copyWith(
        status: VoiceStatus.muted,
        muted: true,
        clearNowSpeaking: true,
        pending: 0,
      ));
    } else {
      _emit(_status.copyWith(status: VoiceStatus.ready, muted: false));
    }
  }

  /// Re-speak the last replayable message (the "repeat" command / replay button).
  VoiceEnqueueResult replayLast() {
    final last = _lastReplayable;
    if (last == null) return VoiceEnqueueResult.dropped;
    // Fresh dedup key so it is not suppressed as a duplicate of itself.
    return speak(VoiceMessage(
      content: last.content,
      event: last.event,
      priority: VoicePriority.interactive,
      language: last.language,
      dedupKey: 'replay:${last.id}:${_replaySeq++}',
    ));
  }

  // ---------------------------------------------------------------------------
  // Listening / command pipeline
  // ---------------------------------------------------------------------------
  /// Listen for a single spoken command and parse it. Never throws: an
  /// unavailable/denied mic returns [VoiceCommand.unknown] and flips
  /// [VoiceStatusSnapshot.micAvailable] false so the UI falls back to touch.
  Future<VoiceCommand> listenForCommand() async {
    if (!_recognizer.isAvailable) {
      final ok = await _recognizer.initialize();
      _emit(_status.copyWith(micAvailable: ok));
      if (!ok) return VoiceCommand.unknown;
    }

    final previous = _status.status;
    _emit(_status.copyWith(status: VoiceStatus.listening, micAvailable: true));
    SpeechRecognitionResult result;
    try {
      result = await _recognizer.listen(
        language: _config.language,
        onPartial: (p) => onPartialTranscript?.call(p),
      );
    } catch (e) {
      debugPrint('VoiceCoordinator listen error: $e');
      result = const SpeechRecognitionResult(
          outcome: SpeechRecognitionOutcome.error);
    }

    _emit(_status.copyWith(
      status: previous == VoiceStatus.listening ? VoiceStatus.ready : previous,
      micAvailable: !result.outcome.isFallbackToTouch,
    ));

    if (!result.hasTranscript) return VoiceCommand.unknown;
    return _parser.parse(
      result.transcript,
      confidence: result.confidence,
      language: result.language,
    );
  }

  Future<void> stopListening() => _recognizer.stop();

  /// Handle the engine-scoped commands (speech transport + audio nudges) and
  /// report whether it was consumed. App-scoped commands (start/next/previous
  /// tour, assistance, etc.) return false so the app layer handles them — this
  /// keeps command *routing* centralized while leaving app *actions* to the app.
  Future<bool> handleEngineCommand(VoiceCommand command) async {
    if (!command.isActionable) return false;
    switch (command.intent) {
      case VoiceCommandIntent.stopSpeaking:
        await stopSpeaking();
        return true;
      case VoiceCommandIntent.repeatExplanation:
        replayLast();
        return true;
      case VoiceCommandIntent.increaseVolume:
        _nudgeConfig(_config.copyWith(volume: _config.volume + 0.1));
        return true;
      case VoiceCommandIntent.decreaseVolume:
        _nudgeConfig(_config.copyWith(volume: _config.volume - 0.1));
        return true;
      case VoiceCommandIntent.fasterSpeech:
        _nudgeConfig(_config.copyWith(rate: _config.rate + 0.1));
        return true;
      case VoiceCommandIntent.slowerSpeech:
        _nudgeConfig(_config.copyWith(rate: _config.rate - 0.1));
        return true;
      default:
        return false; // app-scoped
    }
  }

  void _nudgeConfig(SpeechConfig next) {
    _config = next;
    unawaited(_tts.applyConfig(next));
    onConfigChanged?.call(next);
  }

  // ---------------------------------------------------------------------------
  // Audio focus reactions (phone calls / other apps grabbing audio)
  // ---------------------------------------------------------------------------
  void _handleFocusChange(AudioFocusState state) {
    switch (state) {
      case AudioFocusState.active:
        if (_paused) unawaited(resume());
        break;
      case AudioFocusState.transientLoss:
      case AudioFocusState.lost:
        unawaited(pause());
        break;
    }
  }

  void _emit(VoiceStatusSnapshot next) {
    if (next == _status) return;
    _status = next;
    onStatusChanged?.call(next);
  }

  Future<void> dispose() async {
    await _tts.dispose();
    await _recognizer.dispose();
    await _audio.dispose();
  }
}
