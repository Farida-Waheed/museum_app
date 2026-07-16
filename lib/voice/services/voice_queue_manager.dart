import '../constants/voice_constants.dart';
import '../enums/voice_enums.dart';
import '../models/voice_message.dart';

/// The outcome of offering a message to the queue, so the coordinator knows
/// whether it must interrupt the current utterance.
enum VoiceEnqueueResult {
  /// Queued behind existing items; will be spoken in turn.
  queued,

  /// Higher priority than what is speaking — the coordinator should stop the
  /// current utterance and speak this next.
  interrupt,

  /// Dropped as a duplicate within the dedup window.
  duplicate,

  /// Dropped because the queue is full and this item is not urgent enough.
  dropped,
}

/// A priority-ordered, de-duplicated speech queue — the mechanism that
/// guarantees voice messages never overlap and that urgent messages win.
///
/// Pure data structure: no timers, no plugins, no async. The coordinator owns
/// timing and playback; the queue owns *ordering policy*. Keeping them separate
/// is what makes the ordering rules exhaustively unit-testable.
///
/// Ordering rules:
/// * Higher [VoicePriority] is always dequeued first.
/// * Within a priority, FIFO by creation (stable, fair).
/// * A [VoicePriority.critical] arrival clears all lower-priority pending items
///   (a fire alarm is not followed by the exhibit blurb it interrupted).
/// * Duplicates within [VoiceConstants.duplicateWindow] are rejected.
/// * Above [VoiceConstants.maxQueueLength] the least-urgent, oldest pending item
///   is evicted so memory is bounded and the visitor is not buried.
class VoiceQueueManager {
  VoiceQueueManager({
    int maxLength = VoiceConstants.maxQueueLength,
    Duration duplicateWindow = VoiceConstants.duplicateWindow,
  })  : _maxLength = maxLength,
        _duplicateWindow = duplicateWindow;

  final int _maxLength;
  final Duration _duplicateWindow;

  final List<VoiceMessage> _items = <VoiceMessage>[];

  /// The message most recently handed out by [takeNext] (i.e. now "speaking"),
  /// tracked so [wouldInterrupt] and dedup can consider it.
  VoiceMessage? _current;

  // --- Introspection (for the controller/UI and tests) ---
  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  VoiceMessage? get current => _current;
  List<VoiceMessage> get pending => List.unmodifiable(_items);

  /// Offer a message. Returns how it was handled. Does NOT speak — the
  /// coordinator reacts to the result.
  VoiceEnqueueResult enqueue(VoiceMessage message) {
    // 1. Duplicate suppression (against current + pending).
    if (_isDuplicate(message)) return VoiceEnqueueResult.duplicate;

    // 2. Critical clears everything of lower priority already waiting.
    if (message.priority.clearsLowerPriority) {
      _items.removeWhere((m) => m.priority.index < message.priority.index);
    }

    // 3. Insert in priority order (stable: after equal-priority items).
    _insertOrdered(message);

    // 4. Enforce the cap by evicting the least-urgent, oldest pending item.
    _enforceCap(protect: message);

    // 5. Tell the coordinator whether to interrupt what is currently speaking.
    if (_current != null &&
        message.priority.interruptsCurrent &&
        message.priority.isMoreUrgentThan(_current!.priority) &&
        _current!.interruptible) {
      return VoiceEnqueueResult.interrupt;
    }
    return VoiceEnqueueResult.queued;
  }

  /// Whether offering [message] would interrupt the current utterance, without
  /// mutating the queue (used by the coordinator to decide before enqueue).
  bool wouldInterrupt(VoiceMessage message) =>
      _current != null &&
      message.priority.interruptsCurrent &&
      message.priority.isMoreUrgentThan(_current!.priority) &&
      _current!.interruptible &&
      !_isDuplicate(message);

  /// Remove and return the next message to speak, marking it current.
  VoiceMessage? takeNext() {
    if (_items.isEmpty) {
      return null;
    }
    _current = _items.removeAt(0);
    return _current;
  }

  /// Mark the current message finished (spoken or stopped).
  void completeCurrent() => _current = null;

  /// Drop everything pending (e.g. on mute or emergency-clear). Does not affect
  /// the already-dequeued current message; the coordinator stops that directly.
  void clear() => _items.clear();

  /// Drop pending items at or below [priority] (used when a higher stream takes
  /// over, e.g. entering a conversation clears ambient chatter).
  void clearAtOrBelow(VoicePriority priority) =>
      _items.removeWhere((m) => m.priority.index <= priority.index);

  bool _isDuplicate(VoiceMessage message) {
    if (_current != null && message.duplicates(_current!, _duplicateWindow)) {
      return true;
    }
    return _items.any((m) => message.duplicates(m, _duplicateWindow));
  }

  void _insertOrdered(VoiceMessage message) {
    // Find the first item strictly LOWER priority than the new one and insert
    // before it; equal-priority items keep FIFO order.
    var index = _items.length;
    for (var i = 0; i < _items.length; i++) {
      if (message.priority.isMoreUrgentThan(_items[i].priority)) {
        index = i;
        break;
      }
    }
    _items.insert(index, message);
  }

  void _enforceCap({required VoiceMessage protect}) {
    while (_items.length > _maxLength) {
      // Evict the least-urgent item; among equals, the oldest (front-most of
      // that priority band, i.e. the last in list order). Never evict [protect].
      VoiceMessage? victim;
      for (final m in _items) {
        if (identical(m, protect)) continue;
        if (victim == null || m.priority.index <= victim.priority.index) {
          victim = m;
        }
      }
      if (victim == null) break;
      _items.remove(victim);
    }
  }
}
