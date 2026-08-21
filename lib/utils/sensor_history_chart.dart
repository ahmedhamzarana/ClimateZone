import 'dart:math' as math;

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

      // ============================================================
      // HISTORY DATA
      // ============================================================

      for (int i = 0; i < history.length; i++) {
        final item = history[i];

        final temperature =
            (item['temperature'] as num?)?.toDouble() ?? 0.0;

        final humidity =
            (item['humidity'] as num?)?.toDouble() ?? 0.0;

        final gas =
            (item['gasValue'] as num?)?.toDouble() ?? 0.0;

        temperatureSpots.add(
          FlSpot(i.toDouble(), temperature),
        );

        humiditySpots.add(
          FlSpot(i.toDouble(), humidity),
        );

        gasSpots.add(
          FlSpot(i.toDouble(), gas),
        );
      }

      // ============================================================
      // CURRENT REALTIME VALUE
      // ============================================================

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

      // ============================================================
      // FIND MAXIMUM VALUE
      // ============================================================

      final allValues = <double>[
        ...temperatureSpots.map((e) => e.y),
        ...humiditySpots.map((e) => e.y),
        ...gasSpots.map((e) => e.y),
      ];

      double highestValue = 100;

      if (allValues.isNotEmpty) {
        highestValue = allValues.reduce(
          (a, b) => math.max(a, b),
        );
      }

      // ============================================================
      // RESPONSIVE CHART
      // ============================================================

      return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          // --------------------------------------------------------
          // RESPONSIVE VALUES
          // --------------------------------------------------------

          final bool isSmallMobile = screenWidth < 360;
          final bool isMobile = screenWidth < 600;

          final double chartHeight = isSmallMobile
              ? 220
              : isMobile
                  ? 235
                  : 280;

          final double leftReservedSize = isSmallMobile
              ? 32
              : isMobile
                  ? 38
                  : 45;

          final double bottomReservedSize = isSmallMobile
              ? 25
              : 30;

          final double labelFontSize = isSmallMobile
              ? 8
              : isMobile
                  ? 9
                  : 10;

          final double lineWidth = isSmallMobile
              ? 2.5
              : 3;

          // --------------------------------------------------------
          // Y AXIS
          // --------------------------------------------------------

          double maxY =
              ((highestValue / 10).ceil() * 10).toDouble();

          maxY += 10;

          if (maxY < 110) {
            maxY = 110;
          }

          const double minY = 0;

          // --------------------------------------------------------
          // BOTTOM LABEL INTERVAL
          // --------------------------------------------------------

          int labelInterval = 1;

          if (history.length > 12) {
            labelInterval = 2;
          }

          if (history.length > 24) {
            labelInterval = 4;
          }

          if (history.length > 48) {
            labelInterval = 8;
          }

          if (history.length > 100) {
            labelInterval = 10;
          }

          // --------------------------------------------------------
          // CONTAINER
          // --------------------------------------------------------

          return Container(
            width: double.infinity,
            height: chartHeight,
            padding: EdgeInsets.only(
              left: isSmallMobile ? 4 : 6,
              right: isSmallMobile ? 10 : 16,
              top: 16,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF151D25),
              borderRadius: BorderRadius.circular(
                isSmallMobile ? 16 : 20,
              ),
            ),
            child: LineChart(
              LineChartData(
                // ==================================================
                // X AXIS
                // ==================================================

                minX: 0,

                maxX: currentX <= 0
                    ? 1
                    : currentX,

                // ==================================================
                // Y AXIS
                // ==================================================

                minY: minY,
                maxY: maxY,

                // ==================================================
                // GRID
                // ==================================================

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,

                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.06),
                      strokeWidth: 1,
                    );
                  },
                ),

                // ==================================================
                // TITLES
                // ==================================================

                titlesData: FlTitlesData(
                  // ------------------------------------------------
                  // TOP
                  // ------------------------------------------------

                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  // ------------------------------------------------
                  // RIGHT
                  // ------------------------------------------------

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  // ------------------------------------------------
                  // LEFT
                  // ------------------------------------------------

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      reservedSize: leftReservedSize,

                      interval: 10,

                      getTitlesWidget: (
                        value,
                        meta,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 3,
                          ),
                          child: Text(
                            value.toInt().toString(),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ------------------------------------------------
                  // BOTTOM
                  // ------------------------------------------------

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      reservedSize: bottomReservedSize,

                      interval: labelInterval.toDouble(),

                      getTitlesWidget: (
                        value,
                        meta,
                      ) {
                        final index = value.toInt();

                        if (index < 0 ||
                            index > history.length) {
                          return const SizedBox.shrink();
                        }

                        // Only show selected intervals.
                        if (index % labelInterval != 0 &&
                            index != history.length) {
                          return const SizedBox.shrink();
                        }

                        return SideTitleWidget(
                          meta: meta,
                          space: 6,
                          child: Text(
                            '${index + 1}',
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ==================================================
                // BORDER
                // ==================================================

                borderData: FlBorderData(
                  show: false,
                ),

                // ==================================================
                // TOUCH
                // ==================================================

                lineTouchData: LineTouchData(
                  enabled: true,

                  touchTooltipData:
                      LineTouchTooltipData(
                    getTooltipItems:
                        (touchedSpots) {
                      return touchedSpots.map(
                        (spot) {
                          String label;

                          if (spot.barIndex == 0) {
                            label = 'Temperature';
                          } else if (spot.barIndex == 1) {
                            label = 'Humidity';
                          } else {
                            label = 'Gas';
                          }

                          return LineTooltipItem(
                            '$label\n'
                            '${spot.y.toStringAsFixed(1)}',
                            TextStyle(
                              color: Colors.white,
                              fontSize:
                                  isSmallMobile
                                      ? 9
                                      : 11,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          );
                        },
                      ).toList();
                    },
                  ),
                ),

                // ==================================================
                // LINE BARS
                // ==================================================

                lineBarsData: [
                  // =================================================
                  // TEMPERATURE
                  // =================================================

                  LineChartBarData(
                    spots: temperatureSpots,

                    isCurved: true,

                    curveSmoothness: 0.25,

                    barWidth: lineWidth,

                    color: const Color(
                      0xFFFF5252,
                    ),

                    dotData: const FlDotData(
                      show: false,
                    ),

                    belowBarData:
                        BarAreaData(
                      show: true,

                      gradient:
                          LinearGradient(
                        begin:
                            Alignment.topCenter,
                        end:
                            Alignment.bottomCenter,
                        colors: [
                          const Color(
                            0xFFFF5252,
                          ).withOpacity(0.15),
                          const Color(
                            0xFFFF5252,
                          ).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),

                  // =================================================
                  // HUMIDITY
                  // =================================================

                  LineChartBarData(
                    spots: humiditySpots,

                    isCurved: true,

                    curveSmoothness: 0.25,

                    barWidth: lineWidth,

                    color: Colors.blueAccent,

                    dotData: const FlDotData(
                      show: false,
                    ),

                    belowBarData:
                        BarAreaData(
                      show: true,

                      gradient:
                          LinearGradient(
                        begin:
                            Alignment.topCenter,
                        end:
                            Alignment.bottomCenter,
                        colors: [
                          Colors.blueAccent
                              .withOpacity(0.12),
                          Colors.blueAccent
                              .withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),

                  // =================================================
                  // GAS
                  // =================================================

                  LineChartBarData(
                    spots: gasSpots,

                    isCurved: true,

                    curveSmoothness: 0.25,

                    barWidth: lineWidth,

                    color: const Color(
                      0xFF00D9A5,
                    ),

                    dotData: const FlDotData(
                      show: false,
                    ),

                    belowBarData:
                        BarAreaData(
                      show: true,

                      gradient:
                          LinearGradient(
                        begin:
                            Alignment.topCenter,
                        end:
                            Alignment.bottomCenter,
                        colors: [
                          const Color(
                            0xFF00D9A5,
                          ).withOpacity(0.10),
                          const Color(
                            0xFF00D9A5,
                          ).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}