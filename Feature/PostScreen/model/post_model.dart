import 'post_comment.dart';
import 'post_like.dart';

class PostModel {
  final String postId;
  final String userId;
  final String username;

  /// main content
  final String text;

  /// KEY FIELD (null = normal post, not null = reshare)
  final String? originalPostId;

  /// optional snapshot (for faster UI)
  final String? originalText;
  final String? originalUsername;

  final int createdAt;

  final List<PostLike> likes;
  final List<PostComment> comments;

  PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
    required this.likes,
    required this.comments,

    this.originalPostId,
    this.originalText,
    this.originalUsername,
  });

  /// ------------------ FROM MAP ------------------
  factory PostModel.fromMap(String id, Map<dynamic, dynamic> data) {
    final likesMap = data['likes'] is Map
        ? Map<dynamic, dynamic>.from(data['likes'])
        : {};

    final commentsMap = data['comments'] is Map
        ? Map<dynamic, dynamic>.from(data['comments'])
        : {};

    return PostModel(
      postId: id,
      userId: data['userId']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      createdAt: _parseInt(data['createdAt']),

      /// reshare fields
      originalPostId: data['originalPostId']?.toString(),
      originalText: data['originalText']?.toString(),
      originalUsername: data['originalUsername']?.toString(),

      /// likes
      likes: likesMap.values
          .where((e) => e is Map)
          .map((e) => PostLike.fromMap(
        Map<String, dynamic>.from(e),
      ))
          .toList(),

      /// comments
      comments: commentsMap.entries
          .where((e) => e.value is Map)
          .map((e) => PostComment.fromMap(
        e.key.toString(),
        Map<String, dynamic>.from(e.value),
      ))
          .toList(),
    );
  }

  /// ------------------ TO MAP ------------------
  Map<String, dynamic> toMap() {
    return {
      "postId": postId,
      "userId": userId,
      "username": username,
      "text": text,
      "createdAt": createdAt,

      /// reshare fields
      "originalPostId": originalPostId,
      "originalText": originalText,
      "originalUsername": originalUsername,

      "likes": {
        for (var like in likes) like.uid: like.toMap(),
      },

      "comments": {
        for (var c in comments) c.commentId: c.toMap(),
      },
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// ------------------ HELPERS ------------------

  /// check if reshare
  bool get isReshare => originalPostId != null;
}