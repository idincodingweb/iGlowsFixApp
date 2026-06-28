class ChatMessage {
  final String text;
  final bool fromUser;
  final DateTime time;

  ChatMessage({required this.text, required this.fromUser, DateTime? time})
      : time = time ?? DateTime.now();
}
