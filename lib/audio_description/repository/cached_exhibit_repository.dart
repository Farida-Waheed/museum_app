import '../models/exhibit_id.dart';
import '../models/exhibit_metadata.dart';
import 'exhibit_data_source.dart';
import 'exhibit_lookup_result.dart';
import 'local_exhibit_cache.dart';

/// Cache-first [ExhibitRepository]: the layer the Audio Description engine reads
/// exhibit metadata through. It composes a [LocalExhibitCache] (offline-first
/// speed + resilience) with an [ExhibitDataSource] (the authoritative backend),
/// following the same DI + graceful-degradation ethos as
/// `VoiceSettingsRepository` and `AccessibilityRepository`.
///
/// Lookup strategy (per the Task 3 spec):
///   1. Return cached metadata if present (a "frequently visited exhibit").
///   2. Otherwise fetch from the data source.
///   3. Cache a successful fetch, then return it.
///
/// Graceful failure:
///   * A source that returns `null` → [ExhibitLookupStatus.notFound].
///   * A source that THROWS (offline / backend error) with no cached copy →
///     [ExhibitLookupStatus.sourceUnavailable]. The lookup itself never throws,
///     so the engine can always fall back to a generic narration.
///
/// Everything is injected: the concrete Firebase source and a durable cache can
/// be dropped in later with no change here.
class CachedExhibitRepository implements ExhibitRepository {
  CachedExhibitRepository({
    required ExhibitDataSource source,
    LocalExhibitCache? cache,
  })  : _source = source,
        _cache = cache ?? InMemoryExhibitCache();

  final ExhibitDataSource _source;
  final LocalExhibitCache _cache;

  @override
  Future<ExhibitLookupResult> getExhibit(ExhibitId id) async {
    // 1. Cache-first: a hit serves instantly and works fully offline.
    final cached = await _readCache(id);
    if (cached != null) {
      return ExhibitLookupResult.found(cached, fromCache: true);
    }

    // 2. Miss → go to the authoritative source. A genuine "not found" is a
    //    clean, non-throwing null; only a real backend fault throws.
    try {
      final fetched = await _source.fetch(id);
      if (fetched == null) return ExhibitLookupResult.notFound;

      // 3. Cache the successful result for next time (best-effort — a cache
      //    write fault must not fail the lookup).
      await _writeCache(fetched);
      return ExhibitLookupResult.found(fetched);
    } catch (_) {
      // Offline / backend error and nothing cached: a transient failure,
      // distinct from a genuine missing exhibit.
      return ExhibitLookupResult.sourceUnavailable;
    }
  }

  Future<ExhibitMetadata?> _readCache(ExhibitId id) async {
    try {
      return await _cache.read(id);
    } catch (_) {
      // A cache fault must never break a lookup — treat it as a miss.
      return null;
    }
  }

  Future<void> _writeCache(ExhibitMetadata metadata) async {
    try {
      await _cache.write(metadata);
    } catch (_) {
      // Best-effort; a failed write just means the next lookup re-fetches.
    }
  }
}
