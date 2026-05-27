class ChatMessage {
  final String id;
  final String fromId;
  final String text;
  final DateTime time;

  ChatMessage({
    required this.id,
    required this.fromId,
    required this.text,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}
