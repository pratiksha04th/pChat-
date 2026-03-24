import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../../../Core/Model/app_user.dart';
import '../../Home/controller/userController/all_users_controller.dart';
import '../model/friend_request_model.dart';

class FriendRequestController extends GetxController {

  final AllUsersController usersController = Get.find();

  final RxList<AppUser> friends = <AppUser>[].obs;
  final RxList<AppUser> filteredFriends = <AppUser>[].obs;

  final RxString searchQuery = ''.obs;
  final RxBool isRefreshing = false.obs;

  final DatabaseReference _requestRef =
  FirebaseDatabase.instance.ref("friendRequests");

  /// uid -> request
  final RxMap<String, FriendRequestModel> requests =
      <String, FriendRequestModel>{}.obs;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  StreamSubscription<DatabaseEvent>? _requestSub;

  @override
  void onInit() {
    super.onInit();

    isRefreshing.value = true;

    listenRequests();

    Future.delayed( const Duration(seconds: 2), () {
      isRefreshing.value = false;
    });

    /// listen user list updates
    ever(usersController.users, (List<AppUser> users) {
      updateFriends(users);
    });

    /// search debounce
    debounce(searchQuery, (_) => applySearch(),
        time: const Duration(milliseconds: 300));
  }

  /// LISTEN FRIEND REQUESTS
  void listenRequests() {

    final uid = currentUser?.uid;
    if (uid == null) return;

    _requestSub = _requestRef.onValue.listen((event) {

      final data = event.snapshot.value;

      if (data == null) {
        requests.clear();
        updateFriends(usersController.users);
        return;
      }

      final map = Map<String, dynamic>.from(data as Map);

      requests.clear();

      map.forEach((key, value) {

        if (value is! Map) return;

        final req = FriendRequestModel.fromMap(
          key,
          Map<String, dynamic>.from(value),
        );

        if (req.fromUid == uid) {
          requests[req.toUid] = req;
        }
        else if (req.toUid == uid) {
          requests[req.fromUid] = req;
        }
        requests.refresh();

      });

      /// update friends after request change
      updateFriends(usersController.users);
    });
  }

  /// SEND FRIEND REQUEST
  Future<void> sendRequest(String toUid) async {

    final uid = currentUser?.uid;
    if (uid == null) return;

    if (uid == toUid) return;

    if (requests.containsKey(toUid)) {
      Get.snackbar("Request Exists", "Request already sent");
      return;
    }

    final newRef = _requestRef.push();

    final request = FriendRequestModel(
      requestId: newRef.key!,
      fromUid: uid,
      toUid: toUid,
      status: "pending",
    );

    await newRef.set({
      "requestId": request.requestId,
      "fromUid": request.fromUid,
      "toUid": request.toUid,
      "status": request.status,
      "createdAt": ServerValue.timestamp,
    });

    Get.snackbar(
      "Request Sent",
      "Friend request sent successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  /// ACCEPT FRIEND REQUEST
  Future<void> acceptRequest(String requestId) async {

    await _requestRef.child(requestId).update({
      "status": "accepted",
    });

    Get.snackbar(
      "Friend Added",
      "You are now friends",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  /// REJECT FRIEND REQUEST
  Future<void> rejectRequest(String requestId) async {
    try {
      await _requestRef.child(requestId).remove();

      Get.snackbar(
        "Request Removed",
        "Friend request rejected",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to reject request",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  /// UPDATE FRIEND LIST
  void updateFriends(List<AppUser> allUsers) {

    final friendIds = requests.entries
        .where((e) => e.value.status == "accepted")
        .map((e) => e.key)
        .toSet();

    final list =
    allUsers.where((user) => friendIds.contains(user.uid)).toList();

    friends.assignAll(list);

    applySearch();
  }

  /// SEARCH
  void applySearch() {

    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredFriends.assignAll(friends);
      return;
    }

    filteredFriends.assignAll(
      friends.where((user) {

        final username = user.username.toLowerCase();
        final first = user.firstName.toLowerCase();
        final last = user.lastName.toLowerCase();

        return username.contains(query) ||
            first.contains(query) ||
            last.contains(query);

      }).toList(),
    );
  }

  /// SEARCH INPUT
  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  @override
  void onClose() {
    _requestSub?.cancel();
    super.onClose();
  }

  /// refresh listner
  Future<void> refreshFriends() async {
    isRefreshing.value = true;
    _requestSub?.cancel();

    requests.clear();
    friends.clear();
    filteredFriends.clear();

    await Future.delayed(const Duration(milliseconds: 300));

    listenRequests();
    isRefreshing.value = false;

  }
}