import 'package:flutter/widgets.dart';

import '../models/accessibility_profile.dart';

/// Motion helpers that make "reduced motion" a one-line, app-wide capability.
///
/// Every later phase (and any existing screen that opts in) routes its animation
/// durations through [AccessibilityMotion.duration] so a single profile flag
/// calms transitions everywhere for sensory-sensitive visitors — no scattered
/// `if (reduceMotion)` checks.
class AccessibilityMotion {
  const AccessibilityMotion._();

  /// Collapses [base] to [Duration.zero] when the profile requests reduced
  /// motion; otherwise returns [base] unchanged.
  static Duration duration(Duration base, {required bool reduceMotion}) =>
      reduceMotion ? Duration.zero : base;

  /// Convenience overload reading the flag straight from a profile.
  static Duration forProfile(Duration base, AccessibilityProfile profile) =>
      duration(base, reduceMotion: profile.display.reduceMotion);

  /// A curve that is effectively instant under reduced motion, so callers can
  /// keep a single AnimatedX call site.
  static Curve curve(Curve base, {required bool reduceMotion}) =>
      reduceMotion ? Curves.linear : base;
}
