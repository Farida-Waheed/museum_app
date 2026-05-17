import 'package:flutter/foundation.dart';

import 'package:museum_app/models/chat_message.dart';

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
