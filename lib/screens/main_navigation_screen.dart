import 'package:climatezone/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainNavigationScreen extends StatelessWidget {
  MainNavigationScreen({super.key});

  final MainController controller = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ============================================================
      // BODY
      // ============================================================

      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: controller.screens,
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================

bottomNavigationBar: Obx(
  () => NavigationBar(
    height: 75,

    selectedIndex: controller.currentIndex.value,

    onDestinationSelected: (index) {
      controller.changeTab(index);
    },

    backgroundColor: const Color(0xFF111820),

    indicatorColor: const Color(0xFF00D9A5).withOpacity(0.15),

    labelBehavior:
        NavigationDestinationLabelBehavior.alwaysShow,

    // ============================================================
    // LABEL STYLE
    // ============================================================

    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: Color(0xFF00D9A5),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          );
        }

        return const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        );
      },
    ),

    destinations: const [
      NavigationDestination(
        icon: Icon(
          Icons.dashboard_outlined,
          color: Colors.grey,
        ),
        selectedIcon: Icon(
          Icons.dashboard,
          color: Color(0xFF00D9A5),
        ),
        label: 'Home',
      ),

      NavigationDestination(
        icon: Icon(
          Icons.message_outlined,
          color: Colors.grey,
        ),
        selectedIcon: Icon(
          Icons.message,
          color: Color(0xFF00D9A5),
        ),
        label: 'AI',
      ),

      NavigationDestination(
        icon: Icon(
          Icons.person_outline,
          color: Colors.grey,
        ),
        selectedIcon: Icon(
          Icons.person,
          color: Color(0xFF00D9A5),
        ),
        label: 'Profile',
      ),
    ],
  ),
),

    );
  }
}
