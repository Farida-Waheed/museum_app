import '../enums/voice_enums.dart';
import '../models/voice_message.dart';
import '../services/voice_director.dart';
import '../services/voice_queue_manager.dart';
import '../services/voice_service.dart';

/// The single seam through which navigation, tour, and robot producers emit
/// spoken guidance. Producers call intention-revealing methods with plain data
/// (an exhibit name, a direction) and this announcer:
///   1. asks the [VoiceDirector] whether the current activity/config allows it
///      (context-aware, non-intrusive), and
///   2. builds the localized [VoiceContent] and speaks it through [VoiceService]
///      at the right priority and verbosity.
///
/// No producer builds strings or touches the queue/plugins — guidance phrasing,
/// localization, and gating all live here and in the director.
class VoiceNavigationAnnouncer {
  VoiceNavigationAnnouncer(
    this._voice, {
    VoiceDirector director = const VoiceDirector(),
  }) : _director = director;

  final VoiceService _voice;
  final VoiceDirector _director;

  VoiceActivity _activity = VoiceActivity.idle;
  VoiceActivity get activity => _activity;

  /// Update the visitor's current activity so gating adapts (walking, reading,
  /// in conversation, emergency…). Set by the tour/UI layer.
  void setActivity(VoiceActivity activity) => _activity = activity;

  // --- High-level guidance verbs -------------------------------------------

  void welcome() => _emit(VoiceEventType.tourWelcome);
  void tourStarted() => _emit(VoiceEventType.tourStarted);
  void tourCompleted() => _emit(VoiceEventType.tourCompleted);
  void robotApproaching() => _emit(VoiceEventType.robotApproaching);
  void robotConnected() => _emit(VoiceEventType.robotConnected);
  void robotDisconnected() => _emit(VoiceEventType.robotDisconnected);
  void robotReconnecting() => _emit(VoiceEventType.robotReconnecting);

  void walk({int? distanceMeters}) => _emit(
        VoiceEventType.walkInstruction,
        args: VoiceEventArgs(distanceMeters: distanceMeters),
      );

  void turn(String direction) => _emit(
        VoiceEventType.turnInstruction,
        args: VoiceEventArgs(direction: direction),
      );

  void arrived({String? destinationName}) => _emit(
        VoiceEventType.destinationArrival,
        args: VoiceEventArgs(destinationName: destinationName),
      );

  void introduceExhibit({required String name, String? summary}) => _emit(
        VoiceEventType.exhibitIntroduction,
        args: VoiceEventArgs(exhibitName: name, exhibitSummary: summary),
      );

  void assistanceRequested() => _emit(VoiceEventType.assistanceRequested);

  void emergency() => _emit(VoiceEventType.emergency);

  /// The core path: gate on context, then build + speak. Returns the enqueue
  /// result (or `dropped` if the director suppressed it).
  VoiceEnqueueResult _emit(
    VoiceEventType event, {
    VoiceEventArgs args = VoiceEventArgs.none,
  }) {
    final config = _voice.config;
    if (!_director.shouldAnnounce(event,
        activity: _activity, config: config)) {
      return VoiceEnqueueResult.dropped;
    }
    final verbosity = config.verbosityFor(event.defaultPriority);
    final content = _director.build(
      event,
      args: args,
      language: _voice.language,
      verbosity: verbosity,
    );
    if (content.isEmpty) return VoiceEnqueueResult.dropped;
    return _voice.speak(VoiceMessage(
      content: content,
      event: event,
      priority: event.defaultPriority,
      language: _voice.language,
    ));
  }
}
