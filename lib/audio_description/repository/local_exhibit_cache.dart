import '../models/exhibit_id.dart';
import '../models/exhibit_metadata.dart';

/// Device-local cache of exhibit metadata for offline narration — the offline-
/// first layer for the Audio Description engine, mirroring the role of
/// `AccessibilityLocalStore`. Kept as an interface so the durable backing
/// (Hive / SharedPreferences / a file) can be added in a later task without
/// touching the repository or its callers; [InMemoryExhibitCache] is the default
/// and the test double.
///
/// Contract for every implementation:
/// * All methods degrade gracefully — a cache fault must never crash a tour, so
///   [read] returns `null` on any error rather than throwing.
/// * [write] is idempotent (last write wins per id).
abstract class LocalExhibitCache {
  /// The cached metadata for [id], or `null` if nothing is cached (or on any
  /// storage fault).
  Future<ExhibitMetadata?> read(ExhibitId id);

  /// Cache [metadata], overwriting any prior entry for the same id.
  Future<void> write(ExhibitMetadata metadata);

  /// True when metadata for [id] is currently cached.
  Future<bool> contains(ExhibitId id);

  /// Remove one entry (no-op if absent).
  Future<void> remove(ExhibitId id);

  /// Drop everything cached.
  Future<void> clear();
}

/// Volatile [LocalExhibitCache] backed by a plain map. This is the default cache
/// and the test double — no plugin, no disk, fully deterministic. A durable
/// implementation added later can be swapped in via constructor injection with
/// zero changes to [CachedExhibitRepository].
class InMemoryExhibitCache implements LocalExhibitCache {
  InMemoryExhibitCache([Map<ExhibitId, ExhibitMetadata>? seed])
      : _store = {...?seed};

  final Map<ExhibitId, ExhibitMetadata> _store;

  /// How many entries are currently cached (test/introspection aid).
  int get length => _store.length;

  @override
  Future<ExhibitMetadata?> read(ExhibitId id) async => _store[id];

  @override
  Future<void> write(ExhibitMetadata metadata) async {
    _store[metadata.id] = metadata;
  }

  @override
  Future<bool> contains(ExhibitId id) async => _store.containsKey(id);

  @override
  Future<void> remove(ExhibitId id) async {
    _store.remove(id);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}
