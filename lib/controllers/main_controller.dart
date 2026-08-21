import 'package:climatezone/screens/auth/profile_screen.dart';
import 'package:climatezone/screens/chat_bot_screen.dart';
import 'package:climatezone/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  // Reactive integer tracking the bottom navigation index
  var currentIndex = 0.obs;

  // Method to update index
  void changeTab(int index) {
    currentIndex.value = index;
  }

  final List<Widget> screens = [HomeScreen(), ChatBotScreen(), ProfileScreen()];
}
