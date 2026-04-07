import 'package:get/get.dart';
import 'package:pchat/Core/controller/pchat_controller.dart';
import 'package:pchat/Feature/Chat_Screen/controller/chat_controller.dart';
import 'package:pchat/Feature/ShowFriends/controller/friend_request_controller.dart';
import '../../Feature/Auth/controller/auth_controlller.dart';
import '../../Feature/Home/controller/userController/all_users_controller.dart';
import '../../Feature/PostScreen/controller/post_controller.dart';
import '../../Feature/location/services/location_service.dart';
import '../../Feature/splash/controller/appController.dart';
import '../services/connectivity_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    /// Auth Controller (created only when first used)
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true, //  If the controller is removed from memory,
      // GetX will automatically recreate it when Get.find() is called again.
    );

    /// Users Controller
    Get.put<AllUsersController>(AllUsersController(), permanent: true);

    /// friend request controller
    Get.put(FriendRequestController(), permanent: true);

    /// CHAT controller
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);

    /// pChat controller
    Get.put(PChatController(), permanent: true);

    Get.put(AppController(), permanent: true);

    Get.put(ConnectivityService(), permanent: true);

    Get.put(PostController(), permanent: true);

    /// location
    Get.put<LocationService>(
      LocationService()..init(),
      permanent: true,
    );
  }
}
