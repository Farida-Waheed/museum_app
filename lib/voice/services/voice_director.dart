import '../enums/voice_enums.dart';
import '../models/speech_config.dart';
import '../models/voice_content.dart';

/// Structured arguments for building an announcement, so producers pass data
/// (an exhibit name, a direction, a distance) rather than pre-baked strings —
/// keeping localization and phrasing entirely inside the [VoiceDirector].
class VoiceEventArgs {
  final String? exhibitName;
  final String? exhibitSummary;
  final String? direction; // e.g. 'left' / 'right'
  final int? distanceMeters;
  final String? destinationName;

  /// Free-form fallback text for [VoiceEventType.genericNotice] / AI answers.
  final String? text;

  const VoiceEventArgs({
    this.exhibitName,
    this.exhibitSummary,
    this.direction,
    this.distanceMeters,
    this.destinationName,
    this.text,
  });

  static const VoiceEventArgs none = VoiceEventArgs();
}

/// The context-aware "brain" that decides **whether** an event should be spoken
/// and **what** it should say — the difference between an engine that reads
/// everything and a companion that speaks only meaningful things at the right
/// time.
///
/// Pure and localized (en/ar): no Flutter, no plugin, no I/O — so both the
/// gating policy and every phrase are exhaustively unit-testable. Producers hand
/// it an event + [VoiceEventArgs]; it returns localized [VoiceContent] with
/// deliberate pauses and an emphasised exhibit name where appropriate.
class VoiceDirector {
  const VoiceDirector();

  /// Decide whether [event] should be announced given the visitor's current
  /// [activity] and their resolved [config]. This is the "smart, non-intrusive"
  /// contract:
  ///
  /// * Emergencies are ALWAYS announced, overriding everything.
  /// * When voice is disabled, only critical safety events pass.
  /// * While the visitor reads manually, suppress ambient/content pushes.
  /// * During a conversation, hold navigation until the exchange ends.
  /// * In emergency mode, only emergency-class events pass.
  bool shouldAnnounce(
    VoiceEventType event, {
    required VoiceActivity activity,
    required SpeechConfig config,
  }) {
    if (event.isEmergency) return true;

    final priority = event.defaultPriority;
    final isCritical = priority == VoicePriority.critical;

    if (!config.enabled && !isCritical) return false;

    switch (activity) {
      case VoiceActivity.emergency:
        return isCritical;
      case VoiceActivity.readingManually:
        // Don't interrupt manual reading with ambient/content; navigation and
        // interactive replies still get through.
        return priority.index >= VoicePriority.navigation.index;
      case VoiceActivity.conversation:
        // Hold navigation until the conversation finishes; let interactive
        // (the answer itself) and critical through.
        return event.isNavigation
            ? false
            : priority.index >= VoicePriority.interactive.index || !event.isNavigation;
      case VoiceActivity.idle:
      case VoiceActivity.walking:
      case VoiceActivity.atExhibit:
        return true;
    }
  }

  /// Build the localized [VoiceContent] for [event]. [verbosity] tunes length
  /// (concise for cognitive-assistance visitors, detailed for screen-reader
  /// first). Unknown/generic events fall back to [VoiceEventArgs.text].
  VoiceContent build(
    VoiceEventType event, {
    VoiceEventArgs args = VoiceEventArgs.none,
    VoiceLanguage language = VoiceLanguage.english,
    VoiceVerbosity verbosity = VoiceVerbosity.standard,
  }) {
    final ar = language == VoiceLanguage.arabic;
    switch (event) {
      case VoiceEventType.tourWelcome:
        return _c(ar
            ? 'أهلاً بك في المتحف. أنا حورس، مرشدك اليوم.'
            : 'Welcome to the museum. I am Horus, your guide today.');
      case VoiceEventType.tourStarted:
        return _c(ar
            ? 'لنبدأ الجولة. سأرشدك في كل خطوة.'
            : "Let's begin the tour. I'll guide you every step of the way.");
      case VoiceEventType.robotApproaching:
        return _c(ar
            ? 'الروبوت يقترب منك الآن.'
            : 'Your robot is approaching you now.');
      case VoiceEventType.robotConnected:
        return _c(ar
            ? 'تم توصيل الروبوت بنجاح. الجولة جاهزة للبدء.'
            : 'Your robot has been connected successfully. The tour is ready to begin.');
      case VoiceEventType.robotDisconnected:
        return _c(ar
            ? 'انقطع الاتصال بالروبوت. جارٍ محاولة إعادة الاتصال.'
            : 'The robot connection has been lost. Attempting to reconnect.');
      case VoiceEventType.robotReconnecting:
        return _c(ar ? 'جارٍ إعادة الاتصال بالروبوت.' : 'Reconnecting to the robot.');
      case VoiceEventType.walkInstruction:
        return _walk(ar, args, verbosity);
      case VoiceEventType.turnInstruction:
        return _turn(ar, args);
      case VoiceEventType.destinationArrival:
        return _arrival(ar, args);
      case VoiceEventType.exhibitIntroduction:
        return _exhibitIntro(ar, args, verbosity);
      case VoiceEventType.tourCompleted:
        return _c(ar
            ? 'انتهت الجولة. شكراً لزيارتك، ونتمنى أن تكون قد استمتعت.'
            : 'The tour is complete. Thank you for visiting — we hope you enjoyed it.');
      case VoiceEventType.emergency:
        return _c(ar
            ? 'تنبيه طارئ. يرجى البقاء في مكانك، المساعدة في الطريق.'
            : 'Emergency alert. Please stay where you are, help is on the way.');
      case VoiceEventType.assistanceRequested:
        return _c(ar
            ? 'تم طلب المساعدة. سيصل أحد الموظفين قريباً.'
            : 'Assistance has been requested. A staff member will arrive shortly.');
      case VoiceEventType.commandAck:
        return _c(args.text ?? (ar ? 'تم.' : 'Done.'));
      case VoiceEventType.aiAnswer:
      case VoiceEventType.genericNotice:
        return VoiceContent.plain(args.text ?? '');
    }
  }

  // --- Phrase helpers -------------------------------------------------------

  VoiceContent _walk(bool ar, VoiceEventArgs args, VoiceVerbosity verbosity) {
    final d = args.distanceMeters;
    if (d != null && d > 0) {
      final text = ar
          ? 'استمر في السير لمسافة $d متر تقريباً.'
          : 'Continue walking for about $d meters.';
      return _c(text);
    }
    return _c(ar ? 'استمر في السير للأمام.' : 'Continue walking straight ahead.');
  }

  VoiceContent _turn(bool ar, VoiceEventArgs args) {
    final dir = (args.direction ?? '').toLowerCase();
    final isLeft = dir == 'left' || dir.contains('يسار');
    final isRight = dir == 'right' || dir.contains('يمين');
    if (isLeft) {
      return _c(ar ? 'انعطف إلى اليسار.' : 'Turn left.');
    }
    if (isRight) {
      return _c(ar ? 'انعطف إلى اليمين.' : 'Turn right.');
    }
    return _c(ar ? 'انعطف الآن.' : 'Turn now.');
  }

  VoiceContent _arrival(bool ar, VoiceEventArgs args) {
    final name = args.destinationName ?? args.exhibitName;
    if (name == null || name.trim().isEmpty) {
      return _c(ar ? 'لقد وصلنا إلى وجهتنا.' : 'We have arrived at our destination.');
    }
    // Emphasise the destination name so it stands out — "We have arrived at the
    // Rosetta Stone."
    return VoiceContent(segments: [
      VoiceSegment(
        ar ? 'لقد وصلنا إلى' : 'We have arrived at the',
        pauseAfter: const Duration(milliseconds: 150),
      ),
      VoiceSegment.emphasis(name.trim()),
    ]);
  }

  VoiceContent _exhibitIntro(
      bool ar, VoiceEventArgs args, VoiceVerbosity verbosity) {
    final name = (args.exhibitName ?? '').trim();
    final summary = (args.exhibitSummary ?? '').trim();
    if (name.isEmpty) return VoiceContent.plain(summary);

    final lead = ar ? 'أمامك الآن' : 'In front of you is the';
    final segments = <VoiceSegment>[
      VoiceSegment(lead, pauseAfter: const Duration(milliseconds: 120)),
      VoiceSegment.emphasis(name),
    ];
    // Concise verbosity (cognitive assistance) stops at the name; standard/
    // detailed add the summary.
    if (verbosity != VoiceVerbosity.concise && summary.isNotEmpty) {
      segments.add(VoiceSegment(
        summary,
        pauseAfter: const Duration(milliseconds: 200),
      ));
    }
    return VoiceContent(segments: segments);
  }

  VoiceContent _c(String text) => VoiceContent.plain(text);
}
