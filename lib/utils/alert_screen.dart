import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Alerts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          alertCard(
            title: 'Critical Humidity Drop',
            description:
                'Humidity has dropped below the safe level.',
            status: 'CRITICAL',
            time: 'Just now',
            color: Colors.redAccent,
            icon: Icons.water_drop_outlined,

            temperature: '29.4 °C',
            humidity: '24 %',
            gas: '312 ppm',
            systemStatus: 'WARNING',

            imageUrl:
                'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17?auto=format&fit=crop&w=1000&q=80',
          ),

          const SizedBox(height: 16),

          alertCard(
            title: 'Bad Weather Warning',
            description:
                'Atmospheric conditions indicate possible heavy rain.',
            status: 'WARNING',
            time: '12 mins ago',
            color: Colors.amber,
            icon: Icons.thunderstorm_outlined,

            temperature: '30.1 °C',
            humidity: '68 %',
            gas: '330 ppm',
            systemStatus: 'WARNING',

            imageUrl:
                'https://images.unsplash.com/photo-1605727216801-e27ce1d0cc28?auto=format&fit=crop&w=1000&q=80',
          ),

          const SizedBox(height: 16),

          alertCard(
            title: 'Air Quality Restored',
            description:
                'Gas and smoke levels returned to normal.',
            status: 'RESOLVED',
            time: '1 hour ago',
            color: const Color(0xFF00D9A5),
            icon: Icons.check_circle_outline,

            temperature: '28.7 °C',
            humidity: '55 %',
            gas: '318 ppm',
            systemStatus: 'NORMAL',

            imageUrl:
                'https://images.unsplash.com/photo-1516939884455-1445c8652f83?auto=format&fit=crop&w=1000&q=80',
          ),
        ],
      ),
    );
  }

  Widget alertCard({
    required String title,
    required String description,
    required String status,
    required String time,
    required Color color,
    required IconData icon,
    required String temperature,
    required String humidity,
    required String gas,
    required String systemStatus,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        showAlertBottomSheet(
          title: title,
          description: description,
          status: status,
          time: time,
          color: color,
          icon: icon,
          temperature: temperature,
          humidity: humidity,
          gas: gas,
          systemStatus: systemStatus,
          imageUrl: imageUrl,
        );
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151D25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(.2),
          ),
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAlertBottomSheet({
    required String title,
    required String description,
    required String status,
    required String time,
    required Color color,
    required IconData icon,
    required String temperature,
    required String humidity,
    required String gas,
    required String systemStatus,
    required String imageUrl,
  }) {
    Get.bottomSheet(
      AlertBottomSheet(
        title: title,
        description: description,
        status: status,
        time: time,
        color: color,
        icon: icon,
        temperature: temperature,
        humidity: humidity,
        gas: gas,
        systemStatus: systemStatus,
        imageUrl: imageUrl,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}


// ============================================================
// BOTTOM SHEET
// ============================================================

class AlertBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final String time;
  final Color color;
  final IconData icon;

  final String temperature;
  final String humidity;
  final String gas;
  final String systemStatus;

  final String imageUrl;

  const AlertBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.time,
    required this.color,
    required this.icon,
    required this.temperature,
    required this.humidity,
    required this.gas,
    required this.systemStatus,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      height: MediaQuery.of(context).size.height * .90,

      decoration: const BoxDecoration(
        color: Color(0xFF0F151C),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),

      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: color.withOpacity(.12),
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              time,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // CURRENT TIME
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151D25),
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.cyanAccent,
                        ),

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Time',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              '${now.hour.toString().padLeft(2, '0')}:'
                              '${now.minute.toString().padLeft(2, '0')}:'
                              '${now.second.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        const Text(
                          'Asia/Karachi',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // STATUS
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.08),
                      borderRadius:
                          BorderRadius.circular(17),
                      border: Border.all(
                        color: color.withOpacity(.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: color,
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          'Alert Status',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          status,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // ALERT DESCRIPTION
                  // ==================================================

                  const Text(
                    'Alert Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF9EAFBC),
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // CURRENT SENSOR DATA
                  // ==================================================

                  const Text(
                    'Current Sensor Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: sensorBox(
                          Icons.thermostat,
                          'Temperature',
                          temperature,
                          Colors.orangeAccent,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: sensorBox(
                          Icons.water_drop,
                          'Humidity',
                          humidity,
                          Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: sensorBox(
                          Icons.air,
                          'Gas',
                          gas,
                          Colors.purpleAccent,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: sensorBox(
                          Icons.memory,
                          'System',
                          systemStatus,
                          color,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // INTERNET IMAGE
                  // ==================================================

                  const Text(
                    'Detection Evidence',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => FullScreenImage(
                          imageUrl: imageUrl,
                          title: title,
                        ),
                      );
                    },

                    child: Hero(
                      tag: imageUrl,

                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20),

                        child: Stack(
                          children: [
                            Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 230,
                              fit: BoxFit.cover,

                              loadingBuilder:
                                  (
                                context,
                                child,
                                progress,
                              ) {
                                if (progress == null) {
                                  return child;
                                }

                                return Container(
                                  height: 230,
                                  color:
                                      const Color(
                                    0xFF151D25,
                                  ),
                                  child: const Center(
                                    child:
                                        CircularProgressIndicator(
                                      color:
                                          Colors.cyanAccent,
                                    ),
                                  ),
                                );
                              },

                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  height: 230,
                                  color:
                                      const Color(
                                    0xFF151D25,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons
                                          .broken_image_outlined,
                                      color:
                                          Colors.white38,
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                            ),

                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black
                                      .withOpacity(.65),
                                  borderRadius:
                                      BorderRadius
                                          .circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .fullscreen,
                                      color:
                                          Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'View Full',
                                      style: TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // CLOSE
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),

                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sensorBox(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151D25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),

          const SizedBox(height: 9),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// FULL SCREEN IMAGE
// ============================================================

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullScreenImage({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),

      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Hero(
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
