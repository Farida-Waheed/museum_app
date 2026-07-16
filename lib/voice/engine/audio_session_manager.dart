/// How the app should currently behave with respect to shared audio output.
enum AudioFocusState {
  /// We hold focus and may speak.
  active('active'),

  /// Another app took focus transiently (e.g. a notification chime); we should
  /// pause and resume when it returns.
  transientLoss('transient_loss'),

  /// We lost focus indefinitely (a phone call, another media app started); we
  /// should stop and wait for focus to return.
  lost('lost');

  const AudioFocusState(this.storageKey);
  final String storageKey;
}

/// The current output route, so the UI can hint where sound is going and the
/// coordinator can decide robot-vs-phone playback.
enum AudioRoute {
  speaker('speaker'),
  headphones('headphones'),
  bluetooth('bluetooth'),
  robotSpeaker('robot_speaker'),
  unknown('unknown');

  const AudioRoute(this.storageKey);
  final String storageKey;
}

/// Abstract audio-session/focus manager. Wraps whatever platform mechanism
/// governs audio focus, ducking, and route changes behind one contract so the
/// coordinator can react to phone calls, headphone unplugs, and other apps
/// grabbing audio — without importing any plugin.
///
/// Implementations:
/// * `PlatformAudioSessionManager` — production (audio focus + route via the
///   platform / a plugin).
/// * `NoopAudioSessionManager`     — always-active default and test double, so
///   the engine runs fully without any audio-session dependency.
abstract class AudioSessionManager {
  Future<void> initialize();

  AudioFocusState get focusState;
  AudioRoute get route;

  /// Request focus before speaking. Returns false if focus is denied (e.g. an
  /// active call) — the coordinator then holds the message.
  Future<bool> requestFocus();

  /// Release focus after the queue drains, so other apps resume.
  Future<void> abandonFocus();

  /// Fires when focus changes (call starts/ends, other media app). The
  /// coordinator pauses/resumes/stops accordingly.
  set onFocusChanged(void Function(AudioFocusState state)? handler);

  /// Fires when the output route changes (headphones unplugged → speaker).
  set onRouteChanged(void Function(AudioRoute route)? handler);

  Future<void> dispose();
}

/// Default no-op manager: focus is always granted, route is speaker. Lets the
/// whole engine run (and every test pass) without a real audio-session plugin.
/// Production can swap in a platform implementation with no coordinator change.
class NoopAudioSessionManager implements AudioSessionManager {
  AudioFocusState _focus = AudioFocusState.active;

  @override
  Future<void> initialize() async {}

  @override
  AudioFocusState get focusState => _focus;

  @override
  AudioRoute get route => AudioRoute.speaker;

  @override
  Future<bool> requestFocus() async {
    _focus = AudioFocusState.active;
    return true;
  }

  @override
  Future<void> abandonFocus() async {}

  @override
  set onFocusChanged(void Function(AudioFocusState state)? handler) {}

  @override
  set onRouteChanged(void Function(AudioRoute route)? handler) {}

  @override
  Future<void> dispose() async {}
}
