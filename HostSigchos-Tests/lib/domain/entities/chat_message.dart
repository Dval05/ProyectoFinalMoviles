class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.action,
    this.actionData,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? action;
  final Map<String, dynamic>? actionData;
}
