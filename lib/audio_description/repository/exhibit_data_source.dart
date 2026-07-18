import '../models/exhibit_id.dart';
import '../models/exhibit_metadata.dart';

/// The authoritative backend for exhibit data (SOLID / DIP), the audio-
/// description analogue of `AccessibilityRepository`. The cache-first
/// [CachedExhibitRepository] depends on this interface, never on Firebase
/// directly, so:
/// * the engine and UI stay backend-agnostic,
/// * a Firebase implementation can be added in a later task without touching
///   any caller,
/// * tests inject a fake source with scripted results.
///
/// Contract: implementations resolve [fetch] to the metadata for [id], or
/// `null` when the exhibit genuinely does not exist. They throw ONLY on a real
/// backend failure (offline / transport error) so the repository can tell
/// "missing" apart from "unreachable" and degrade accordingly.
abstract class ExhibitDataSource {
  Future<ExhibitMetadata?> fetch(ExhibitId id);
}
