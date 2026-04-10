enum SupportSender { user, human, assistant }

class SupportMessage {
  final String id;
  final SupportSender sender;
  final String text;
  final DateTime timestamp;

  SupportMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  String get senderLabel {
    switch (sender) {
      case SupportSender.user:
        return 'User';
      case SupportSender.human:
        return 'Human Support';
      case SupportSender.assistant:
        return 'Assistant';
    }
  }
}
