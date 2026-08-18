import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Logout confirmation dialog helper
    void showLogoutDialog() {
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF151D25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Center(
            // 1. Wrapped with Center widget
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of SmartSense?',
            textAlign: TextAlign.center, // 2. Added center text alignment line
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          actionsAlignment: MainAxisAlignment
              .center, // 3. Aligns the Action Buttons to the center line
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed('/login');
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFF0B0F14,
      ), // Dark background matching theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Admin Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 1. Admin Avatar & Profile Details Header
            Center(
              child: Column(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151D25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00D9A5),
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 45,
                      color: Color(0xFF00D9A5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ahmed Khan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'System Administrator',
                    style: TextStyle(
                      color: Color(0xFF00D9A5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // 2. Settings Menu Option Blocks
            profileMenuOption(
              icon: Icons.shield_outlined,
              title: 'Security & Node Access',
              subtitle: 'Manage ESP32 encryption keys',
            ),
            const SizedBox(height: 14),
            profileMenuOption(
              icon: Icons.notifications_none_outlined,
              title: 'Alert Thresholds',
              subtitle: 'Set critical temperature/gas levels',
            ),
            const SizedBox(height: 14),
            profileMenuOption(
              icon: Icons.sync,
              title: 'Hardware Integration',
              subtitle: 'Configure MQTT & Wi-Fi broker setup',
            ),

            const SizedBox(height: 40),

            // 3. Functional Logout Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: showLogoutDialog,
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Logout from Session',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF2C1414,
                  ), // Muted dark red button canvas
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  side: BorderSide(
                    color: Colors.redAccent.withOpacity(0.2),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for custom individual setting option tiles
  Widget profileMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D25), // Container background tile
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0F14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00D9A5), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
    );
  }
}
