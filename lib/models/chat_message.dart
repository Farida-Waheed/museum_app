/// A simple chat message model used by the Horus chatbot.
///
/// This is intentionally lightweight and optimized for the demo, and is used
/// across both the ChatScreen UI and the ChatProvider state.
library;

enum MessageKind { text, infoCard }

class ChatMessageModel {
  final String id;
  final bool isUser;
  final DateTime timestamp;
  final MessageKind kind;
  final String text;
  final String? cardTitle;
  final List<String>? cardItems;

  ChatMessageModel.text({
    required this.id,
    required this.isUser,
    required this.timestamp,
    required this.text,
  }) : kind = MessageKind.text,
       cardTitle = null,
       cardItems = null;

  ChatMessageModel.card({
    required this.id,
    required this.isUser,
    required this.timestamp,
    required this.cardTitle,
    required this.cardItems,
  }) : kind = MessageKind.infoCard,
       text = '';
}
