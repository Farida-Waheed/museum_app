import 'package:museum_app/accessibility/accessibility.dart';

/// Registers the Voice Communication Engine's features with the shared
/// [AccessibilityFeatureRegistry] (Phase 1 spec #18), so the home "accessibility
/// hub", navigation, and analytics can discover them generically — no shared
/// code edits, exactly as later phases were designed to plug in.
///
/// Idempotent: safe to call on every controller initialization.
class VoiceFeatureRegistration {
  const VoiceFeatureRegistration._();

  static void register() {
    final registry = AccessibilityFeatureRegistry.instance;

    registry.register(AccessibilityFeature(
      id: AccessibilityFeatureRegistry.voiceNavigation,
      // Available whenever the visitor wants spoken guidance or relies on the
      // screen reader — derived from the Phase-2 profile.
      appliesTo: (profile) =>
          profile.voice.voiceGuidanceEnabled ||
          profile.voice.screenReaderFirst ||
          profile.navigation.announceDirections,
    ));

    registry.register(AccessibilityFeature(
      id: AccessibilityFeatureRegistry.audioDescription,
      appliesTo: (profile) =>
          profile.voice.audioDescriptionEnabled ||
          profile.voice.screenReaderFirst,
    ));
  }
}
