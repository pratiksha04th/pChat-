import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../../../Core/routes/app_routes.dart';

class AppController extends GetxController with WidgetsBindingObserver {

  final _db = FirebaseDatabase.instance;

  @override
  void onInit() {
    super.onInit();

    /// Listen app Lifecycle
    WidgetsBinding.instance.addObserver(this);

    /// set user online when app starts
    setUserOnline(true);

    /// set user disconnect handler
    setupDisconnect();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);

    ///Mark offline when controller removed
    setUserOnline(false);

    super.onClose();
  }

  void setupPresence() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseDatabase.instance.ref().child("users/${user.uid}");
    final connectedRef = FirebaseDatabase.instance.ref().child(".info/connected");

    connectedRef.onValue.listen((event) async {
      final isConnected = event.snapshot.value as bool? ?? false;

      if (!isConnected) return;

      /// when app disconnects (background / killed)
      await userRef.onDisconnect().update({
        "isOnline": false,
        "lastSeen": ServerValue.timestamp,
      });

      /// when connected
      await userRef.update({
        "isOnline": true,
        "lastSeen": ServerValue.timestamp,
      });
    });
  }

  ///------------------ APP START ---------------

  Future<void> handleAppStart() async {
    /// APP START
    setupPresence();
    FirebaseCrashlytics.instance.log("App started");

    final user = FirebaseAuth.instance.currentUser;

    /// NOT LOGGED IN
    if (user == null) {
      FirebaseCrashlytics.instance.log("No user found");

      Get.offAllNamed(AppRoutes.signin);
      return;
    }

    try {
      await user.reload();
      FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: "User reload failed",
      );
    }

    /// EMAIL NOT VERIFIED
    if (!user.emailVerified) {
      FirebaseCrashlytics.instance.log("User email not verified");
      Get.offAllNamed(AppRoutes.verifyEmail);
      return;
    }

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("users/${user.uid}")
          .get();

      /// PROFILE NOT COMPLETE
      if (!snapshot.exists ||
          snapshot
              .child("profileCompleted")
              .value != true) {
        FirebaseCrashlytics.instance.log("Profile not completed");

        Get.offAllNamed(AppRoutes.createProfile);
        return;
      }

      /// user ready  -> mark online
      setUserOnline(true);

      /// SUCCESS -> MAIN SCREEN
      FirebaseCrashlytics.instance.log("User entered main screen");
      Get.offAllNamed(AppRoutes.mainScreen);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: "Fetching user profile failed",
      );

      Get.offAllNamed(AppRoutes.signin);
    }
  }

  ///---------- ONLINE STATUS ----------
  void setUserOnline(bool status) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _db.ref("users/${user.uid}").update({
      "isOnline": status,
      "lastSeen": DateTime
          .now()
          .millisecondsSinceEpoch,
    });

    FirebaseCrashlytics.instance.log(
        "user ${user.uid} is ${status ? "ONLINE" : " OFFLINE"}");
  }

  /// HANDLER APP CLOSE /CRASH / INTERNET LOSS
  void setupDisconnect() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = _db.ref("users/${user.uid}");

    ref.onDisconnect().update({
      "isOnline": false,
      "lastSeen": ServerValue.timestamp,
    });
  }

  ///----------- APP LIFECYCLE -----------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        setUserOnline(true);
        break;

      case AppLifecycleState.detached:
        setUserOnline(false);
        break;

        default:
          setUserOnline(false);
    }
  }
  }