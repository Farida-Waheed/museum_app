import '../enums/accessibility_enums.dart';
import '../utils/accessibility_parse.dart';

/// How the visitor prefers to operate the app and robot. Consumed by the
/// Alternative Interaction System (Phase 11) and Live Captions (Phase 5).
class InteractionSettings {
  final InteractionMode mode;

  /// Show captions for spoken content (robot narration, AI voice, videos).
  final bool captionsEnabled;

  /// Provide haptic confirmation for key actions.
  final bool hapticFeedback;

  /// Allow extra time before timeouts / auto-advance (motor + cognitive).
  final bool extendedTimeouts;

  /// Confirm destructive / important actions with an explicit step.
  final bool confirmActions;

  const InteractionSettings({
    this.mode = InteractionMode.standardTouch,
    this.captionsEnabled = false,
    this.hapticFeedback = false,
    this.extendedTimeouts = false,
    this.confirmActions = false,
  });

  static const InteractionSettings standard = InteractionSettings();

  bool get isNeutral =>
      mode == InteractionMode.standardTouch &&
      !captionsEnabled &&
      !hapticFeedback &&
      !extendedTimeouts &&
      !confirmActions;

  InteractionSettings copyWith({
    InteractionMode? mode,
    bool? captionsEnabled,
    bool? hapticFeedback,
    bool? extendedTimeouts,
    bool? confirmActions,
  }) {
    return InteractionSettings(
      mode: mode ?? this.mode,
      captionsEnabled: captionsEnabled ?? this.captionsEnabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      extendedTimeouts: extendedTimeouts ?? this.extendedTimeouts,
      confirmActions: confirmActions ?? this.confirmActions,
    );
  }

  Map<String, dynamic> toMap() => {
        'mode': mode.storageKey,
        'captions_enabled': captionsEnabled,
        'haptic_feedback': hapticFeedback,
        'extended_timeouts': extendedTimeouts,
        'confirm_actions': confirmActions,
      };

  factory InteractionSettings.fromMap(Map<String, dynamic> map) =>
      InteractionSettings(
        mode: InteractionMode.fromStorage(map['mode']),
        captionsEnabled: AccessibilityParse.asBool(map['captions_enabled']),
        hapticFeedback: AccessibilityParse.asBool(map['haptic_feedback']),
        extendedTimeouts: AccessibilityParse.asBool(map['extended_timeouts']),
        confirmActions: AccessibilityParse.asBool(map['confirm_actions']),
      );

  @override
  bool operator ==(Object other) =>
      other is InteractionSettings &&
      other.mode == mode &&
      other.captionsEnabled == captionsEnabled &&
      other.hapticFeedback == hapticFeedback &&
      other.extendedTimeouts == extendedTimeouts &&
      other.confirmActions == confirmActions;

  @override
  int get hashCode => Object.hash(
      mode, captionsEnabled, hapticFeedback, extendedTimeouts, confirmActions);
}
