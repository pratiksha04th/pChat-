import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';

class MapUtils {

  /// Get LocationService globally
  static LocationService get location => Get.find<LocationService>();

  /// Current latitude
  static double get lat => location.latitude.value;

  /// Current longitude
  static double get lng => location.longitude.value;

  /// Get Address from current location
  static Future<String> getAddressFromLatLng() async {
    return await getAddress(lat, lng);
  }

  /// Convert lat/lng → readable address
  static Future<String> getAddress(double lat, double lng) async {
    try {
      /// Prevent invalid calls
      if (lat == 0 && lng == 0) {
        return "Location unavailable";
      }

      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final city = place.locality ?? "";
        final country = place.country ?? "";

        return "$city, $country";
      }
    } catch (e) {
      print("MapUtils Error: $e");
    }

    return "Unknown location";
  }
}