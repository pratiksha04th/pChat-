import 'package:get/get.dart';
import 'package:pchat/Core/bindings/inital_binding.dart';
import 'package:pchat/Core/view/main_screen.dart';
import 'package:pchat/Feature/Auth/view/VerifyEmailScreen/verify_email_screen.dart';
import 'package:pchat/Feature/Profile/view/profile_screen.dart';
import 'package:pchat/Feature/ShowFriends/view/friend_request.dart';
import 'package:pchat/Feature/splash/view/splash_screen.dart';

import '../../Feature/Auth/middleware/auth_middleware.dart';

import '../../Feature/Auth/view/CreateProfileScreen/create_profile_screen.dart';
import '../../Feature/Auth/view/SignIn/SignIn.dart';
import '../../Feature/Auth/view/SignUp/SignUp.dart';
import '../../Feature/Chat_Screen/view/chat_screen.dart';
import '../../Feature/ShowFriends/Group/create_group_screen.dart';
import '../../Feature/Home/view/home_screen.dart';
import '../../Feature/Auth/view/ForgotPasswordScreen/forgot_password_screen.dart';

import '../../Feature/ShowFriends/view/Chat_friends.dart';
import '../../Feature/ShowFriends/view/all_friends.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.signin;

  static final pages = [
    /// SPLASH
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreen(),
      binding: InitialBinding(),
    ),

    /// SIGN IN
    GetPage(
      name: AppRoutes.signin,
      page: () => SignInScreen(),
      binding: InitialBinding(),
    ),

    /// SIGN UP
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignUpScreen(),
      binding: InitialBinding(),
    ),

    /// VERIFY EMAIL
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyEmailScreen(),
      binding: InitialBinding(),
    ),

    /// CREATE PROFILE
    GetPage(
      name: AppRoutes.createProfile,
      page: () => CreateProfileScreen(username: Get.arguments ?? ""),
      binding: InitialBinding(),
      middlewares: [AuthMiddleware()],
    ),

    /// FORGOT PASSWORD
    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => ForgotPasswordScreen(),
      binding: InitialBinding(),
    ),

    /// MAIN SCREEN
    GetPage(
      name: AppRoutes.mainScreen,
      page: () => MainScreen(),
      binding: InitialBinding(),
      middlewares: [AuthMiddleware()],
    ),

    /// HOME
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      binding: InitialBinding(),
      middlewares: [AuthMiddleware()],
    ),

    /// FRIENDS SCREEN
    GetPage(
      name: AppRoutes.chatFriends,
      page: () => ChatFriends(),
      binding: InitialBinding(),
      middlewares: [AuthMiddleware()],
    ),

    /// FRIEND REQUEST
    GetPage(
      name: AppRoutes.friendRequest,
      page: () => FriendRequest(),
      binding: InitialBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.allFriends,
      page: () => AllFriends(),
      binding: InitialBinding(),
      middlewares: [AuthMiddleware()],
    ),

    /// CHAT SCREEN
    GetPage(
      name: AppRoutes.chat,
      page: () => ChatScreen(
        chatId: Get.parameters['chatId']!,
        username: Get.parameters['username']!,
        otherUserId: Get.parameters['otherUserId'] ?? "",
      ),
      binding: InitialBinding(),
      middlewares: [AuthMiddleware()],
    ),

    /// CREATE GROUP
    GetPage(
      name: AppRoutes.createGroup,
      page: () => CreateGroupScreen(
        selectedUserIds: Get.arguments ?? [],
      ),
      binding: InitialBinding(),
      middlewares: [AuthMiddleware()],
    ),

    /// PROFILE SCREEN
    GetPage(
      name: AppRoutes.profileScreen,
      page: () => ProfileScreen(),
      binding: InitialBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
