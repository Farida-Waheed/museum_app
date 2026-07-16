import '../enums/accessibility_enums.dart';
import '../utils/accessibility_parse.dart';

/// Accessibility-specific tour preferences. Distinct from the app's existing
/// `TourPreferences` model (which covers interests/duration) — this group only
/// holds accessibility-driven pacing and explanation depth so the two never
/// collide. Consumed by Cognitive Assistance (Phase 7) and Smart Pace (Phase 10).
class AccessibilityTourPreferences {
  final TourPace pace;
  final ExplanationLevel explanationLevel;

  /// Automatically pause narration between exhibits (time to absorb).
  final bool autoPauseBetweenStops;

  /// Prefer fewer stops focused on highlights (reduces fatigue/overload).
  final bool highlightsOnly;

  const AccessibilityTourPreferences({
    this.pace = TourPace.standard,
    this.explanationLevel = ExplanationLevel.standard,
    this.autoPauseBetweenStops = false,
    this.highlightsOnly = false,
  });

  static const AccessibilityTourPreferences standard =
      AccessibilityTourPreferences();

  bool get isNeutral =>
      pace == TourPace.standard &&
      explanationLevel == ExplanationLevel.standard &&
      !autoPauseBetweenStops &&
      !highlightsOnly;

  AccessibilityTourPreferences copyWith({
    TourPace? pace,
    ExplanationLevel? explanationLevel,
    bool? autoPauseBetweenStops,
    bool? highlightsOnly,
  }) {
    return AccessibilityTourPreferences(
      pace: pace ?? this.pace,
      explanationLevel: explanationLevel ?? this.explanationLevel,
      autoPauseBetweenStops:
          autoPauseBetweenStops ?? this.autoPauseBetweenStops,
      highlightsOnly: highlightsOnly ?? this.highlightsOnly,
    );
  }

  Map<String, dynamic> toMap() => {
        'pace': pace.storageKey,
        'explanation_level': explanationLevel.storageKey,
        'auto_pause_between_stops': autoPauseBetweenStops,
        'highlights_only': highlightsOnly,
      };

  factory AccessibilityTourPreferences.fromMap(Map<String, dynamic> map) =>
      AccessibilityTourPreferences(
        pace: TourPace.fromStorage(map['pace']),
        explanationLevel:
            ExplanationLevel.fromStorage(map['explanation_level']),
        autoPauseBetweenStops:
            AccessibilityParse.asBool(map['auto_pause_between_stops']),
        highlightsOnly: AccessibilityParse.asBool(map['highlights_only']),
      );

  @override
  bool operator ==(Object other) =>
      other is AccessibilityTourPreferences &&
      other.pace == pace &&
      other.explanationLevel == explanationLevel &&
      other.autoPauseBetweenStops == autoPauseBetweenStops &&
      other.highlightsOnly == highlightsOnly;

  @override
  int get hashCode =>
      Object.hash(pace, explanationLevel, autoPauseBetweenStops, highlightsOnly);
}
