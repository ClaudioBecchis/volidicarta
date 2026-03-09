class ForumReply {
  final String id;
  final String threadId;
  final String userId;
  final String username;
  final String body;
  final String createdAt;
  final int likesCount;
  final bool isLikedByMe;

  const ForumReply({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.username,
    required this.body,
    required this.createdAt,
    required this.likesCount,
    required this.isLikedByMe,
  });

  factory ForumReply.fromMap(Map<String, dynamic> m, String myUserId) {
    final likes = (m['forum_reply_likes'] as List?) ?? [];
    return ForumReply(
      id: m['id'] as String,
      threadId: m['thread_id'] as String,
      userId: m['user_id'] as String,
      username: m['username'] as String? ?? 'Utente',
      body: m['body'] as String,
      createdAt: m['created_at'] as String? ?? '',
      likesCount: m['likes_count'] as int? ?? 0,
      isLikedByMe: likes.any((l) => l['user_id'] == myUserId),
    );
  }

  ForumReply copyWith({int? likesCount, bool? isLikedByMe}) => ForumReply(
        id: id,
        threadId: threadId,
        userId: userId,
        username: username,
        body: body,
        createdAt: createdAt,
        likesCount: likesCount ?? this.likesCount,
        isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      );
}
