import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Home/controller/userController/all_users_controller.dart';
import '../../ShowFriends/controller/friend_request_controller.dart';

class PostController extends GetxController {
  final db = FirebaseDatabase.instance.ref();
  final FriendRequestController friendController = Get.find();
  final userCtrl = Get.find<AllUsersController>();
  final RxBool isPosting = false.obs;
  final RxInt refreshTrigger = 0.obs;
  final RxBool isRefreshing = false.obs;
  final RxList<Map<String, dynamic>> myFeed = <Map<String, dynamic>>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> commentsMap =
      <String, List<Map<String, dynamic>>>{}.obs;
  final RxMap<String, bool> loadingMap = <String, bool>{}.obs;
  final RxMap<String, List<Map<String, dynamic>>> likesMap =
      <String, List<Map<String, dynamic>>>{}.obs;
  final RxMap<String, List<Map<String, dynamic>>> reshareUsersMap =
      <String, List<Map<String, dynamic>>>{}.obs;
  final RxList<Map<String, dynamic>> friendsFeed =
      <Map<String, dynamic>>[].obs;

  final RxMap<String, int> reshareCountMap = <String, int>{}.obs;

  /// prevent duplicate listeners
  final Set<String> _listeningLikes = {};
  final Set<String> _listeningReshares = {};

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();

    db.child("posts").onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null || data is! Map) {
        myFeed.clear();
        return;
      }

      final postsData = Map<String, dynamic>.from(data);
      final List<Map<String, dynamic>> feed = [];

      postsData.forEach((postId, value) {
        if (value is Map) {
          final post = Map<String, dynamic>.from(value);

          if (post['userId'] != uid) return;

          post['type'] = post['originalPostId'] == null ? 'post' : 'reshare';

          feed.add(post);

          // fetch counts
          final postId = post['postId'];

          listenLikes(postId);
          listenReshares(postId);
        }
      });

      feed.sort((a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0));

      myFeed.assignAll(feed);
    });
  }

  /// CREATE POST
  Future<void> createPost(String text) async {
    try {
      if (text.trim().isEmpty) return;

      isPosting.value = true;

      final ref = db.child("posts").push();

      final postId = ref.key;

      final postData = {
        "postId": postId,
        "userId": uid,
        "username": userCtrl.currentUserUsername.value,
        "text": text.trim(),
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "originalPostId": null,
        "likes": {},
        "comments": {},
      };

      /// SAVE MASTER DATA
      await ref.set(postData);
    } finally {
      isPosting.value = false;
    }
  }

  /// LIKE / UNLIKE
  Future<void> toggleLike(String postId) async {
    final likeRef = db.child("posts/$postId/likes/$uid");

    final snap = await likeRef.get();

    if (snap.exists) {
      await likeRef.remove();
    } else {
      await likeRef.set({
        "uid": uid,
        "username": userCtrl.currentUserUsername.value,
      });
    }
  }

  /// ADD COMMENT
  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final ref = db.child("posts/$postId/comments").push();

    await ref.set({
      "commentId": ref.key,
      "uid": uid,
      "username": userCtrl.currentUserUsername.value,
      "text": text.trim(),
      "createdAt": DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// RESHARE
  Future<void> toggleReshare(Map originalPost) async {
    final originalPostId = originalPost['postId'];

    if (originalPostId == null) return;

    // local check
    final alreadyReshared = myFeed.any((post) {
      return post['userId'] == uid && post['originalPostId'] == originalPostId;
    });
    // remove reshare if already reshared
    if (alreadyReshared) {
      final existing = myFeed.firstWhere(
        (post) =>
            post['userId'] == uid && post['originalPostId'] == originalPostId,
      );

      await db.child("posts/${existing['postId']}").remove();
      return;
    }

    /// create new reshare post
    final newRef = db.child("posts").push();

    await newRef.set({
      "postId": newRef.key,
      "userId": uid,
      "username": userCtrl.currentUserUsername.value,

      "text": originalPost['text'],

      /// LINK TO ORIGINAL
      "originalPostId": originalPostId,

      // fetch data locally
      "originalData": {
        "postId": originalPost['postId'],
        "userId": originalPost['userId'],
        "username": originalPost['username'],
        "text": originalPost['text'],
        "createdAt": originalPost['createdAt'],
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,

      "likes": {},
      "comments": {},
    });
  }

  /// get friends post (used in home screen)
  Stream<List<Map<String, dynamic>>> getFriendsPosts() {
    return db.child("posts").onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null || data is! Map) return [];

      final postsData = Map<String, dynamic>.from(data);

      final friendIds = friendController.friends.map((e) => e.uid).toSet();

      friendIds.add(uid);

      final List<Map<String, dynamic>> feed = [];


      postsData.forEach((key, value) {
        if (value is Map) {
          final post = Map<String, dynamic>.from(value);

          if (!friendIds.contains(post['userId'])) return;

          /// detect type
          post['type'] = post['originalPostId'] == null ? 'post' : 'reshare';

          feed.add(post);

          final postId = post['postId'];
          listenLikes(postId);
          listenReshares(postId);
        }
      });

      feed.sort((a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0));

      return feed;
    });
  }

  //Refresh posts
  Future<void> refreshPosts() async {
    if (isRefreshing.value) return;

    try {
      isRefreshing.value = true;

      await Future.delayed(const Duration(milliseconds: 500));

      refreshTrigger.value++;
    } finally {
      isRefreshing.value = false;
    }
  }

  /// like post stream
  void listenLikes(String postId) {
    if (_listeningLikes.contains(postId)) return;
    _listeningLikes.add(postId);

    db.child("posts/$postId/likes").onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null || data is! Map) {
        likesMap[postId] = [];
        likesMap.refresh();
        return;
      }

      final map = Map<String, dynamic>.from(data);

      likesMap[postId] = map.values
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      likesMap.refresh();
    });
  }

  /// comment stream
  Future<void> fetchComments(String postId) async {
    loadingMap[postId] = true;

    try {
      final snap = await db.child("posts/$postId/comments").get();

      if (!snap.exists || snap.value is! Map) {
        commentsMap[postId] = [];
        return;
      }

      final data = Map<String, dynamic>.from(snap.value as Map);

      final list = data.values
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      list.sort((a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0));

      commentsMap[postId] = list;
    } finally {
      loadingMap[postId] = false;
    }
  }

  /// reshare tracking
  void listenReshares(String postId) {
    if (_listeningReshares.contains(postId)) return;
    _listeningReshares.add(postId);

    db.child("posts").onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null || data is! Map) {
        reshareCountMap[postId] = 0;
        reshareUsersMap[postId] = [];
        reshareCountMap.refresh();
        reshareUsersMap.refresh();
        return;
      }

      final posts = Map<String, dynamic>.from(data);
      final List<Map<String,dynamic>> users = [];

      for (var e in posts.values) {
        if (e is Map && e['originalPostId'] == postId) {
          users.add({
            "uid": e['userId'],
            "username": e['username'],
          });
        }
      }

      reshareUsersMap[postId] = users;
      reshareCountMap[postId] = users.length;
      reshareCountMap.refresh();
      reshareCountMap.refresh();
    });
  }

  /// delete comment
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await db.child("posts/$postId/comments/$commentId").remove();
  }

  /// edit commment
  Future<void> editComment({
    required String postId,
    required String commentId,
    required String newText,
  }) async {
    await db.child("posts/$postId/comments/$commentId").update({
      "text": newText,
      "editedAt": DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// delete post
  Future<void> deletePost(String postId) async {
    await db.child("posts/$postId").remove();

    myFeed.removeWhere((e) => e['postId'] == postId);
  }

  ///edit post
  Future<void> editPost({
    required String postId,
    required String newText,
  }) async {
    await db.child("posts/$postId").update({
      "text": newText,
      "editedAt": DateTime.now().millisecondsSinceEpoch,
    });

    final index = myFeed.indexWhere((e) => e['postId'] == postId);

    if (index != -1) {
      myFeed[index]['text'] = newText;
      myFeed.refresh();
    }
  }

  /// check who reshare post
  bool hasUserReshared(String postId) {
    return myFeed.any(
      (post) => post['originalPostId'] == postId && post['userId'] == uid,
    );
  }
}
