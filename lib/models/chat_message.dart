enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  Map<String, dynamic> toMap() => {
    'role': role == MessageRole.user ? 'user' : 'assistant',
    'content': content,
  };
}
