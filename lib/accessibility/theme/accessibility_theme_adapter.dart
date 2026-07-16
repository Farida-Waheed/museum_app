import 'package:flutter/material.dart';

import '../models/accessibility_profile.dart';

/// Accessibility-aware theme adapter (spec #8).
///
/// Takes the app's EXISTING branded [ThemeData] and layers accessibility
/// adaptations on top — it never redesigns the Horus-Bot visual identity. Text
/// scaling and high-contrast are already handled by the existing pipeline (via
/// the controller's bridge into UserPreferencesModel); this adapter adds the
/// capabilities that live purely in [ThemeData]:
///
/// * **Larger touch targets** — `visualDensity` + `materialTapTargetSize`.
/// * **Bold text** — bumps font weight across the text theme.
/// * **Reduced motion** — swaps page transitions for an instant builder.
/// * **Color-vision** — hook prepared (no filter applied yet in Phase 1).
///
/// Applying it is a pure function, so it is trivial to unit-test and cannot
/// leak state. Wiring is additive: `app.dart` passes its themes through
/// [AccessibilityThemeAdapter.apply] and everything else stays the same.
class AccessibilityThemeAdapter {
  const AccessibilityThemeAdapter._();

  static ThemeData apply(ThemeData base, AccessibilityProfile profile) {
    final display = profile.display;

    var theme = base;

    // Larger, easier touch targets.
    if (display.largeTapTargets) {
      theme = theme.copyWith(
        visualDensity: const VisualDensity(horizontal: 1.5, vertical: 1.5),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      );
    }

    // Bolder text for low-vision comfort (does not change fonts or colors).
    if (display.boldText) {
      theme = theme.copyWith(
        textTheme: _bolden(theme.textTheme),
        primaryTextTheme: _bolden(theme.primaryTextTheme),
      );
    }

    // Reduced motion: make platform page transitions instant across the app.
    if (display.reduceMotion) {
      theme = theme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoTransitionsBuilder(),
            TargetPlatform.iOS: _NoTransitionsBuilder(),
            TargetPlatform.fuchsia: _NoTransitionsBuilder(),
            TargetPlatform.linux: _NoTransitionsBuilder(),
            TargetPlatform.macOS: _NoTransitionsBuilder(),
            TargetPlatform.windows: _NoTransitionsBuilder(),
          },
        ),
      );
    }

    // Color-vision hook: intentionally a no-op in Phase 1. A future phase can
    // enable a ColorFilter/scheme swap here keyed on profile.display.colorVision
    // without changing any call site.
    return theme;
  }

  static TextTheme _bolden(TextTheme t) {
    TextStyle? b(TextStyle? s) => s?.copyWith(
          fontWeight: _bumpWeight(s.fontWeight ?? FontWeight.w400),
        );
    return t.copyWith(
      displayLarge: b(t.displayLarge),
      displayMedium: b(t.displayMedium),
      displaySmall: b(t.displaySmall),
      headlineLarge: b(t.headlineLarge),
      headlineMedium: b(t.headlineMedium),
      headlineSmall: b(t.headlineSmall),
      titleLarge: b(t.titleLarge),
      titleMedium: b(t.titleMedium),
      titleSmall: b(t.titleSmall),
      bodyLarge: b(t.bodyLarge),
      bodyMedium: b(t.bodyMedium),
      bodySmall: b(t.bodySmall),
      labelLarge: b(t.labelLarge),
      labelMedium: b(t.labelMedium),
      labelSmall: b(t.labelSmall),
    );
  }

  static FontWeight _bumpWeight(FontWeight w) {
    const order = FontWeight.values;
    final i = order.indexOf(w);
    // Bump two steps (e.g. w400 → w600) but never past w900.
    return order[(i + 2).clamp(0, order.length - 1)];
  }
}

/// Page transition builder that renders the destination immediately with no
/// animation — the reduced-motion equivalent of a platform transition.
class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}
