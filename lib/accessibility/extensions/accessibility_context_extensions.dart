import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/accessibility_profile.dart';
import '../state/accessibility_controller.dart';
import '../utils/accessibility_motion.dart';

/// Ergonomic access to the accessibility state from any widget, so no screen
/// re-implements provider plumbing (spec #7 — "no duplicated logic").
///
/// * [a11y] — the controller for actions (does NOT subscribe to rebuilds).
/// * [watchA11y] — the controller with rebuild subscription.
/// * [accessibility] — the current profile (subscribes to rebuilds).
/// * [reduceMotion] / [minTapTarget] — the most-used values inline.
/// * [a11yDuration] — reduced-motion-aware animation duration in one call.
extension AccessibilityContextX on BuildContext {
  AccessibilityController get a11y => read<AccessibilityController>();

  AccessibilityController get watchA11y => watch<AccessibilityController>();

  AccessibilityProfile get accessibility =>
      watch<AccessibilityController>().profile;

  bool get reduceMotion =>
      watch<AccessibilityController>().profile.display.reduceMotion;

  double get minTapTarget => watch<AccessibilityController>().minTapTargetSize;

  /// Reduced-motion-aware duration. Use for any AnimatedX/transition so motion
  /// preferences apply automatically:
  ///   AnimatedContainer(duration: context.a11yDuration(kThemeAnimationDuration))
  Duration a11yDuration(Duration base) => AccessibilityMotion.duration(
        base,
        reduceMotion: read<AccessibilityController>().profile.display.reduceMotion,
      );
}
