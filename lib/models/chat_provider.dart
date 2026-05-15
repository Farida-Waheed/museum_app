import 'package:flutter/foundation.dart';

import 'package:museum_app/models/chat_message.dart';

/// Keeps a simple in-memory Ask Horus history for tour fallback questions.
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

  void updateLastMessage(ChatMessageModel message) {
    if (_messages.isEmpty) return;
    if (_messages.last.id != message.id) return;
    _messages[_messages.length - 1] = message;
    notifyListeners();
  }

  void ensureGreeting({required bool isArabic}) {
    if (_messages.isNotEmpty) return;

    final greeting = isArabic
        ? 'مرحبًا! استخدم هذه المساحة عندما لا يستطيع حورس سماعك بوضوح أثناء الجولة.'
        : 'Use this when Horus cannot hear you clearly during your tour.';

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
