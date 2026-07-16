import '../enums/voice_enums.dart';

/// An immutable snapshot of the engine's live state for the UI status indicator
/// and controls. The [VoiceController] rebuilds one of these on every change so
/// widgets render from a single, consistent value instead of many getters.
class VoiceStatusSnapshot {
  final VoiceStatus status;

  /// The text currently being spoken (for a live-caption / "now speaking" strip).
  final String? nowSpeaking;

  /// Number of messages waiting behind the current one.
  final int pending;

  final bool muted;
  final bool micAvailable;
  final bool ttsAvailable;

  const VoiceStatusSnapshot({
    this.status = VoiceStatus.ready,
    this.nowSpeaking,
    this.pending = 0,
    this.muted = false,
    this.micAvailable = false,
    this.ttsAvailable = false,
  });

  static const VoiceStatusSnapshot initial = VoiceStatusSnapshot();

  bool get isSpeaking => status == VoiceStatus.speaking;
  bool get isListening => status == VoiceStatus.listening;
  bool get isPaused => status == VoiceStatus.paused;
  bool get canReplay => !muted && ttsAvailable;

  VoiceStatusSnapshot copyWith({
    VoiceStatus? status,
    String? nowSpeaking,
    bool clearNowSpeaking = false,
    int? pending,
    bool? muted,
    bool? micAvailable,
    bool? ttsAvailable,
  }) =>
      VoiceStatusSnapshot(
        status: status ?? this.status,
        nowSpeaking:
            clearNowSpeaking ? null : (nowSpeaking ?? this.nowSpeaking),
        pending: pending ?? this.pending,
        muted: muted ?? this.muted,
        micAvailable: micAvailable ?? this.micAvailable,
        ttsAvailable: ttsAvailable ?? this.ttsAvailable,
      );

  @override
  bool operator ==(Object other) =>
      other is VoiceStatusSnapshot &&
      other.status == status &&
      other.nowSpeaking == nowSpeaking &&
      other.pending == pending &&
      other.muted == muted &&
      other.micAvailable == micAvailable &&
      other.ttsAvailable == ttsAvailable;

  @override
  int get hashCode =>
      Object.hash(status, nowSpeaking, pending, muted, micAvailable, ttsAvailable);
}
