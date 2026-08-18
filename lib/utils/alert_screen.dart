import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0B0F14,
      ), // Matches your home screen layout
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HUMIDITY DROP ALERT CARD (Critical Hazard)
            alertCard(
              icon: Icons.water_drop_outlined,
              title: 'Critical Humidity Drop',
              description:
                  'ESP32 Room Sensor detected a severe drop to 24% RH. Air is dangerously dry. Static hazard high.',
              time: 'Just now',
              statusLabel: 'CRITICALLY DRY',
              colorTheme: Colors.redAccent,
            ),

            const SizedBox(height: 16),

            // 2. BAD WEATHER ALERT CARD (Warning Alert)
            alertCard(
              icon: Icons.thunderstorm_outlined,
              title: 'Bad Weather Warning',
              description:
                  'Sudden barometric pressure shift detected. External atmospheric updates indicate approaching heavy rain or storms.',
              time: '12 mins ago',
              statusLabel: 'STORM WARNING',
              colorTheme: const Color(0xFFFFB300), // Warning Amber/Orange
            ),

            const SizedBox(height: 16),

            // 3. SYSTEM RESOLVED CARD (Info Status)
            alertCard(
              icon: Icons.check_circle_outline,
              title: 'Air Quality Restored',
              description:
                  'Gas/Smoke metrics normalized below 350 ppm. Room ventilation status stable.',
              time: '1 hour ago',
              statusLabel: 'RESOLVED',
              colorTheme: const Color(
                0xFF00D9A5,
              ), // Your main green color accent
            ),
          ],
        ),
      ),
    );
  }

  // UI Component Blueprint Helper for the Custom Alert Cards
  Widget alertCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required String statusLabel,
    required Color colorTheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D25), // Matches your home container color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorTheme.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon, Title, and Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorTheme.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorTheme, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Status Pill Tag Layout
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorTheme.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: colorTheme,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom Message Block
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF9EAFBC), // Clear readable layout font gray
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
