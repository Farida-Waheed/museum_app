import '../models/exhibit_metadata.dart';
import '../models/narration_policy.dart';
import 'narration_conversation_context.dart';

/// Owns and evolves the single [NarrationConversationContext] for a tour so that
/// follow-up questions stay exhibit-aware across stops. It is the audio-
/// description analogue of the chat layer's context builder: it PREPARES context
/// for the existing AI/chat infrastructure and never calls a model itself (no
/// second AI client, no network/Firebase).
///
/// Lifecycle:
/// * [onNarrationComplete] — a new exhibit was narrated: replace the context and
///   reset the follow-up history (a new exhibit is a fresh conversation).
/// * [recordFollowUp] — remember a visitor question about the current exhibit.
/// * [enrichFollowUp] — turn a bare follow-up into an exhibit-grounded prompt
///   string for the AI, so "tell me more" resolves against the right artifact.
/// * [clear] — the visitor left the exhibit / tour ended (language preserved).
///
/// Pure Dart, DI-friendly: an optional [clock] makes timestamps testable, and
/// [maxFollowUps] caps memory.
class ConversationContextManager {
  ConversationContextManager({
    DateTime Function()? clock,
    int maxFollowUps = 5,
    String initialLanguage = 'en',
  })  : _clock = clock ?? DateTime.now,
        _maxFollowUps = maxFollowUps,
        _context = NarrationConversationContext(language: initialLanguage);

  final DateTime Function() _clock;
  final int _maxFollowUps;

  NarrationConversationContext _context;

  /// The current context snapshot (immutable).
  NarrationConversationContext get current => _context;

  /// Record that a narration finished for an exhibit. This REPLACES the exhibit
  /// context: if it is a different exhibit, the follow-up history is reset (a new
  /// exhibit starts a fresh conversation); re-narrating the same exhibit keeps
  /// the accumulated follow-ups.
  NarrationConversationContext onNarrationComplete({
    required ExhibitMetadata metadata,
    required String narration,
    required NarrationPolicy policy,
    String? language,
  }) {
    final sameExhibit = _context.exhibitId == metadata.id;
    _context = NarrationConversationContext(
      exhibitId: metadata.id,
      metadata: metadata,
      lastNarration: narration,
      narrationAt: _clock(),
      language: language ?? _context.language,
      policy: policy,
      recentFollowUps: sameExhibit ? _context.recentFollowUps : const [],
    );
    return _context;
  }

  /// Remember a visitor follow-up question about the current exhibit, capped at
  /// [maxFollowUps] (oldest dropped first). No-op for blank input.
  NarrationConversationContext recordFollowUp(String question) {
    final q = question.trim();
    if (q.isEmpty) return _context;

    final updated = [..._context.recentFollowUps, q];
    final capped = updated.length > _maxFollowUps
        ? updated.sublist(updated.length - _maxFollowUps)
        : updated;
    _context = _context.copyWith(recentFollowUps: capped);
    return _context;
  }

  /// Enrich a bare follow-up question with the current exhibit context, yielding
  /// a grounded prompt string the EXISTING chat/AI layer can answer. When there
  /// is no exhibit in context, the question is returned trimmed and unchanged.
  ///
  /// Enriching does not itself record the question — call [recordFollowUp] (or
  /// pass [remember]) to add it to history.
  String enrichFollowUp(String question, {bool remember = false}) {
    final q = question.trim();
    final ctx = _context;
    if (!ctx.hasExhibit || ctx.metadata == null) {
      if (remember) recordFollowUp(q);
      return q;
    }

    final ar = ctx.language == 'ar';
    final m = ctx.metadata!;
    final b = StringBuffer();

    b.writeln(ar
        ? 'الزائر يستمع حالياً إلى شرح عن: ${m.title}.'
        : 'The visitor is currently hearing about: ${m.title}.');
    if (ctx.recentFollowUps.isNotEmpty) {
      b.writeln(ar
          ? 'أسئلة سابقة: ${ctx.recentFollowUps.join(' | ')}'
          : 'Earlier questions: ${ctx.recentFollowUps.join(' | ')}');
    }
    b.writeln(ar
        ? 'سؤال المتابعة: $q'
        : 'Follow-up question: $q');
    b.write(ar
        ? 'أجب مع الأخذ في الاعتبار هذه القطعة تحديداً.'
        : 'Answer with this specific exhibit in mind.');

    if (remember) recordFollowUp(q);
    return b.toString();
  }

  /// Clear the exhibit context (visitor moved on / tour ended). The active
  /// [language] is preserved so the next narration stays in the visitor's
  /// language unless explicitly changed.
  NarrationConversationContext clear() {
    _context = NarrationConversationContext(language: _context.language);
    return _context;
  }

  /// Update just the active language (e.g. the visitor switched languages
  /// mid-tour) without disturbing the rest of the context.
  NarrationConversationContext setLanguage(String language) {
    _context = _context.copyWith(language: language);
    return _context;
  }
}
