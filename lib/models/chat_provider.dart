import 'package:flutter/foundation.dart';

import 'package:museum_app/models/chat_message.dart';

/// Keeps a simple in-memory chat history for the Horus chatbot.
///
/// This allows the chat screen to be reopened without re-adding the
/// initial greeting message over and over, and provides a single
/// source-of-truth for the last message for popups.
class ChatProvider extends ChangeNotifier {
  final List<ChatMessageModel> _messages = [];

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get hasMessages => _messages.isNotEmpty;
  ChatMessageModel? get lastMessage => hasMessages ? _messages.last : null;

  void clear() {
    _messages.clear();
    notifyListeners();
  }

  void addMessage(ChatMessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  /// Updates the last message if the IDs match (for typewriter-style updates).
  void updateLastMessage(ChatMessageModel message) {
    if (_messages.isEmpty) return;
    if (_messages.last.id != message.id) return;
    _messages[_messages.length - 1] = message;
    notifyListeners();
  }

  /// Ensures the initial greeting is present.
  ///
  /// This is idempotent: calling it multiple times will not add duplicates.
  void ensureGreeting({required bool isArabic}) {
    if (_messages.isNotEmpty) return;

    final greeting = isArabic
        ? "مرحباً! أنا حوروس، كيف يمكنني مساعدتك؟"
        : "Welcome! I’m Horus, how can I help you today?";

    addMessage(ChatMessageModel.text(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      isUser: false,
      timestamp: DateTime.now(),
      text: greeting,
    ));
  }
}
