import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/alert_controller.dart';

class AlertScreen extends StatelessWidget {
  AlertScreen({super.key});

  final AlertController controller = Get.put(AlertController());

  static const Color backgroundColor = Color(0xFF0B0F14);
  static const Color cardColor = Color(0xFF151D25);
  static const Color accentColor = Color(0xFF00D9A5);
  static const Color secondaryText = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alerts',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            Text(
              'Safety events & notifications',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),

        actions: [
          Obx(
            () => controller.alerts.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      controller.clearAlerts();
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: Obx(
        () {
          if (controller.alerts.isEmpty) {
            return _emptyState();
          }

          return RefreshIndicator(
            color: accentColor,
            backgroundColor: cardColor,

            onRefresh: () async {
              await controller.loadSupabaseAlerts();
            },

            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                25,
              ),

              itemCount: controller.alerts.length,

              itemBuilder: (context, index) {
                final alert = controller.alerts[index];

                return _alertCard(
                  context,
                  alert,
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ALERT CARD
  // ============================================================

  Widget _alertCard(
    BuildContext context,
    Map<String, dynamic> alert,
  ) {
    final type =
        alert['type']?.toString() ?? 'AI ALERT';

    final status =
        alert['status']?.toString() ?? 'WARNING';

    final imageUrl =
        alert['imageUrl']?.toString() ?? '';

    final time =
        alert['time'] as DateTime?;

    return GestureDetector(
      onTap: () {
        _showAlertBottomSheet(
          context,
          alert,
        );
      },

      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
        ),

        decoration: BoxDecoration(
          color: cardColor,

          borderRadius: BorderRadius.circular(
            20,
          ),

          border: Border.all(
            color: Colors.white.withOpacity(0.04),
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ====================================================
              // IMAGE
              // ====================================================

              ClipRRect(
                borderRadius: BorderRadius.circular(
                  15,
                ),

                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,

                        width: 75,
                        height: 75,

                        fit: BoxFit.cover,

                        errorBuilder:
                            (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),

              const SizedBox(width: 14),

              // ====================================================
              // CONTENT
              // ====================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: Text(
                            alert['title']
                                    ?.toString() ??
                                'AI ALERT',

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        _statusBadge(status),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Text(
                      type,

                      style: const TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      alert['description']
                              ?.toString() ??
                          'Safety event detected.',

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          _formatDateTime(time),

                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              const Padding(
                padding: EdgeInsets.only(
                  top: 25,
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder() {
    return Container(
      width: 75,
      height: 75,

      decoration: BoxDecoration(
        color: const Color(0xFF1C252E),
        borderRadius: BorderRadius.circular(15),
      ),

      child: const Icon(
        Icons.image_outlined,
        color: Colors.grey,
        size: 30,
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    Color color;

    switch (status.toUpperCase()) {
      case 'CRITICAL':
        color = Colors.redAccent;
        break;

      case 'WARNING':
        color = Colors.orangeAccent;
        break;

      case 'NORMAL':
        color = accentColor;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.12),

        borderRadius: BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),

      child: Text(
        status.toUpperCase(),

        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 95,
              height: 95,

              decoration: BoxDecoration(
                color: accentColor.withOpacity(
                  0.10,
                ),

                shape: BoxShape.circle,

                border: Border.all(
                  color: accentColor.withOpacity(
                    0.15,
                  ),
                ),
              ),

              child: const Icon(
                Icons.notifications_none,
                size: 48,
                color: accentColor,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No Alerts',

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'No smoke, fire or safety alerts detected.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),

              decoration: BoxDecoration(
                color: accentColor.withOpacity(
                  0.08,
                ),

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: const Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: accentColor,
                  ),

                  SizedBox(width: 7),

                  Text(
                    'System is stable',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM SHEET
  // ============================================================

  void _showAlertBottomSheet(
    BuildContext context,
    Map<String, dynamic> alert,
  ) {
    final imageUrl =
        alert['imageUrl']?.toString() ?? '';

    final time =
        alert['time'] as DateTime?;

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.82,

          decoration: const BoxDecoration(
            color: backgroundColor,

            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),

          child: Column(
            children: [
              // ==================================================
              // HANDLE
              // ==================================================

              const SizedBox(height: 10),

              Container(
                width: 45,
                height: 5,

                decoration: BoxDecoration(
                  color: Color(0xFF303943),

                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              // ==================================================
              // HEADER
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  12,
                  12,
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert['title']
                                ?.toString() ??
                            'Alert',

                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Get.back();
                      },

                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              Expanded(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    30,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // ==========================================
                      // IMAGE
                      // ==========================================

                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),

                          child: Image.network(
                            imageUrl,

                            width: double.infinity,
                            height: 220,

                            fit: BoxFit.cover,

                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return _largeImagePlaceholder();
                            },
                          ),
                        ),

                      const SizedBox(height: 18),

                      // ==========================================
                      // DESCRIPTION
                      // ==========================================

                      Text(
                        alert['description']
                                ?.toString() ??
                            'Safety event detected.',

                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          _statusBadge(
                            alert['status']
                                    ?.toString() ??
                                'WARNING',
                          ),

                          const SizedBox(width: 10),

                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            _formatDateTime(time),

                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Sensor Data',

                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 13),

                      // ==========================================
                      // SENSOR GRID
                      // ==========================================

                      GridView.count(
                        crossAxisCount: 2,

                        shrinkWrap: true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,

                        childAspectRatio: 1.55,

                        children: [
                          _sensorCard(
                            icon: Icons.thermostat,
                            title: 'Temperature',
                            value:
                                '${alert['temperature']} °C',
                          ),

                          _sensorCard(
                            icon: Icons.water_drop,
                            title: 'Humidity',
                            value:
                                '${alert['humidity']} %',
                          ),

                          _sensorCard(
                            icon: Icons.air,
                            title: 'Gas',
                            value:
                                '${alert['gasValue']} ppm',
                          ),

                          _sensorCard(
                            icon: Icons.sensors,
                            title: 'DHT Status',
                            value:
                                '${alert['dht']}',
                          ),

                          _sensorCard(
                            icon: Icons.memory,
                            title: 'System',
                            value:
                                '${alert['systemStatus']}',
                          ),

                          _sensorCard(
                            icon: Icons.timer,
                            title: 'Uptime',
                            value:
                                '${alert['uptime']} sec',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SENSOR CARD
  // ============================================================

  Widget _sensorCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            size: 22,
            color: accentColor,
          ),

          const SizedBox(height: 7),

          Text(
            title,

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,

            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LARGE IMAGE PLACEHOLDER
  // ============================================================

  Widget _largeImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),

      child: const Icon(
        Icons.image_outlined,
        size: 60,
        color: Colors.grey,
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return 'Unknown time';
    }

    final d = date.toLocal();

    String two(int n) =>
        n.toString().padLeft(2, '0');

    return '${d.day}/${d.month}/${d.year} '
        '${two(d.hour)}:${two(d.minute)}';
  }
}