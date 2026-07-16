import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/accessibility_controller.dart';
import 'accessibility_setup_screen.dart';

/// Ensures every visitor has been offered the accessibility setup exactly once.
///
/// Wrap the app's landing screen with this. On first build, if the current
/// profile has not completed setup, it shows the wizard; otherwise it shows
/// [child] unchanged. Because the profile is already loaded before the first
/// frame (Phase 1), this decision is synchronous and flicker-free.
///
/// It intentionally does NOT force-redirect on every visit — once
/// `hasCompletedSetup` is true (including via "skip"), the visitor is never
/// nagged again; they manage accessibility from the profile page thereafter.
class AccessibilitySetupGate extends StatelessWidget {
  final Widget child;

  const AccessibilitySetupGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Watch only the setup flag, not the whole profile, to avoid rebuilding the
    // gate on unrelated preference changes.
    final completed = context.select<AccessibilityController, bool>(
      (c) => c.profile.hasCompletedSetup,
    );

    if (!completed) {
      // Show the wizard inline; on finish it pops back to reveal [child].
      return const AccessibilitySetupScreen();
    }
    return child;
  }
}
