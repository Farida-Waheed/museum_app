import '../models/exhibit_id.dart';
import '../models/exhibit_metadata.dart';

/// Why an exhibit lookup did not return metadata, so callers can react
/// specifically (fall back to a generic narration for [notFound], retry / show
/// an offline hint for [sourceUnavailable]) instead of treating every empty
/// result the same. Mirrors the "never throw for not-found; degrade safely"
/// ethos of the accessibility repository.
enum ExhibitLookupStatus {
  /// Metadata was found (from cache or the source).
  found('found'),

  /// The exhibit genuinely does not exist in the source.
  notFound('not_found'),

  /// The source could not be reached (offline / backend error) and nothing was
  /// cached — a transient failure, distinct from a genuine "not found".
  sourceUnavailable('source_unavailable');

  const ExhibitLookupStatus(this.storageKey);

  final String storageKey;

  bool get isFound => this == ExhibitLookupStatus.found;
}

/// The outcome of an exhibit lookup: either the [metadata] with
/// [ExhibitLookupStatus.found], or a reason it is absent. Immutable value
/// object; a lookup NEVER throws for missing data, so the description engine can
/// always fall back gracefully.
class ExhibitLookupResult {
  final ExhibitLookupStatus status;
  final ExhibitMetadata? metadata;

  /// Whether this result was served from the local cache (vs. the source). Lets
  /// callers/analytics distinguish an offline cache hit from a fresh fetch.
  final bool fromCache;

  const ExhibitLookupResult._(this.status, this.metadata, this.fromCache);

  factory ExhibitLookupResult.found(
    ExhibitMetadata metadata, {
    bool fromCache = false,
  }) =>
      ExhibitLookupResult._(ExhibitLookupStatus.found, metadata, fromCache);

  static const ExhibitLookupResult notFound =
      ExhibitLookupResult._(ExhibitLookupStatus.notFound, null, false);

  static const ExhibitLookupResult sourceUnavailable =
      ExhibitLookupResult._(ExhibitLookupStatus.sourceUnavailable, null, false);

  bool get isFound => status.isFound && metadata != null;

  @override
  bool operator ==(Object other) =>
      other is ExhibitLookupResult &&
      other.status == status &&
      other.metadata == metadata &&
      other.fromCache == fromCache;

  @override
  int get hashCode => Object.hash(status, metadata, fromCache);

  @override
  String toString() {
    final id = metadata?.id;
    return 'ExhibitLookupResult(${status.storageKey}'
        '${id != null ? ', $id' : ''}${fromCache ? ', cached' : ''})';
  }
}

/// The read contract for exhibit data, whatever the consumer (engine, UI,
/// analytics). Exposed so callers depend on the abstraction, never on the
/// cache-first implementation or a specific backend.
abstract class ExhibitRepository {
  /// Look up one exhibit by id. Never throws for a missing exhibit or a source
  /// failure — returns an [ExhibitLookupResult] whose status explains the case.
  Future<ExhibitLookupResult> getExhibit(ExhibitId id);
}
