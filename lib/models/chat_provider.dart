import 'package:flutter/foundation.dart';

import 'package:museum_app/models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessageModel> _messages = [];

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get hasMessages => _messages.isNotEmpty;
  ChatMessageModel? get lastMessage => hasMessages ? _messages.last : null;

  /// Voice seam (Phase 3): invoked whenever a speakable assistant message is
  /// added, so AI answers are automatically voice-enabled through the Voice
  /// Communication Engine. Kept as a plain callback so this model never imports
  /// the voice module — `main.dart` binds it to the AI voice adapter, and the
  /// engine itself decides (from the accessibility profile / mute state) whether
  /// to actually speak. Null when no engine is wired (tests, headless).
  void Function(ChatMessageModel message)? onAssistantMessage;

  void clear() {
    _messages.clear();
    notifyListeners();
  }

  void addMessage(ChatMessageModel message) {
    _messages.add(message);
    notifyListeners();
    _maybeSpeak(message);
  }

  /// Route a newly-added assistant text message to the voice engine. Only real
  /// spoken content passes: user messages, non-text cards, and empty
  /// placeholders are ignored so nothing meaningless is announced.
  void _maybeSpeak(ChatMessageModel message) {
    final hook = onAssistantMessage;
    if (hook == null) return;
    if (message.isUser) return;
    if (message.kind != MessageKind.text) return;
    if (message.text.trim().isEmpty) return;
    hook(message);
  }

  void updateLastMessage(ChatMessageModel message) {
    if (_messages.isEmpty) return;
    if (_messages.last.id != message.id) return;
    _messages[_messages.length - 1] = message;
    notifyListeners();
  }

  void ensureGreeting(String greeting) {
    if (_messages.isNotEmpty) return;
    addMessage(
      ChatMessageModel.text(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: false,
        timestamp: DateTime.now(),
        text: greeting,
      ),
    );
  }
}
