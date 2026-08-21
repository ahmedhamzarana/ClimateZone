import 'package:climatezone/controllers/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SensorHistoryChart extends StatelessWidget {
  const SensorHistoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final history = controller.history;


      final temperatureSpots = <FlSpot>[];
      final humiditySpots = <FlSpot>[];
      final gasSpots = <FlSpot>[];

      for (int i = 0; i < history.length; i++) {
        final item = history[i];

        temperatureSpots.add(
          FlSpot(
            i.toDouble(),
            (item['temperature'] as num).toDouble(),
          ),
        );

        humiditySpots.add(
          FlSpot(
            i.toDouble(),
            (item['humidity'] as num).toDouble(),
          ),
        );

        gasSpots.add(
          FlSpot(
            i.toDouble(),
            (item['gasValue'] as num).toDouble(),
          ),
        );
      }

      // Add CURRENT realtime value as the latest point.
      final currentX = history.length.toDouble();

      temperatureSpots.add(
        FlSpot(
          currentX,
          controller.temperature.value,
        ),
      );

      humiditySpots.add(
        FlSpot(
          currentX,
          controller.humidity.value,
        ),
      );

      gasSpots.add(
        FlSpot(
          currentX,
          controller.gasValue.value,
        ),
      );

      return Container(
        height: 220,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          10,
          20,
          24,
          10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF151D25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: currentX,

            gridData: const FlGridData(
              show: true,
              drawVerticalLine: false,
            ),

            titlesData: const FlTitlesData(
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
            ),

            borderData: FlBorderData(
              show: false,
            ),

            lineBarsData: [
              // =========================
              // TEMPERATURE
              // =========================

              LineChartBarData(
                spots: temperatureSpots,
                isCurved: true,
                barWidth: 3.5,
                color: const Color(0xFFFF5252),
                dotData: const FlDotData(
                  show: false,
                ),
              ),

              // =========================
              // HUMIDITY
              // =========================

              LineChartBarData(
                spots: humiditySpots,
                isCurved: true,
                barWidth: 3.5,
                color: Colors.blueAccent,
                dotData: const FlDotData(
                  show: false,
                ),
              ),

              // =========================
              // GAS
              // =========================

              LineChartBarData(
                spots: gasSpots,
                isCurved: true,
                barWidth: 3.5,
                color: const Color(0xFF00D9A5),
                dotData: const FlDotData(
                  show: false,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}