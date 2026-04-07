import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends GetxService {

  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  /// INIT SERVICE
  Future<void> init() async {
    await _determinePosition();
  }

  /// GET CURRENT LOCATION (ONE TIME)
  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("GPS is OFF");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        print("Permission permanently denied");
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      print("Initial Location --> ${latitude.value}, ${longitude.value}");

      /// Save initial location
      _updateFirebase();

    } catch (e) {
      print(" Error getting location: $e");
    }
  }

  /// STREAM LOCATION (REAL-TIME)
  void startLiveTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update only if user moves 10 meters
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) {

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      print("Live Location -> ${latitude.value}, ${longitude.value}");

      _updateFirebase();
    });
  }

  /// UPDATE FIREBASE
  void _updateFirebase() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseDatabase.instance
        .ref("users/${user.uid}")
        .update({
      "lat": latitude.value,
      "lng": longitude.value,
      "lastLocationUpdate": ServerValue.timestamp,
    });
  }
}