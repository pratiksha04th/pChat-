import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  final RxBool isOnline = true.obs;
  final RxString connectionType = "unknown".obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  /// Handle all connection types
  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      isOnline.value = false;
      connectionType.value = "No Internet";
      return;
    }

    isOnline.value = true;

    if (results.contains(ConnectivityResult.wifi)) {
      connectionType.value = "WiFi";
    } else if (results.contains(ConnectivityResult.mobile)) {
      connectionType.value = "Mobile Data";
    } else if (results.contains(ConnectivityResult.ethernet)) {
      connectionType.value = "Ethernet";
    } else if (results.contains(ConnectivityResult.vpn)) {
      connectionType.value = "VPN";
    } else {
      connectionType.value = "Other";
    }

    /// Debug
    print("Connection: ${connectionType.value}");
  }
}