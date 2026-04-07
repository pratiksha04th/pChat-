class PostLike {
  final String uid;
  final String username;

  PostLike({
    required this.uid,
    required this.username,
  });

  factory PostLike.fromMap(Map data) {
    return PostLike(
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "username": username,
    };
  }
}