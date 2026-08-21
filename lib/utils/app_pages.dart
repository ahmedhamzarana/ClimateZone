import 'package:climatezone/bindings/login_binding.dart';
import 'package:climatezone/bindings/splash_binding.dart';
import 'package:climatezone/screens/auth/login_screen.dart';
import 'package:climatezone/screens/auth/splash_screen.dart';
import 'package:climatezone/screens/chat_bot_screen.dart';
import 'package:climatezone/screens/main_navigation_screen.dart';
import 'package:climatezone/utils/alert_screen.dart';
import 'package:climatezone/utils/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash, 
      page: () => const SplashScreen(),
      binding: SplashBinding()
    ),
    GetPage(
      name: AppRoutes.login, 
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => MainNavigationScreen()
    ),
    GetPage(name: AppRoutes.chat, page: () => ChatBotScreen(),),
    GetPage(
      name: AppRoutes.alerts, 
      page: () => AlertScreen()
    ),
  ];
}
