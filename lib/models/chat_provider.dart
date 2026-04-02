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
        ? "مرحباً! أنا دليلك في المتحف، كيف يمكنني مساعدتك؟"
        : "Welcome! I am your museum guide. How can I help you today?";

    final suggestionTitle = isArabic ? 'اقتراحات سريعة' : 'Quick suggestions';
    final suggestionItems = isArabic
        ? ['أسأل عن التذاكر', 'ساعات العمل', 'الفعاليات', 'أخبرني عن هذا المعروض']
        : ['Ask about tickets', 'Opening hours', 'Current events', 'Tell me about this exhibit'];

    addMessage(ChatMessageModel.text(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      isUser: false,
      timestamp: DateTime.now(),
      text: greeting,
    ));

    addMessage(ChatMessageModel.card(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      isUser: false,
      timestamp: DateTime.now(),
      cardTitle: suggestionTitle,
      cardItems: suggestionItems,
    ));
  }
}
