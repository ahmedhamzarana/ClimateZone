import 'package:climatezone/utils/sensor_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0B0F14,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SmartSense',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Environment Monitor',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Get.toNamed('/alerts'), // Fixed missing forward slash
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Monitor your environment in real time',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // Device Status Widget
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF151D25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D9A5).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.memory, color: Color(0xFF00D9A5)),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ESP32 Sensor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Last updated: Just now',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D9A5).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: Color(0xFF00D9A5),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Online',
                          style: TextStyle(
                            color: Color(0xFF00D9A5),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              'Live Sensors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Using your newly created external SensorCard custom utility widget
            Row(
              children: [
                const Expanded(
                  child: SensorCard(
                    icon: Icons.thermostat,
                    title: 'Temperature',
                    value: '28.5°C',
                    accentColor: Color(
                      0xFFFF5252,
                    ), // Styled unique color marker
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SensorCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Humidity',
                    value: '64%',
                    accentColor: Colors.blueAccent.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SensorCard(
              icon: Icons.air,
              title: 'Gas / Air Quality',
              value: '320 ppm',
              accentColor: Color(0xFF00D9A5),
              fullWidth: true,
            ),
            const SizedBox(height: 25),

            // Historical Trends Section
            const Text(
              'Environmental Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 20, 24, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF151D25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Temperature Line (Red)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 25),
                        FlSpot(3, 27),
                        FlSpot(6, 26.5),
                        FlSpot(9, 28.5),
                      ],
                      isCurved: true,
                      barWidth: 3.5,
                      color: const Color(0xFFFF5252),
                      dotData: const FlDotData(show: false),
                    ),
                    // Humidity Line (Blue)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 58),
                        FlSpot(3, 62),
                        FlSpot(6, 60),
                        FlSpot(9, 64),
                      ],
                      isCurved: true,
                      barWidth: 3.5,
                      color: Colors.blueAccent.shade100,
                      dotData: const FlDotData(show: false),
                    ),
                    // Gas Line (Green)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 30),
                        FlSpot(3, 35),
                        FlSpot(6, 31),
                        FlSpot(9, 32),
                      ],
                      isCurved: true,
                      barWidth: 3.5,
                      color: const Color(0xFF00D9A5),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Fully Closed & Written System Status Card Component
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF142A28), Color(0xFF101A20)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF00D9A5)),
                  SizedBox(height: 12),
                  Text(
                    'System Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All environmental systems are stable. Sensors are feeding real-time metric updates safely.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
