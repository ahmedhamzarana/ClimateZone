import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final GetStorage _storage = GetStorage();

  @override
  void onReady() {
    super.onReady();
    checkUser();
  }

  Future<void> checkUser() async {
    await Future.delayed(const Duration(seconds: 2));

    final String? email = _storage.read('email');

    print('==========================');
    print('SPLASH STORAGE EMAIL: $email');
    print('==========================');

    if (email != null && email.isNotEmpty) {
      print('USER FOUND → HOME');
      Get.offAllNamed('/home');
    } else {
      print('USER NOT FOUND → LOGIN');
      Get.offAllNamed('/login');
    }
  }
}
