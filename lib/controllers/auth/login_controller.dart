import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  // Password visibility
  final isVisible = false.obs;

  void toggleVisibility() {
    isVisible.value = !isVisible.value;
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  final RxString emailError = "".obs;
  final RxString passwordError = "".obs;

  final isLoading = false.obs;

  bool validateForm() {
    emailError.value = "";
    passwordError.value = "";

    bool isValid = true;

    final emailText = emailController.text.trim();
    final passwordText = passwordController.text;

    if (emailText.isEmpty) {
      emailError.value = "Email address is required";
      isValid = false;
    } else if (!GetUtils.isEmail(emailText)) {
      emailError.value = "Enter a valid email address";
      isValid = false;
    }

    if (passwordText.isEmpty) {
      passwordError.value = "Password is required";
      isValid = false;
    }

    return isValid;
  }

  Future<void> login() async {
    if (!validateForm()) {
      return;
    }

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      await _storage.write('email', user?.email ?? '');

      emailController.clear();
      passwordController.clear();

      isLoading.value = false;

      Get.offAllNamed('/home');
      Get.snackbar(
        "Login Successful",
        "Welcome back!",
        backgroundColor: const Color(0xFF00D9A5),
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
          message = 'Incorrect password.';
          break;

        case 'invalid-email':
          message = 'Invalid email address.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;

        default:
          message = e.message ?? 'Login failed.';
      }

      Get.snackbar(
        "Login Failed",
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      isLoading.value = false;

      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
