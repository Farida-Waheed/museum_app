/// A stable, opaque identifier for a museum exhibit.
///
/// Wrapping the raw string in a value type (rather than passing `String`s
/// around) is deliberate: the exhibit id flows from the robot's detection layer
/// (QR / BLE / positioning) into the description engine, the cache, and
/// analytics, and a dedicated type stops it from being confused with any other
/// string along the way and gives every layer one thing to key on.
///
/// Pure, immutable value object — no plugin, AI, or Firebase imports.
class ExhibitId {
  /// The underlying identifier as detected/stored (already trimmed).
  final String value;

  const ExhibitId._(this.value);

  /// Build an id from a raw detected/stored string, normalising surrounding
  /// whitespace. The string is expected to be non-empty; use [tryParse] when the
  /// source (a scanned code, a payload field) might be missing or blank.
  factory ExhibitId(String raw) {
    final trimmed = raw.trim();
    assert(trimmed.isNotEmpty, 'ExhibitId cannot be empty');
    return ExhibitId._(trimmed);
  }

  /// Null-safe parse for untrusted input (scan results, payloads, cache keys):
  /// returns null instead of throwing when there is no usable id.
  static ExhibitId? tryParse(Object? raw) {
    final trimmed = raw?.toString().trim() ?? '';
    if (trimmed.isEmpty) return null;
    return ExhibitId._(trimmed);
  }

  @override
  bool operator ==(Object other) =>
      other is ExhibitId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
