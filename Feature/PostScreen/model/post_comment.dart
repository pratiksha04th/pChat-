class PostComment {
  final String commentId;
  final String uid;
  final String username;
  final String text;
  final int createdAt;

  PostComment({
    required this.commentId,
    required this.uid,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  factory PostComment.fromMap(String id, Map data) {
    return PostComment(
      commentId: id,
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      text: data['text'] ?? '',
      createdAt: data['createdAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "commentId": commentId,
      "uid": uid,
      "username": username,
      "text": text,
      "createdAt": createdAt,
    };
  }
}