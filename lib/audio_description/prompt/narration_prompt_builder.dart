import 'package:museum_app/accessibility/accessibility.dart';

import '../models/audio_description_enums.dart';
import '../models/exhibit_description.dart';
import '../models/exhibit_metadata.dart';
import '../models/narration_policy.dart';
import '../models/narration_preferences.dart';
import 'narration_prompt.dart';

/// Turns exhibit facts + the resolved [NarrationPolicy] into a structured,
/// bilingual [NarrationPrompt] for the AI backend. This is a *pure text*
/// transformation — it NEVER calls an AI service, opens a socket, or touches
/// Firebase; Task 5 owns sending the produced prompt.
///
/// It follows the bilingual, directive-list style of
/// `AccessibilityProfile.toAiDirectives` (reused directly here) so accessibility
/// adaptations are phrased once and consistently across the app. The policy —
/// not raw profile inspection — decides length, layers, tone, and audience, so
/// the "adapt automatically to the visitor" rule lives in one tested place
/// (Task 2) and this builder only renders it.
class NarrationPromptBuilder {
  const NarrationPromptBuilder();

  /// Build the prompt. [description] is optional: when a cached/prior
  /// [ExhibitDescription] exists it is offered to the AI as prior material to
  /// avoid repetition; otherwise the AI works from [metadata] alone.
  NarrationPrompt build({
    required ExhibitMetadata metadata,
    required NarrationPolicy policy,
    required AccessibilityProfile profile,
    NarrationPreferences preferences = NarrationPreferences.defaults,
    ExhibitDescription? description,
    String language = 'en',
  }) {
    final ar = language == 'ar';
    final layers = policy.orderedLayers;

    final systemPrompt = _system(ar, policy, preferences, layers);
    final userPrompt =
        _user(ar, metadata, policy, profile, layers, description, language);

    return NarrationPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      language: language,
      length: policy.length,
      layers: layers,
    );
  }

  // ---------------------------------------------------------------------------
  // System prompt: role, tone, audience, output constraints.
  // ---------------------------------------------------------------------------
  String _system(
    bool ar,
    NarrationPolicy policy,
    NarrationPreferences preferences,
    List<StoryLayer> layers,
  ) {
    final lines = <String>[];

    lines.add(ar
        ? 'أنت "حورس"، مرشد متحفي ذكي يقف بجانب الزائر ويصف القطع الأثرية بأسلوب طبيعي وجذّاب.'
        : 'You are "Horus", an intelligent museum guide standing beside the visitor, describing artifacts in a natural, engaging way.');

    // Tone / audience.
    lines.add(_toneLine(ar, policy, preferences));

    // Output constraints (the required list).
    lines.add(ar ? 'قيود الإخراج:' : 'Output constraints:');
    for (final c in _constraints(ar, policy)) {
      lines.add('- $c');
    }

    return lines.join('\n');
  }

  String _toneLine(bool ar, NarrationPolicy policy, NarrationPreferences prefs) {
    if (policy.childMode) {
      return ar
          ? 'الجمهور المستهدف: طفل. استخدم أسلوب القصة، والتشبيهات، وأسئلة تفاعلية بسيطة وممتعة.'
          : 'Target audience: a child. Use a storytelling tone, comparisons, and simple, fun interactive questions.';
    }
    if (policy.researchMode) {
      return ar
          ? 'الجمهور المستهدف: باحث. قدّم عمقاً تاريخياً وأثرياً ودقة أكاديمية.'
          : 'Target audience: a researcher. Provide historical and archaeological depth with academic precision.';
    }
    switch (policy.educationalDepth) {
      case EducationalDepth.educational:
        return ar
            ? 'الجمهور المستهدف: طالب. أضف تفاصيل تعليمية مفيدة.'
            : 'Target audience: a student. Include useful educational detail.';
      case EducationalDepth.academic:
        return ar
            ? 'الجمهور المستهدف: باحث. قدّم عمقاً أكاديمياً.'
            : 'Target audience: a researcher. Provide academic depth.';
      case EducationalDepth.casual:
        return ar
            ? 'الجمهور المستهدف: زائر عام. حافظ على أسلوب ودود وسهل.'
            : 'Target audience: a general visitor. Keep a warm, easy tone.';
    }
  }

  List<String> _constraints(bool ar, NarrationPolicy policy) {
    final c = <String>[
      ar
          ? 'التزم بالحقائق فقط ولا تختلق أي معلومة.'
          : 'Stay strictly factual; do not invent or hallucinate any information.',
      ar
          ? 'لا تكرر المعلومات نفسها.'
          : 'Do not repeat the same information.',
      ar
          ? 'احترم طول السرد المطلوب: ${_lengthPhrase(true, policy.length)}.'
          : 'Respect the requested narration length: ${_lengthPhrase(false, policy.length)}.',
      ar
          ? 'استخدم لغة منطوقة طبيعية مناسبة للاستماع لا للقراءة.'
          : 'Produce natural spoken language, meant to be heard, not read.',
      ar
          ? 'اكتب السرد بالكامل باللغة العربية.'
          : 'Write the entire narration in English.',
    ];

    if (policy.useSimpleLanguage) {
      c.add(ar
          ? 'استخدم جملاً قصيرة ومفردات بسيطة.'
          : 'Use short sentences and simple vocabulary.');
    }
    if (policy.inviteFollowUp) {
      c.add(ar
          ? 'اختم بسؤال متابعة يدعو الزائر لمعرفة المزيد.'
          : 'End with an inviting follow-up question that encourages the visitor to learn more.');
    }
    return c;
  }

  // ---------------------------------------------------------------------------
  // User prompt: the exhibit facts + what to produce.
  // ---------------------------------------------------------------------------
  String _user(
    bool ar,
    ExhibitMetadata m,
    NarrationPolicy policy,
    AccessibilityProfile profile,
    List<StoryLayer> layers,
    ExhibitDescription? description,
    String language,
  ) {
    final b = StringBuffer();

    b.writeln(ar ? 'معلومات القطعة الأثرية:' : 'Exhibit information:');
    b.writeln('${ar ? 'الاسم' : 'Title'}: ${m.title}');
    _factLine(b, ar ? 'الموقع' : 'Location', m.location);
    _factLine(b, ar ? 'الفترة التاريخية' : 'Historical period', m.period);
    _factLine(b, ar ? 'الوصف المادي' : 'Physical description',
        m.physicalDescription);
    _factLine(b, ar ? 'السياق التاريخي' : 'Historical context',
        m.historicalContext);
    if (m.interestingFacts.isNotEmpty) {
      b.writeln(ar ? 'حقائق مثيرة للاهتمام:' : 'Interesting facts:');
      for (final f in m.interestingFacts) {
        b.writeln('- $f');
      }
    }

    // Requested layers.
    b.writeln();
    b.writeln(ar
        ? 'غطِّ الطبقات التالية بهذا الترتيب:'
        : 'Cover the following layers, in this order:');
    for (final layer in layers) {
      b.writeln('- ${_layerPhrase(ar, layer)}');
    }
    if (policy.emphasizePhysicalDescription) {
      b.writeln(ar
          ? 'أعطِ وصفاً مادياً غنياً للغاية لأن الزائر يعتمد على الوصف الصوتي.'
          : 'Give an especially rich physical description; the visitor relies on audio description.');
    }

    // Accessibility adaptations — reuse the profile's own bilingual directives.
    final directives = profile.toAiDirectives(language: language);
    if (directives.isNotEmpty) {
      b.writeln();
      b.writeln(directives);
    }

    // Prior material to avoid repetition (optional).
    if (description != null && !description.isEmpty) {
      b.writeln();
      b.writeln(ar
          ? 'مادة سابقة (لا تكررها حرفياً، طوّرها فقط):'
          : 'Prior material (do not repeat verbatim; build on it):');
      b.writeln(description.fullText);
    }

    return b.toString().trimRight();
  }

  void _factLine(StringBuffer b, String label, String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    b.writeln('$label: $v');
  }

  String _layerPhrase(bool ar, StoryLayer layer) {
    switch (layer) {
      case StoryLayer.visual:
        return ar
            ? 'الوصف البصري: الشكل، الحجم، الألوان، المواد، الملمس، الموضع، التفاصيل الزخرفية.'
            : 'Visual description: shape, size, colours, materials, texture, position, decorative detail.';
      case StoryLayer.historical:
        return ar
            ? 'السياق التاريخي: من صنعها، ومتى، ولماذا، وأهميتها.'
            : 'Historical context: who made it, when, why, and its significance.';
      case StoryLayer.story:
        return ar
            ? 'قصة شيّقة أو حقيقة مثيرة تُضفي الحياة على القطعة.'
            : 'An engaging story or interesting fact that brings the artifact to life.';
      case StoryLayer.accessibility:
        return ar
            ? 'تحسين الوصول: صف ما يُدرك عادةً بالبصر (تعابير الوجه، الملابس، الرموز، النقوش، الحجم النسبي، الاتجاه).'
            : 'Accessibility enhancement: describe what is normally seen (facial expressions, clothing, symbols, carvings, relative size, orientation).';
    }
  }

  String _lengthPhrase(bool ar, NarrationLength length) {
    switch (length) {
      case NarrationLength.short:
        return ar ? 'قصير (30–45 ثانية)' : 'short (30–45 seconds)';
      case NarrationLength.standard:
        return ar ? 'قياسي (1–2 دقيقة)' : 'standard (1–2 minutes)';
      case NarrationLength.detailed:
        return ar ? 'مفصّل (3–5 دقائق)' : 'detailed (3–5 minutes)';
    }
  }
}
