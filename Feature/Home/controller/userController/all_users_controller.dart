import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../Core/SharedPreferences/session_manager.dart';
import '../../../../Core/crashlytics/crashlytics_service.dart';
import '../../model/app_user.dart';

class AllUsersController extends GetxController {
  // ------------- create NODE in firebase realtime db named as USERS --------------
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref("users");
  // ------------- list of all the users in the database --------------
  final RxList<AppUser> users = <AppUser>[].obs;

  // -------------- For searchBar functionality ---------------
  final RxList<AppUser> filteredUsers = <AppUser>[].obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = true.obs;

  final RxBool groupSelectionMode = false.obs;
  final RxSet<String> selectedGroupUsers = <String>{}.obs;



  // -------- users in the AppUsers with there respective uid -------
  final Map<String, AppUser> _usersMap = {};

  // Listeners to change firebase realtime db
  StreamSubscription<DatabaseEvent>? _addSub;
  StreamSubscription<DatabaseEvent>? _changeSub;
  StreamSubscription<DatabaseEvent>? _removeSub;

  @override
  void onInit() {
    super.onInit();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        print("User not logged in -> stop listeners");

        _addSub?.cancel();
        _changeSub?.cancel();
        _removeSub?.cancel();

        users.clear();
        filteredUsers.clear();
        _usersMap.clear();

        return;
      }

      saveFcmToken();

      _usersMap.clear();
      users.clear();

      _usersRef.keepSynced(true);

      _loadInitialData();
      _attachRealtimeListeners();
      loadCurrentUser();
    });

    ever(searchQuery, (_) => _applySearch());
  }

  Future<void> _loadInitialData() async {
    final snapshot = await _usersRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.value;

    if (data is Map) {
      data.forEach((uid, value) {
        if (value is Map) {
          _usersMap[uid] = AppUser.fromMap(uid, Map<String, dynamic>.from(value));
        }
      });
    }

    final list = _usersMap.values.toList();
    users.assignAll(list);
    filteredUsers.assignAll(list);

    isLoading.value = false;
  }

  void _attachRealtimeListeners() {
    _addSub = _usersRef.onChildAdded.listen(_upsertUser);
    _changeSub = _usersRef.onChildChanged.listen(_upsertUser);
    _removeSub = _usersRef.onChildRemoved.listen(_removeUser);
  }


  void _upsertUser(DatabaseEvent event) {
    final uid = event.snapshot.key;
    final data = event.snapshot.value;

    if (uid == null || data == null || data is! Map) return;

    _usersMap[uid] = AppUser.fromMap(uid, Map<String, dynamic>.from(data));

    users.assignAll(_usersMap.values.toList());
    _applySearch();

    if (isLoading.value) {
      isLoading.value = false;
    }
  }
// remove the user from the database
  void _removeUser(DatabaseEvent event) {
    final uid = event.snapshot.key;
    if (uid == null) return;
    _usersMap.remove(uid);
    users.assignAll(_usersMap.values.toList());
    _applySearch();
  }
// -------  get the current user from firebase auth -------
  final RxString currentUserId = ''.obs;
  final RxString currentUserEmail = ''.obs;
  final RxString currentUserUsername = ''.obs;

  Future<void> loadCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
      FirebaseCrashlytics.instance.setCustomKey(
          "email", user.email ?? "no email");
      FirebaseCrashlytics.instance.setCustomKey("screen", "AllUsersController");

      await saveCrashlyticsUserId();
      currentUserId.value = user.uid;
      currentUserEmail.value = user.email ?? '';

      final snap = await FirebaseDatabase.instance
          .ref("users/${user.uid}")
          .get();

      if (snap.exists && snap.value is Map) {
        final data = snap.value as Map;

        currentUserUsername.value = data['username'] ?? '';
      }
      // Save token to DB
      final token = await FirebaseMessaging.instance.getToken();
      if (user != null && token != null) {
        await FirebaseDatabase.instance
            .ref('users/${user.uid}/fcmToken')
            .set(token);
      }
      await SessionManager.saveUserSession(
        userId: user.uid,
        email: user.email ?? '',
        username: currentUserUsername.value,
      );

      print("USER LOADED:");
      print("ID: ${currentUserId.value}");
      print("NAME: ${currentUserUsername.value}");
      print("FCM Token: $token");
    }
    catch (e, stack) {
      CrashlyticsService.recordError(e, stack, reason: "loadCurrentUser failed",
      );
    }
  }

  void startGroupSelection() {
    groupSelectionMode.value = true;
    selectedGroupUsers.clear();
  }

  void toggleGroupUser(String uid) {
    if (selectedGroupUsers.contains(uid)) {
      selectedGroupUsers.remove(uid);
    } else {
      selectedGroupUsers.add(uid);
    }
  }

  void clearGroupSelection() {
    groupSelectionMode.value = false;
    selectedGroupUsers.clear();
  }
//------------ Apply Search -------------
  void _applySearch(){
    final query = searchQuery.value.toLowerCase();
    if(query.isEmpty){
    filteredUsers.assignAll(users);
  } else {
      filteredUsers.assignAll(
          users.where((user) {
            return user.username.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query);
          }).toList(),
      );
    }
  }
  void onSearchChanged(String value){
    searchQuery.value = value;
  }

  // savefcmToken
  Future<void> saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await FirebaseDatabase.instance
        .ref("users/${user.uid}/fcmToken")
        .set(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      FirebaseDatabase.instance
          .ref("users/${user.uid}/fcmToken")
          .set(newToken);
    });
  }
  // save crashlyticsUserId same as uid
  Future<void> saveCrashlyticsUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DatabaseReference db =
    FirebaseDatabase.instance.ref();

    await db.child("users/${user.uid}").update({
      "crashlyticsUserId": user.uid,
      "lastUpdated": ServerValue.timestamp,
    });
  }

  @override
  void onClose() {
    _addSub?.cancel();
    _changeSub?.cancel();
    _removeSub?.cancel();
    super.onClose();
  }
}
