import 'package:museum_app/accessibility/accessibility.dart';

import '../models/audio_description_enums.dart';
import '../models/narration_policy.dart';
import '../models/narration_preferences.dart';

/// Derives the effective [NarrationPolicy] by combining:
/// 1. the visitor's [AccessibilityProfile] (the accessibility baseline), and
/// 2. their [NarrationPreferences] (audience + explicit length override).
///
/// This is the audio-description analogue of `VoiceSettingsRepository` from
/// Phase 3: the profile→policy mapping is a *pure, static, exhaustively-testable
/// function* with no AI, networking, Firebase, UI, or voice imports. It reuses
/// the existing [AccessibilityProfile] rather than duplicating any of its
/// settings — the profile stays the single source of truth for needs, and this
/// layer only decides how those needs shape storytelling.
///
/// Nothing here mutates state; [NarrationProfileMapper.resolve] is a function.
class NarrationProfileMapper {
  const NarrationProfileMapper._();

  /// The core mapping: profile + preferences → a fully-resolved policy.
  static NarrationPolicy resolve(
    AccessibilityProfile profile, {
    NarrationPreferences preferences = NarrationPreferences.defaults,
  }) {
    final voice = profile.voice;
    final tour = profile.tour;
    final audience = preferences.audience;

    // --- Need signals read from the existing profile (never duplicated) -------
    final visualNeed = profile.hasCategory(AccessibilityCategory.visualImpairment) ||
        voice.audioDescriptionEnabled ||
        voice.screenReaderFirst;
    final cognitiveNeed =
        profile.hasCategory(AccessibilityCategory.cognitiveAssistance) ||
            tour.explanationLevel.prefersSimpleLanguage;

    // --- Audience modes -------------------------------------------------------
    final childMode = audience.isChild;
    final researchMode = audience.isResearcher;

    // --- Simple language ------------------------------------------------------
    // Cognitive assistance and child mode both want short, clear sentences.
    final useSimpleLanguage = cognitiveNeed || childMode;

    // --- Educational depth ----------------------------------------------------
    // Research wins outright; students get educational depth; everyone else
    // (incl. children) stays casual. Cognitive assistance never forces depth up.
    final educationalDepth = _depthFor(audience);

    // --- Physical-description emphasis ---------------------------------------
    // Visitors who cannot rely on sight always get rich physical description and
    // the dedicated accessibility layer.
    final emphasizePhysical = visualNeed;

    // --- Length ---------------------------------------------------------------
    // An explicit visitor choice always wins; otherwise derive from need/audience.
    final length = preferences.lengthOverride ??
        _deriveLength(
          visualNeed: visualNeed,
          cognitiveNeed: cognitiveNeed,
          researchMode: researchMode,
          childMode: childMode,
          profileDetailed: tour.explanationLevel == ExplanationLevel.detailed,
          highlightsOnly: tour.highlightsOnly,
        );

    // --- Story layers ---------------------------------------------------------
    final layers = _layersFor(
      visualNeed: visualNeed,
      cognitiveNeed: cognitiveNeed,
      childMode: childMode,
      researchMode: researchMode,
    );

    // --- Follow-up invitation -------------------------------------------------
    // Encourage conversation, but not for the most concise cognitive telling
    // where an extra question adds load. Children love the invitation.
    final inviteFollowUp = !cognitiveNeed || childMode;

    return NarrationPolicy(
      length: length,
      layers: layers,
      useSimpleLanguage: useSimpleLanguage,
      educationalDepth: educationalDepth,
      childMode: childMode,
      researchMode: researchMode,
      emphasizePhysicalDescription: emphasizePhysical,
      inviteFollowUp: inviteFollowUp,
    );
  }

  static EducationalDepth _depthFor(VisitorAudience audience) {
    switch (audience) {
      case VisitorAudience.researcher:
        return EducationalDepth.academic;
      case VisitorAudience.student:
        return EducationalDepth.educational;
      case VisitorAudience.general:
      case VisitorAudience.child:
        return EducationalDepth.casual;
    }
  }

  static NarrationLength _deriveLength({
    required bool visualNeed,
    required bool cognitiveNeed,
    required bool researchMode,
    required bool childMode,
    required bool profileDetailed,
    required bool highlightsOnly,
  }) {
    // Cognitive assistance keeps it short and digestible — this takes priority
    // so a cognitive+visual visitor is not overwhelmed by a 5-minute telling.
    if (cognitiveNeed) return NarrationLength.short;
    // "Highlights only" pacing also implies brevity.
    if (highlightsOnly) return NarrationLength.short;
    // Researchers and visitors relying on rich audio description want depth.
    if (researchMode || visualNeed || profileDetailed) {
      return NarrationLength.detailed;
    }
    // Children get an engaging-but-not-exhausting standard telling.
    return NarrationLength.standard;
  }

  static Set<StoryLayer> _layersFor({
    required bool visualNeed,
    required bool cognitiveNeed,
    required bool childMode,
    required bool researchMode,
  }) {
    // Cognitive assistance: minimise load — the essentials only.
    if (cognitiveNeed) {
      return {StoryLayer.visual, StoryLayer.historical};
    }

    final layers = <StoryLayer>{StoryLayer.visual, StoryLayer.historical};

    // Visitors relying on audio description always get the dedicated
    // accessibility-enhancement layer (facial expressions, symbols, orientation).
    if (visualNeed) layers.add(StoryLayer.accessibility);

    // Children and general/student visitors benefit from the engaging story;
    // researchers get it too (it never hurts depth).
    layers.add(StoryLayer.story);

    // Researchers get the full set including the accessibility layer's extra
    // physical/archaeological detail.
    if (researchMode) layers.add(StoryLayer.accessibility);

    return layers;
  }
}
