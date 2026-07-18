import '../models/exhibit_id.dart';
import '../models/exhibit_metadata.dart';
import '../models/narration_policy.dart';

/// An immutable snapshot of what Horus is currently narrating and what the
/// visitor has recently asked about it — the memory that makes follow-up
/// questions exhibit-aware ("tell me more", "why is it broken?") without the
/// visitor repeating which exhibit they mean.
///
/// This is deliberately pure data (no AI/network/Firebase/UI): it feeds the
/// existing chat/AI layer as context, exactly as `ChatContext` does, rather than
/// calling any model itself. [ConversationContextManager] owns the mutable
/// current value; this type is only ever a value snapshot.
class NarrationConversationContext {
  /// The exhibit currently in context, or null before any narration.
  final ExhibitId? exhibitId;

  /// The metadata for [exhibitId] (facts available for enrichment).
  final ExhibitMetadata? metadata;

  /// The last narration Horus produced for this exhibit.
  final String? lastNarration;

  /// When [lastNarration] was recorded.
  final DateTime? narrationAt;

  /// The active narration language ('en' / 'ar'). Preserved across exhibit
  /// changes so a follow-up stays in the visitor's language.
  final String language;

  /// The policy the current narration was produced under.
  final NarrationPolicy? policy;

  /// The visitor's recent follow-up questions about THIS exhibit, oldest→newest.
  final List<String> recentFollowUps;

  const NarrationConversationContext({
    this.exhibitId,
    this.metadata,
    this.lastNarration,
    this.narrationAt,
    this.language = 'en',
    this.policy,
    this.recentFollowUps = const [],
  });

  /// The initial, empty context (language defaults to English; the manager can
  /// seed a different language).
  static const NarrationConversationContext empty =
      NarrationConversationContext();

  /// Whether an exhibit is currently in context.
  bool get hasExhibit => exhibitId != null;

  /// Whether a narration has been recorded for the current exhibit.
  bool get hasNarration => (lastNarration?.isNotEmpty ?? false);

  NarrationConversationContext copyWith({
    ExhibitId? exhibitId,
    ExhibitMetadata? metadata,
    String? lastNarration,
    DateTime? narrationAt,
    String? language,
    NarrationPolicy? policy,
    List<String>? recentFollowUps,
  }) =>
      NarrationConversationContext(
        exhibitId: exhibitId ?? this.exhibitId,
        metadata: metadata ?? this.metadata,
        lastNarration: lastNarration ?? this.lastNarration,
        narrationAt: narrationAt ?? this.narrationAt,
        language: language ?? this.language,
        policy: policy ?? this.policy,
        recentFollowUps: recentFollowUps ?? this.recentFollowUps,
      );

  @override
  String toString() =>
      'NarrationConversationContext(${exhibitId ?? 'none'}, $language, '
      'narration: ${hasNarration ? 'yes' : 'no'}, '
      'followUps: ${recentFollowUps.length})';
}
