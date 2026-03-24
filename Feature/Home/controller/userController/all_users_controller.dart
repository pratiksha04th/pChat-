import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pchat/Core/controller/base_controller.dart';

import '../../../../Core/SharedPreferences/session_manager.dart';
import '../../../../Core/crashlytics/crashlytics_service.dart';
import '../../../../Core/Model/app_user.dart';

class AllUsersController extends BaseController {

  /// FIREBASE REFERENCES
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref("users");

  /// STATE
  final RxList<AppUser> users = <AppUser>[].obs;
  final RxList<AppUser> filteredUsers = <AppUser>[].obs;

  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;

  /// GROUP SELECTION
  final RxBool groupSelectionMode = false.obs;
  final RxSet<String> selectedGroupUsers = <String>{}.obs;

  /// CURRENT USER
  final RxString currentUserId = ''.obs;
  final RxString currentUserEmail = ''.obs;
  final RxString currentUserUsername = ''.obs;

  /// LOCAL CACHE
  final Map<String, AppUser> _usersMap = {};

  /// STREAMS
  StreamSubscription<DatabaseEvent>? _addSub;
  StreamSubscription<DatabaseEvent>? _changeSub;
  StreamSubscription<DatabaseEvent>? _removeSub;
  StreamSubscription<String>? _tokenSub;

  @override
  void onInit() {
    super.onInit();

    FirebaseAuth.instance.authStateChanges().listen(_handleAuthState);

    debounce(
      searchQuery,
          (_) => _applySearch(),
      time: const Duration(milliseconds: 300),
    );
  }

  /// AUTH STATE HANDLER
  void _handleAuthState(User? user) {

    _cancelListeners();

    if (user == null) {
      _clearData();
      return;
    }

    currentUserId.value = user.uid;

    saveFcmToken();

    _usersRef.keepSynced(true);

    _attachRealtimeListeners();

    loadCurrentUser();
  }

  /// REALTIME DATABASE LISTENERS
  void _attachRealtimeListeners() {

    _addSub = _usersRef.onChildAdded.listen(_upsertUser);

    _changeSub = _usersRef.onChildChanged.listen(_upsertUser);

    _removeSub = _usersRef.onChildRemoved.listen((event) {

      final uid = event.snapshot.key;

      if (uid == null) return;

      _usersMap.remove(uid);

      _refreshUsers();
    });
  }

  /// UPSERT USER (ADD OR UPDATE)
  void _upsertUser(DatabaseEvent event) {

    final uid = event.snapshot.key;
    final data = event.snapshot.value;

    if (uid == null || data == null || data is! Map) return;

    /// DON'T SHOW CURRENT USER
    if (uid == currentUserId.value) return;

    final user = AppUser.fromMap(
      uid,
      Map<String, dynamic>.from(data),
    );

    _usersMap[uid] = user;

    _refreshUsers();
  }
/// REFRESH USERS LIST
  Future<void> refreshUsers() async {
    isLoading.value = true;

    _cancelListeners();
    _usersMap.clear();
    users.clear();
    filteredUsers.clear();

    await Future.delayed(const Duration(milliseconds: 300));

    _attachRealtimeListeners(); // reattach listeners

    isLoading.value = false;
  }
  /// REFRESH USERS LIST
  void _refreshUsers() {

    final list = _usersMap.values.toList();

    users.assignAll(list);

    _applySearch();

    if (isLoading.value) {
      isLoading.value = false;
    }
  }

  /// LOAD CURRENT USER
  Future<void> loadCurrentUser() async {

    await runSafe(() async {

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await setUserContext(user.uid, email: user.email);

      currentUserEmail.value = user.email ?? '';

      final snap = await _usersRef.child(user.uid).get();

      if (snap.exists && snap.value is Map) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        final currentUser = AppUser.fromMap(user.uid, data);

        currentUserUsername.value = currentUser.username;
      }

      await SessionManager.saveUserSession(
        userId: user.uid,
        email: user.email ?? '',
        username: currentUserUsername.value,
      );

      log("User Loaded: ${currentUserUsername.value}");

    }, errorReason: "loadCurrentUser failed");
  }

  /// SEARCH LOGIC
  void _applySearch() {

    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {

      filteredUsers.assignAll(users);

      return;
    }

    filteredUsers.assignAll(

      users.where((user) {

        final username = user.username.toLowerCase();
        final email = user.email.toLowerCase();
        final first = user.firstName.toLowerCase();
        final last = user.lastName.toLowerCase();

        return username.contains(query) ||
            email.contains(query) ||
            first.contains(query) ||
            last.contains(query);
      }),

    );
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  /// GROUP SELECTION
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

  /// SAVE FCM TOKEN
  Future<void> saveFcmToken() async {
    await runSafe(() async {

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await _usersRef.child("${user.uid}/fcmToken").set(token);

    }, errorReason: "saveFcmToken failed");
  }

  /// SAVE CRASHLYTICS USER
  Future<void> saveCrashlyticsUserId() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await _usersRef.child(user.uid).update({

      "crashlyticsUserId": user.uid,

      "lastUpdated": ServerValue.timestamp,

    });
  }

  /// CLEANUP
  void _cancelListeners() {

    _addSub?.cancel();
    _changeSub?.cancel();
    _removeSub?.cancel();
  }

  void _clearData() {

    _usersRef.keepSynced(false);

    users.clear();
    filteredUsers.clear();
    _usersMap.clear();

    isLoading.value = false;
  }

  @override
  void onClose() {

    _cancelListeners();

    _tokenSub?.cancel();

    super.onClose();
  }
}