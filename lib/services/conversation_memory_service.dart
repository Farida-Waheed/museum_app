class ConversationMemoryItem {
  final String role; // 'user' or 'assistant'
  final String content;
  ConversationMemoryItem({required this.role, required this.content});
}

class ConversationMemoryService {
  final int maxEntries;
  final List<ConversationMemoryItem> _history = [];

  ConversationMemoryService({this.maxEntries = 20});

  List<ConversationMemoryItem> get history => List.unmodifiable(_history);

  void addUserMessage(String text) {
    _push(ConversationMemoryItem(role: 'user', content: text));
  }

  void addAssistantMessage(String text) {
    _push(ConversationMemoryItem(role: 'assistant', content: text));
  }

  void clear() {
    _history.clear();
  }

  void _push(ConversationMemoryItem item) {
    _history.add(item);
    while (_history.length > maxEntries) {
      _history.removeAt(0);
    }
  }

  String get conversationSummary {
    return _history
        .map((m) => '${m.role == 'user' ? 'You' : 'Guide'}: ${m.content}')
        .join('\n');
  }
}
