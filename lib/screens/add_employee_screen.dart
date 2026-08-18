import 'dart:io';

import 'package:climatezone/controllers/emp_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEmployeeScreen extends GetView<EmpController> {
  const AddEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add New Employee',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EmployeeProfileImage(),

              const SizedBox(height: 35),

              const InputLabel(text: 'Employee Name'),
              const SizedBox(height: 8),

              Obx(
                () => EmployeeTextField(
                  controller: controller.nameController,
                  hint: 'Enter full name',
                  icon: Icons.person_outline,
                  errorText: controller.nameError.value.isEmpty
                      ? null
                      : controller.nameError.value,
                ),
              ),

              const SizedBox(height: 20),

              const InputLabel(text: 'Email Address'),
              const SizedBox(height: 8),

              Obx(
                () => EmployeeTextField(
                  controller: controller.emailController,
                  hint: 'name@company.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorText: controller.emailError.value.isEmpty
                      ? null
                      : controller.emailError.value,
                ),
              ),

              const SizedBox(height: 20),

              const InputLabel(text: 'Phone Number'),
              const SizedBox(height: 8),

              Obx(
                () => EmployeeTextField(
                  controller: controller.phoneController,
                  hint: '+92 300 0000000',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  errorText: controller.phoneError.value.isEmpty
                      ? null
                      : controller.phoneError.value,
                ),
              ),

              const SizedBox(height: 20),

              const InputLabel(text: 'Department / Role'),
              const SizedBox(height: 8),

              Obx(
                () => EmployeeTextField(
                  controller: controller.roleController,
                  hint: 'e.g. System Administrator',
                  icon: Icons.badge_outlined,
                  errorText: controller.roleError.value.isEmpty
                      ? null
                      : controller.roleError.value,
                ),
              ),

              const SizedBox(height: 40),

              const SaveEmployeeButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE IMAGE
// ============================================================

class EmployeeProfileImage extends GetView<EmpController> {
  const EmployeeProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasImage = controller.image.value != null;
      final hasError = controller.imageError.value.isNotEmpty;

      return Column(
        children: [
          Center(
            child: GestureDetector(
              onTap: controller.pickImageFromGallery,
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151D25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasError
                            ? Colors.redAccent
                            : const Color(0xFF00D9A5).withOpacity(0.3),
                        width: 2,
                      ),
                      image: hasImage
                          ? DecorationImage(
                              image: FileImage(
                                File(controller.image.value!.path),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: hasImage
                        ? null
                        : Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: hasError
                                ? Colors.redAccent.withOpacity(0.6)
                                : Colors.grey,
                          ),
                  ),

                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: hasError
                            ? Colors.redAccent
                            : const Color(0xFF00D9A5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (hasError) ...[
            const SizedBox(height: 8),
            Text(
              controller.imageError.value,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      );
    });
  }
}

// ============================================================
// INPUT LABEL
// ============================================================

class InputLabel extends StatelessWidget {
  final String text;

  const InputLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

// ============================================================
// TEXT FIELD
// ============================================================

class EmployeeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? errorText;
  final TextInputType keyboardType;

  const EmployeeTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.errorText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF151D25),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF00D9A5), size: 22),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00D9A5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

// ============================================================
// SAVE BUTTON
// ============================================================

class SaveEmployeeButton extends GetView<EmpController> {
  const SaveEmployeeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          if (controller.validateForm()) {
            Get.snackbar(
              'Success',
              'Employee profile processed locally.',
              backgroundColor: const Color(0xFF00D9A5),
              colorText: Colors.black,
              snackPosition: SnackPosition.TOP,
            );
          } else {
            Get.snackbar(
              'Validation Failed',
              'Please check the highlighted entry errors.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9A5),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Save Employee Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
