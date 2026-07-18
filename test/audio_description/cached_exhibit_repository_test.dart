import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/audio_description/models/exhibit_id.dart';
import 'package:museum_app/audio_description/models/exhibit_metadata.dart';
import 'package:museum_app/audio_description/repository/cached_exhibit_repository.dart';
import 'package:museum_app/audio_description/repository/exhibit_data_source.dart';
import 'package:museum_app/audio_description/repository/exhibit_lookup_result.dart';
import 'package:museum_app/audio_description/repository/local_exhibit_cache.dart';

/// A scripted [ExhibitDataSource] test double: it returns whatever metadata was
/// seeded for an id, `null` for an unknown id (genuine "not found"), and throws
/// when [failing] is set (simulating offline / a backend error). It counts
/// fetches so tests can assert cache-first behavior avoids redundant calls.
class _FakeExhibitDataSource implements ExhibitDataSource {
  _FakeExhibitDataSource([Map<ExhibitId, ExhibitMetadata>? seed])
      : _store = {...?seed};

  final Map<ExhibitId, ExhibitMetadata> _store;

  /// When true, [fetch] throws to simulate an unreachable source.
  bool failing = false;

  /// Number of times [fetch] was invoked (per-id counts too).
  int fetchCount = 0;
  final Map<ExhibitId, int> fetchCountsById = {};

  void seed(ExhibitMetadata metadata) => _store[metadata.id] = metadata;

  @override
  Future<ExhibitMetadata?> fetch(ExhibitId id) async {
    fetchCount++;
    fetchCountsById.update(id, (n) => n + 1, ifAbsent: () => 1);
    if (failing) throw StateError('source unavailable');
    return _store[id];
  }
}

/// A [LocalExhibitCache] whose reads/writes can be made to throw, to prove the
/// repository degrades gracefully around a faulty cache.
class _FaultyCache implements LocalExhibitCache {
  bool failReads = false;
  bool failWrites = false;
  final InMemoryExhibitCache _delegate = InMemoryExhibitCache();

  @override
  Future<ExhibitMetadata?> read(ExhibitId id) async {
    if (failReads) throw StateError('cache read fault');
    return _delegate.read(id);
  }

  @override
  Future<void> write(ExhibitMetadata metadata) async {
    if (failWrites) throw StateError('cache write fault');
    return _delegate.write(metadata);
  }

  @override
  Future<bool> contains(ExhibitId id) => _delegate.contains(id);

  @override
  Future<void> remove(ExhibitId id) => _delegate.remove(id);

  @override
  Future<void> clear() => _delegate.clear();
}

ExhibitMetadata _meta(String id, {String title = 'Statue'}) => ExhibitMetadata(
      id: ExhibitId(id),
      title: title,
    );

void main() {
  final rosettaId = ExhibitId('rosetta');
  final rosetta = _meta('rosetta', title: 'Rosetta Stone');

  group('CachedExhibitRepository cache-first strategy', () {
    test('cache hit: serves from cache without ever touching the source', () async {
      final source = _FakeExhibitDataSource();
      final cache = InMemoryExhibitCache({rosettaId: rosetta});
      final repo = CachedExhibitRepository(source: source, cache: cache);

      final result = await repo.getExhibit(rosettaId);

      expect(result.isFound, isTrue);
      expect(result.status, ExhibitLookupStatus.found);
      expect(result.metadata, rosetta);
      expect(result.fromCache, isTrue);
      expect(source.fetchCount, 0, reason: 'a cache hit must not hit the source');
    });

    test('cache miss: fetches from the source and marks it not-from-cache', () async {
      final source = _FakeExhibitDataSource({rosettaId: rosetta});
      final cache = InMemoryExhibitCache();
      final repo = CachedExhibitRepository(source: source, cache: cache);

      final result = await repo.getExhibit(rosettaId);

      expect(result.isFound, isTrue);
      expect(result.metadata, rosetta);
      expect(result.fromCache, isFalse);
      expect(source.fetchCount, 1);
    });

    test('cache update: a successful fetch is written back to the cache', () async {
      final source = _FakeExhibitDataSource({rosettaId: rosetta});
      final cache = InMemoryExhibitCache();
      final repo = CachedExhibitRepository(source: source, cache: cache);

      expect(await cache.contains(rosettaId), isFalse);
      await repo.getExhibit(rosettaId);
      expect(await cache.contains(rosettaId), isTrue);
      expect(await cache.read(rosettaId), rosetta);
      expect(cache.length, 1);
    });

    test('repeated requests: only the first hits the source, rest are cached', () async {
      final source = _FakeExhibitDataSource({rosettaId: rosetta});
      final repo = CachedExhibitRepository(source: source);

      final first = await repo.getExhibit(rosettaId);
      final second = await repo.getExhibit(rosettaId);
      final third = await repo.getExhibit(rosettaId);

      expect(source.fetchCount, 1, reason: 'subsequent lookups serve from cache');
      expect(first.fromCache, isFalse);
      expect(second.fromCache, isTrue);
      expect(third.fromCache, isTrue);
      expect(second.metadata, rosetta);
    });
  });

  group('CachedExhibitRepository graceful failures', () {
    test('missing exhibit: source returns null → notFound (never throws)', () async {
      final source = _FakeExhibitDataSource(); // nothing seeded
      final repo = CachedExhibitRepository(source: source);

      final result = await repo.getExhibit(ExhibitId('ghost'));

      expect(result.isFound, isFalse);
      expect(result.status, ExhibitLookupStatus.notFound);
      expect(result.metadata, isNull);
      expect(source.fetchCount, 1);
    });

    test('a notFound result is NOT cached (a later fetch retries the source)', () async {
      final source = _FakeExhibitDataSource();
      final repo = CachedExhibitRepository(source: source);
      final ghost = ExhibitId('ghost');

      await repo.getExhibit(ghost); // miss → notFound
      source.seed(_meta('ghost', title: 'Now Exists'));
      final second = await repo.getExhibit(ghost);

      expect(source.fetchCount, 2, reason: 'notFound must not poison the cache');
      expect(second.isFound, isTrue);
      expect(second.metadata?.title, 'Now Exists');
    });

    test('source unavailable: a throwing source with no cache → sourceUnavailable', () async {
      final source = _FakeExhibitDataSource()..failing = true;
      final repo = CachedExhibitRepository(source: source);

      final result = await repo.getExhibit(rosettaId);

      expect(result.status, ExhibitLookupStatus.sourceUnavailable);
      expect(result.metadata, isNull);
    });

    test('repository fallback: an offline source still serves a cached copy', () async {
      final source = _FakeExhibitDataSource()..failing = true;
      final cache = InMemoryExhibitCache({rosettaId: rosetta});
      final repo = CachedExhibitRepository(source: source, cache: cache);

      final result = await repo.getExhibit(rosettaId);

      expect(result.isFound, isTrue);
      expect(result.fromCache, isTrue);
      expect(result.metadata, rosetta);
      expect(source.fetchCount, 0, reason: 'cache hit short-circuits before the failing source');
    });

    test('a faulty cache read degrades to a source fetch (miss treated safely)', () async {
      final source = _FakeExhibitDataSource({rosettaId: rosetta});
      final cache = _FaultyCache()..failReads = true;
      final repo = CachedExhibitRepository(source: source, cache: cache);

      final result = await repo.getExhibit(rosettaId);

      expect(result.isFound, isTrue, reason: 'a cache fault must not break the lookup');
      expect(result.metadata, rosetta);
      expect(source.fetchCount, 1);
    });

    test('a faulty cache write does not fail an otherwise successful lookup', () async {
      final source = _FakeExhibitDataSource({rosettaId: rosetta});
      final cache = _FaultyCache()..failWrites = true;
      final repo = CachedExhibitRepository(source: source, cache: cache);

      final result = await repo.getExhibit(rosettaId);

      expect(result.isFound, isTrue);
      expect(result.metadata, rosetta);
    });
  });

  group('InMemoryExhibitCache', () {
    test('write/read/contains/remove/clear behave as a last-write-wins store', () async {
      final cache = InMemoryExhibitCache();
      final id = ExhibitId('x');

      expect(await cache.read(id), isNull);
      expect(await cache.contains(id), isFalse);

      await cache.write(_meta('x', title: 'First'));
      expect(await cache.contains(id), isTrue);
      expect((await cache.read(id))?.title, 'First');

      await cache.write(_meta('x', title: 'Second'));
      expect((await cache.read(id))?.title, 'Second', reason: 'last write wins');
      expect(cache.length, 1);

      await cache.remove(id);
      expect(await cache.contains(id), isFalse);

      await cache.write(_meta('x'));
      await cache.clear();
      expect(cache.length, 0);
    });
  });

  group('ExhibitLookupResult value semantics', () {
    test('found carries metadata + fromCache; sentinels are distinct', () {
      final a = ExhibitLookupResult.found(rosetta, fromCache: true);
      final b = ExhibitLookupResult.found(rosetta, fromCache: true);
      expect(a, b);
      expect(a.hashCode, b.hashCode);

      expect(ExhibitLookupResult.notFound.isFound, isFalse);
      expect(ExhibitLookupResult.sourceUnavailable.isFound, isFalse);
      expect(ExhibitLookupResult.notFound == ExhibitLookupResult.sourceUnavailable,
          isFalse);
    });
  });
}
