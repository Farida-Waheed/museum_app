/// A simple message model used by Ask Horus tour fallback.
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
  final bool isHumanSupport;

  ChatMessageModel.text({
    required this.id,
    required this.isUser,
    required this.timestamp,
    required this.text,
  }) : kind = MessageKind.text,
       cardTitle = null,
       cardItems = null,
       isHumanSupport = false;

  ChatMessageModel.card({
    required this.id,
    required this.isUser,
    required this.timestamp,
    required this.cardTitle,
    required this.cardItems,
  }) : kind = MessageKind.infoCard,
       text = '',
       isHumanSupport = false;

  ChatMessageModel.humanSupport({
    required this.id,
    required this.timestamp,
    required this.text,
  }) : isUser = false,
       kind = MessageKind.text,
       cardTitle = null,
       cardItems = null,
       isHumanSupport = true;
}
