class ForumThread {
  final String id;
  final String userId;
  final String username;
  final String title;
  final String? body;
  final String category;
  final String createdAt;
  final int repliesCount;
  final int likesCount;
  final bool isLikedByMe;

  const ForumThread({
    required this.id,
    required this.userId,
    required this.username,
    required this.title,
    this.body,
    required this.category,
    required this.createdAt,
    required this.repliesCount,
    required this.likesCount,
    required this.isLikedByMe,
  });

  factory ForumThread.fromMap(Map<String, dynamic> m, String myUserId) {
    final likes = (m['forum_thread_likes'] as List?) ?? [];
    return ForumThread(
      id: m['id'] as String,
      userId: m['user_id'] as String,
      username: m['username'] as String? ?? 'Utente',
      title: m['title'] as String,
      body: m['body'] as String?,
      category: m['category'] as String? ?? 'Generale',
      createdAt: m['created_at'] as String? ?? '',
      repliesCount: m['replies_count'] as int? ?? 0,
      likesCount: m['likes_count'] as int? ?? 0,
      isLikedByMe: likes.any((l) => l['user_id'] == myUserId),
    );
  }

  ForumThread copyWith({int? likesCount, bool? isLikedByMe, int? repliesCount}) => ForumThread(
        id: id,
        userId: userId,
        username: username,
        title: title,
        body: body,
        category: category,
        createdAt: createdAt,
        repliesCount: repliesCount ?? this.repliesCount,
        likesCount: likesCount ?? this.likesCount,
        isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      );
}
