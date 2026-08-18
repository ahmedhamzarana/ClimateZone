import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EmpController extends GetxController {
  // 1. Text Field Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  final RxString nameError = "".obs;
  final RxString emailError = "".obs;
  final RxString phoneError = "".obs;
  final RxString roleError = "".obs;
  final RxString imageError = "".obs;

  // 3. Validation Logic Method
  bool validateForm() {
    // Reset previous errors
    imageError.value = ""; // Reset image error
    nameError.value = "";
    emailError.value = "";
    phoneError.value = "";
    roleError.value = "";

    bool isValid = true;
    if (image.value == null) {
      imageError.value = "Profile image is required";
      isValid = false;
    }
    // Validate Name
    if (nameController.text.trim().isEmpty) {
      nameError.value = "Employee name is required";
      isValid = false;
    }

    // Validate Email using simple Regex
    final emailText = emailController.text.trim();
    if (emailText.isEmpty) {
      emailError.value = "Email address is required";
      isValid = false;
    } else if (!GetUtils.isEmail(emailText)) {
      emailError.value = "Enter a valid email address";
      isValid = false;
    }

    // Validate Phone Number
    final phoneText = phoneController.text.trim();
    if (phoneText.isEmpty) {
      phoneError.value = "Phone number is required";
      isValid = false;
    } else if (!GetUtils.isPhoneNumber(phoneText)) {
      phoneError.value = "Enter a valid phone number";
      isValid = false;
    }

    // Validate Role/Department
    if (roleController.text.trim().isEmpty) {
      roleError.value = "Department or role is required";
      isValid = false;
    }

    return isValid;
  }

  // 4. Image Picker Implementation
  final ImagePicker _picker = ImagePicker();
  final Rxn<XFile> image = Rxn<XFile>();

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        image.value = pickedFile;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    roleController.dispose();
    super.onClose();
  }
}
