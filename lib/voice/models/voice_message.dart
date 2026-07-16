import '../enums/voice_enums.dart';
import 'voice_content.dart';

/// One unit of work in the voice queue: a piece of [VoiceContent] plus the
/// metadata the queue and coordinator need to order, dedupe, interrupt, cache,
/// and caption it. Immutable value object.
///
/// Nothing constructs a raw plugin call — everything that wants to speak builds
/// a [VoiceMessage] and hands it to the coordinator, which is what makes this a
/// single, centralized communication channel.
class VoiceMessage {
  /// Process-unique id (ordering tiebreaker + replay/caption correlation).
  final int id;

  final VoiceContent content;
  final VoicePriority priority;
  final VoiceEventType event;
  final VoiceLanguage language;

  /// Whether a higher-priority message may interrupt this one mid-speech. Most
  /// messages are interruptible; a short critical confirmation may not be.
  final bool interruptible;

  /// Whether the visitor's "repeat" command should replay this. Navigation cues
  /// and exhibit intros are replayable; transient acks are not.
  final bool replayable;

  /// Key used for duplicate suppression within [VoiceConstants.duplicateWindow].
  /// Defaults to event + flattened text so two identical announcements collapse.
  final String dedupKey;

  /// Optional key into the offline phrase cache. When set and the phrase is
  /// cached, the engine can play the cached audio instead of synthesizing —
  /// enabling offline announcements.
  final String? cacheKey;

  /// Wall-clock creation time (ms since epoch) — for dedup windows and ordering.
  final int createdAtMs;

  const VoiceMessage._({
    required this.id,
    required this.content,
    required this.priority,
    required this.event,
    required this.language,
    required this.interruptible,
    required this.replayable,
    required this.dedupKey,
    required this.cacheKey,
    required this.createdAtMs,
  });

  static int _seq = 0;

  /// Primary factory. [nowMs] is injectable so tests stay deterministic (the
  /// module never calls DateTime.now() implicitly in a way tests can't control).
  factory VoiceMessage({
    required VoiceContent content,
    VoicePriority priority = VoicePriority.content,
    VoiceEventType event = VoiceEventType.genericNotice,
    VoiceLanguage language = VoiceLanguage.english,
    bool? interruptible,
    bool? replayable,
    String? dedupKey,
    String? cacheKey,
    int? id,
    int? nowMs,
  }) {
    final resolvedPriority = priority;
    return VoiceMessage._(
      id: id ?? (_seq = (_seq + 1) & 0x7fffffff),
      content: content,
      priority: resolvedPriority,
      event: event,
      language: language,
      // Critical messages are, by default, not interruptible.
      interruptible: interruptible ?? (resolvedPriority != VoicePriority.critical),
      replayable: replayable ?? _defaultReplayable(event),
      dedupKey: dedupKey ?? '${event.storageKey}:${content.plainText}',
      cacheKey: cacheKey,
      createdAtMs: nowMs ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convenience: a plain-text message with an event whose default priority is
  /// used unless [priority] overrides it.
  factory VoiceMessage.text(
    String text, {
    VoiceEventType event = VoiceEventType.genericNotice,
    VoicePriority? priority,
    VoiceLanguage language = VoiceLanguage.english,
    String? cacheKey,
    int? nowMs,
  }) =>
      VoiceMessage(
        content: VoiceContent.plain(text),
        event: event,
        priority: priority ?? event.defaultPriority,
        language: language,
        cacheKey: cacheKey,
        nowMs: nowMs,
      );

  static bool _defaultReplayable(VoiceEventType event) {
    switch (event) {
      case VoiceEventType.commandAck:
      case VoiceEventType.assistanceRequested:
        return false;
      default:
        return true;
    }
  }

  /// The flattened text, for captions/logging/cache.
  String get text => content.plainText;

  bool get isCritical => priority == VoicePriority.critical;
  bool get isNavigation => priority == VoicePriority.navigation;

  /// True when [other] is a duplicate of this within [window] (same dedup key,
  /// close in time).
  bool duplicates(VoiceMessage other, Duration window) =>
      other.dedupKey == dedupKey &&
      (createdAtMs - other.createdAtMs).abs() <= window.inMilliseconds;

  VoiceMessage copyWith({
    VoiceContent? content,
    VoicePriority? priority,
    VoiceLanguage? language,
    bool? interruptible,
    String? cacheKey,
  }) =>
      VoiceMessage._(
        id: id,
        content: content ?? this.content,
        priority: priority ?? this.priority,
        event: event,
        language: language ?? this.language,
        interruptible: interruptible ?? this.interruptible,
        replayable: replayable,
        dedupKey: dedupKey,
        cacheKey: cacheKey ?? this.cacheKey,
        createdAtMs: createdAtMs,
      );

  @override
  String toString() =>
      'VoiceMessage(#$id ${priority.storageKey}/${event.storageKey} "$text")';
}
