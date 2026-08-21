import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    await GetStorage().remove('email');
    await GetStorage().remove('username');

    Get.offAllNamed('/login');
  }
}
