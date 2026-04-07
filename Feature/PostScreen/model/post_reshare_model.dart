import 'package:pchat/Feature/PostScreen/model/reshare_model.dart';

import 'post_comment.dart';
import 'post_like.dart';

class ResharePostModel {
  final String reshareId;

  /// user who reshared
  final String userId;
  final String username;

  /// connection to original post
  final String originalPostId;
  final String originalUserId;
  final String originalUsername;

  /// content snapshot
  final String text;

  final int createdAt;

  /// different like, comment from original post
  final List<PostLike> likes;
  final List<PostComment> comments;

  /// track further reshares
  final List<ReshareModel> reshares;

  ResharePostModel({
    required this.reshareId,
    required this.userId,
    required this.username,
    required this.originalPostId,
    required this.originalUserId,
    required this.originalUsername,
    required this.text,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.reshares,
  });

  factory ResharePostModel.fromMap(
      String id, Map<dynamic, dynamic> data) {

    final likesMap = data['likes'] is Map
        ? Map<dynamic, dynamic>.from(data['likes'])
        : {};

    final commentsMap = data['comments'] is Map
        ? Map<dynamic, dynamic>.from(data['comments'])
        : {};

    final reshareMap = data['reshares'] is Map
        ? Map<dynamic, dynamic>.from(data['reshares'])
        : {};

    return ResharePostModel(
      reshareId: id,
      userId: data['userId']?.toString() ?? '',
      username: data['username']?.toString() ?? '',

      originalPostId: data['originalPostId']?.toString() ?? '',
      originalUserId: data['originalUserId']?.toString() ?? '',
      originalUsername: data['originalUsername']?.toString() ?? '',

      text: data['text']?.toString() ?? '',
      createdAt: _parseInt(data['createdAt']),

      likes: likesMap.values
          .where((e) => e is Map)
          .map((e) => PostLike.fromMap(
          Map<String, dynamic>.from(e)))
          .toList(),

      comments: commentsMap.entries
          .where((e) => e.value is Map)
          .map((e) => PostComment.fromMap(
        e.key.toString(),
        Map<String, dynamic>.from(e.value),
      ))
          .toList(),

    reshares: reshareMap.values
        .where((e) => e.value is Map)
        .map((e) => ReshareModel.fromMap(
    Map<String, dynamic>.from(e.value)))
        .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "reshareId": reshareId,
      "userId": userId,
      "username": username,

      "originalPostId": originalPostId,
      "originalUserId": originalUserId,
      "originalUsername": originalUsername,

      "text": text,
      "createdAt": createdAt,

      "likes": {
        for (var like in likes) like.uid: like.toMap()
      },

      "comments": {
        for (var c in comments) c.commentId: c.toMap()
      },

      "reshares": {
        for (var r in reshares) "${r.uid}_${r.createdAt}": r.toMap()
      },
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}