class ChatMessage {
  final String role;
  String message;
  final bool isSending;

  ChatMessage({
    required this.role,
    required this.message,
    this. isSending = false,
  });
}