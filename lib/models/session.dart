class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  int messageCount;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastUsedAt,
    this.messageCount = 0,
  });
}
