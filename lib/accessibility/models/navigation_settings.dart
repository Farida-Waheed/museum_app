import '../enums/accessibility_enums.dart';
import '../utils/accessibility_parse.dart';

/// Wayfinding preferences for the accessible museum map and robot escort.
/// Consumed by Wheelchair Navigation (Phase 6) and the Accessible Map (Phase 9).
class NavigationSettings {
  final RoutePreference routePreference;

  /// Prefer more frequent rest points along a route.
  final bool moreRestPoints;

  /// Announce turn-by-turn directions aloud.
  final bool announceDirections;

  /// Avoid crowded galleries where possible (sensory / mobility comfort).
  final bool avoidCrowds;

  const NavigationSettings({
    this.routePreference = RoutePreference.standard,
    this.moreRestPoints = false,
    this.announceDirections = false,
    this.avoidCrowds = false,
  });

  static const NavigationSettings standard = NavigationSettings();

  bool get isNeutral =>
      routePreference == RoutePreference.standard &&
      !moreRestPoints &&
      !announceDirections &&
      !avoidCrowds;

  NavigationSettings copyWith({
    RoutePreference? routePreference,
    bool? moreRestPoints,
    bool? announceDirections,
    bool? avoidCrowds,
  }) {
    return NavigationSettings(
      routePreference: routePreference ?? this.routePreference,
      moreRestPoints: moreRestPoints ?? this.moreRestPoints,
      announceDirections: announceDirections ?? this.announceDirections,
      avoidCrowds: avoidCrowds ?? this.avoidCrowds,
    );
  }

  Map<String, dynamic> toMap() => {
        'route_preference': routePreference.storageKey,
        'more_rest_points': moreRestPoints,
        'announce_directions': announceDirections,
        'avoid_crowds': avoidCrowds,
      };

  factory NavigationSettings.fromMap(Map<String, dynamic> map) =>
      NavigationSettings(
        routePreference: RoutePreference.fromStorage(map['route_preference']),
        moreRestPoints: AccessibilityParse.asBool(map['more_rest_points']),
        announceDirections:
            AccessibilityParse.asBool(map['announce_directions']),
        avoidCrowds: AccessibilityParse.asBool(map['avoid_crowds']),
      );

  @override
  bool operator ==(Object other) =>
      other is NavigationSettings &&
      other.routePreference == routePreference &&
      other.moreRestPoints == moreRestPoints &&
      other.announceDirections == announceDirections &&
      other.avoidCrowds == avoidCrowds;

  @override
  int get hashCode => Object.hash(
      routePreference, moreRestPoints, announceDirections, avoidCrowds);
}
