/// Semantic vocabulary for the Voice Communication Engine (Phase 3).
///
/// Like the accessibility enums, these describe *communication intent and
/// state*, never widgets or plugins. Every part of the engine — the queue, the
/// coordinator, the controller, the AI/navigation adapters, and the future
/// robot bridge — speaks this vocabulary, so a spoken event is described once
/// and understood everywhere.
///
/// Rules (identical to the accessibility module, spec continuity):
/// * A stable [storageKey] string is what gets persisted / sent on the wire
///   (never the Dart index), so reordering can never corrupt a cache entry or a
///   robot payload.
/// * A null-safe, forward-compatible `fromStorage` degrades unknown values to
///   the safest default instead of throwing.
/// * Zero Flutter / plugin imports — pure data, unit-testable, shareable with
///   the future website dashboard and the ROS side.
library;

/// Relative importance of a spoken message. The queue is a priority queue keyed
/// on this: a higher-priority message can interrupt a lower one, and messages
/// never overlap. Ordering (by index) is meaningful — keep most-urgent last so
/// `.index` increases with urgency.
enum VoicePriority {
  /// Ambient/optional chatter (e.g. "did you know…"). Dropped first under load,
  /// never interrupts anything.
  ambient('ambient'),

  /// Exhibit explanations and AI answers — the main content stream.
  content('content'),

  /// Turn-by-turn navigation ("turn left", "we have arrived"). Outranks content
  /// so guidance is never buried under a long description.
  navigation('navigation'),

  /// Direct answer to something the visitor just asked or a command ack.
  /// Feels rude to delay, so it jumps ahead of navigation/content.
  interactive('interactive'),

  /// System-critical: emergency/SOS, "connection lost", safety warnings.
  /// Always interrupts and clears everything below it.
  critical('critical');

  const VoicePriority(this.storageKey);
  final String storageKey;

  static VoicePriority fromStorage(Object? value) {
    for (final p in VoicePriority.values) {
      if (p.storageKey == value?.toString()) return p;
    }
    return VoicePriority.content;
  }

  bool isMoreUrgentThan(VoicePriority other) => index > other.index;

  /// Critical (and, defensively, interactive) always cut in front of whatever
  /// is currently speaking rather than waiting their turn.
  bool get interruptsCurrent => index >= VoicePriority.interactive.index;

  /// When this message starts, lower-priority items already queued are dropped
  /// rather than spoken later (true only for the top tier — a fire alarm should
  /// not be followed by the exhibit blurb it interrupted).
  bool get clearsLowerPriority => this == VoicePriority.critical;
}

/// The live state of the voice engine, surfaced to the UI status indicator.
enum VoiceStatus {
  /// Idle and available.
  ready('ready'),

  /// Currently speaking (TTS active).
  speaking('speaking'),

  /// Actively listening on the microphone for a command.
  listening('listening'),

  /// Temporarily paused by the visitor or by an audio interruption (phone call).
  paused('paused'),

  /// Muted by the visitor — messages are suppressed, not queued.
  muted('muted'),

  /// A recoverable fault (TTS/mic unavailable). The app keeps working via touch.
  unavailable('unavailable');

  const VoiceStatus(this.storageKey);
  final String storageKey;

  static VoiceStatus fromStorage(Object? value) {
    for (final s in VoiceStatus.values) {
      if (s.storageKey == value?.toString()) return s;
    }
    return VoiceStatus.ready;
  }

  bool get isBusy => this == VoiceStatus.speaking || this == VoiceStatus.listening;
}

/// Preferred synthesized-voice gender, where the TTS backend supports it. Mapped
/// to a backend voice by the engine adapter; unsupported values degrade to the
/// platform default with no error.
enum VoiceGender {
  system('system'),
  female('female'),
  male('male');

  const VoiceGender(this.storageKey);
  final String storageKey;

  static VoiceGender fromStorage(Object? value) {
    for (final g in VoiceGender.values) {
      if (g.storageKey == value?.toString()) return g;
    }
    return VoiceGender.system;
  }
}

/// The spoken language of a message. Kept independent of the app locale enum so
/// a single announcement can override language (e.g. always read an Arabic
/// exhibit label in Arabic even in an English UI) — future multilingual speech.
enum VoiceLanguage {
  english('en', 'en-US'),
  arabic('ar', 'ar-SA');

  const VoiceLanguage(this.code, this.bcp47);

  /// Short app locale code ('en' / 'ar').
  final String code;

  /// BCP-47 tag handed to the TTS/STT backend.
  final String bcp47;

  static VoiceLanguage fromCode(Object? value) {
    final s = value?.toString().toLowerCase();
    for (final l in VoiceLanguage.values) {
      if (l.code == s || l.bcp47.toLowerCase() == s) return l;
    }
    // Match a language subtag like "ar-EG".
    if (s != null && s.startsWith('ar')) return VoiceLanguage.arabic;
    return VoiceLanguage.english;
  }

  bool get isRtl => this == VoiceLanguage.arabic;
}

/// Meaningful things that happen during a visit which the [VoiceDirector] may
/// decide to announce. Announcing is *policy* (context-aware, see the director);
/// this enum is just the vocabulary of events, so producers stay decoupled from
/// speech decisions. This is the "only announce meaningful events" contract.
enum VoiceEventType {
  tourWelcome('tour_welcome', VoicePriority.content),
  tourStarted('tour_started', VoicePriority.navigation),
  robotApproaching('robot_approaching', VoicePriority.navigation),
  robotConnected('robot_connected', VoicePriority.interactive),
  robotDisconnected('robot_disconnected', VoicePriority.critical),
  robotReconnecting('robot_reconnecting', VoicePriority.navigation),
  walkInstruction('walk_instruction', VoicePriority.navigation),
  turnInstruction('turn_instruction', VoicePriority.navigation),
  destinationArrival('destination_arrival', VoicePriority.navigation),
  exhibitIntroduction('exhibit_introduction', VoicePriority.content),
  tourCompleted('tour_completed', VoicePriority.content),
  emergency('emergency', VoicePriority.critical),
  assistanceRequested('assistance_requested', VoicePriority.interactive),
  commandAck('command_ack', VoicePriority.interactive),
  aiAnswer('ai_answer', VoicePriority.interactive),
  genericNotice('generic_notice', VoicePriority.content);

  const VoiceEventType(this.storageKey, this.defaultPriority);
  final String storageKey;

  /// The priority the director assigns to this event unless overridden.
  final VoicePriority defaultPriority;

  static VoiceEventType fromStorage(Object? value) {
    for (final e in VoiceEventType.values) {
      if (e.storageKey == value?.toString()) return e;
    }
    return VoiceEventType.genericNotice;
  }

  bool get isNavigation =>
      this == walkInstruction ||
      this == turnInstruction ||
      this == destinationArrival ||
      this == robotApproaching;

  bool get isEmergency => this == emergency;
}

/// The visitor's inferred current activity, used by the [VoiceDirector] to gate
/// announcements (smart, non-intrusive behavior). E.g. while [readingManually]
/// the engine suppresses ambient/content pushes; while [walking] it prioritizes
/// navigation; during [conversation] it holds navigation until the exchange ends.
enum VoiceActivity {
  idle('idle'),
  walking('walking'),
  atExhibit('at_exhibit'),
  readingManually('reading_manually'),
  conversation('conversation'),
  emergency('emergency');

  const VoiceActivity(this.storageKey);
  final String storageKey;

  static VoiceActivity fromStorage(Object? value) {
    for (final a in VoiceActivity.values) {
      if (a.storageKey == value?.toString()) return a;
    }
    return VoiceActivity.idle;
  }
}

/// How much the engine says for a given stream. Derived from the accessibility
/// profile (e.g. cognitive assistance → concise navigation; audio-description →
/// rich exhibit narration) but independently overridable per the voice settings.
enum VoiceVerbosity {
  /// Only the essentials (short turn cues, one-line intros).
  concise('concise'),

  /// The standard amount of guidance/detail.
  standard('standard'),

  /// Extra description and context (screen-reader-first visitors).
  detailed('detailed');

  const VoiceVerbosity(this.storageKey);
  final String storageKey;

  static VoiceVerbosity fromStorage(Object? value) {
    for (final v in VoiceVerbosity.values) {
      if (v.storageKey == value?.toString()) return v;
    }
    return VoiceVerbosity.standard;
  }

  bool get isDetailed => this == VoiceVerbosity.detailed;
  bool get isConcise => this == VoiceVerbosity.concise;
}

/// Every voice command the engine understands. The grammar (Arabic + English
/// phrasings) that maps utterances to these lives in `VoiceCommandParser`; the
/// handling lives in the coordinator/app. Adding a future command means adding a
/// value here plus phrasings — no architectural change (extensible by design).
enum VoiceCommandIntent {
  startTour('start_tour'),
  pauseTour('pause_tour'),
  resumeTour('resume_tour'),
  repeatExplanation('repeat_explanation'),
  nextExhibit('next_exhibit'),
  previousExhibit('previous_exhibit'),
  stopSpeaking('stop_speaking'),
  callAssistance('call_assistance'),
  increaseVolume('increase_volume'),
  decreaseVolume('decrease_volume'),
  fasterSpeech('faster_speech'),
  slowerSpeech('slower_speech'),
  unknown('unknown');

  const VoiceCommandIntent(this.storageKey);
  final String storageKey;

  static VoiceCommandIntent fromStorage(Object? value) {
    for (final i in VoiceCommandIntent.values) {
      if (i.storageKey == value?.toString()) return i;
    }
    return VoiceCommandIntent.unknown;
  }

  bool get isRecognized => this != VoiceCommandIntent.unknown;

  /// Commands that must be honoured even mid-speech (they control speech itself
  /// or summon help).
  bool get isImmediate =>
      this == stopSpeaking ||
      this == pauseTour ||
      this == callAssistance;
}
