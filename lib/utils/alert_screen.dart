import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/alert_controller.dart';

class AlertScreen extends StatelessWidget {
  AlertScreen({super.key});

  final AlertController controller =
      Get.put(
    AlertController(),
  );

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor =
      Color(0xFF0B0F14);

  static const Color cardColor =
      Color(0xFF151D25);

  static const Color accentColor =
      Color(0xFF00D9A5);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            backgroundColor,

        elevation: 0,

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Alerts',
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
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
            () {
              if (controller
                  .isLoading.value) {
                return const Padding(
                  padding:
                      EdgeInsets.all(16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          accentColor,
                    ),
                  ),
                );
              }

              return IconButton(
                onPressed:
                    controller
                        .refreshAlerts,
                icon:
                    const Icon(
                  Icons.refresh,
                  color:
                      Colors.white,
                ),
              );
            },
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Obx(
        () {
          // ERROR

          if (controller
              .errorMessage
              .value
              .isNotEmpty) {
            return _errorState(
              controller
                  .errorMessage
                  .value,
            );
          }

          // LOADING

          if (controller
                  .isLoading.value &&
              controller.alerts
                  .isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    accentColor,
              ),
            );
          }

          // EMPTY

          if (controller
              .alerts
              .isEmpty) {
            return _emptyState();
          }

          // ALERT LIST

          return RefreshIndicator(
            color:
                accentColor,

            backgroundColor:
                cardColor,

            onRefresh: () async {
              await controller
                  .refreshAlerts();
            },

            child:
                ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding:
                  const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                30,
              ),

              itemCount:
                  controller
                      .alerts
                      .length,

              itemBuilder:
                  (
                context,
                index,
              ) {
                final alert =
                    controller
                        .alerts[index];

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
    final imageUrl =
        alert['imageUrl']
                ?.toString() ??
            '';

    final type =
        alert['alert_type']
                ?.toString() ??
            'AI ALERT';

    final status =
        alert['status']
                ?.toString() ??
            'UNKNOWN';

    final zone =
        alert['zone']
                ?.toString() ??
            'N/A';

    final confidence =
        _confidence(
      alert['confidence'],
    );

    final DateTime? time =
        alert['time']
            as DateTime?;

    return GestureDetector(
      onTap: () {
        _showAlertDetails(
          context,
          alert,
        );
      },

      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 14,
        ),

        padding:
            const EdgeInsets.all(14),

        decoration:
            BoxDecoration(
          color: cardColor,

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          border: Border.all(
            color: Colors.white
                .withOpacity(
              0.05,
            ),
          ),
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [
            // IMAGE

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),

              child: imageUrl
                      .isNotEmpty
                  ? Image.network(
                      imageUrl,

                      width: 78,
                      height: 78,

                      fit:
                          BoxFit.cover,

                      errorBuilder:
                          (
                        _,
                        __,
                        ___,
                      ) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),

            const SizedBox(
              width: 14,
            ),

            // CONTENT

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _title(
                            type,
                          ),

                          maxLines: 1,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 7,
                      ),

                      _statusBadge(
                        status,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    type
                        .toUpperCase(),

                    style:
                        const TextStyle(
                      color:
                          accentColor,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .location_on_outlined,
                        color:
                            Colors.grey,
                        size: 13,
                      ),

                      const SizedBox(
                        width: 3,
                      ),

                      Expanded(
                        child: Text(
                          zone,

                          maxLines: 1,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 6,
                      ),

                      Text(
                        confidence,

                        style:
                            const TextStyle(
                          color:
                              accentColor,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    _description(
                      type,
                    ),

                    maxLines: 1,

                    overflow:
                        TextOverflow
                            .ellipsis,

                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color:
                            Colors.grey,
                        size: 13,
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Text(
                        _formatDateTime(
                          time,
                        ),

                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color:
                  Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETAILS BOTTOM SHEET
  // ============================================================

  void _showAlertDetails(
    BuildContext context,
    Map<String, dynamic> alert,
  ) {
    final imageUrl =
        alert['imageUrl']
                ?.toString() ??
            '';

    final type =
        alert['alert_type']
                ?.toString() ??
            'AI ALERT';

    final status =
        alert['status']
                ?.toString() ??
            'UNKNOWN';

    final zone =
        alert['zone']
                ?.toString() ??
            'N/A';

    final confidence =
        _confidence(
      alert['confidence'],
    );

    final DateTime? time =
        alert['time']
            as DateTime?;

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor:
          Colors.transparent,

      builder: (_) {
        return Container(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.92,

          decoration:
              const BoxDecoration(
            color:
                backgroundColor,

            borderRadius:
                BorderRadius.vertical(
              top:
                  Radius.circular(
                28,
              ),
            ),
          ),

          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),

              // HANDLE

              Container(
                width: 45,
                height: 5,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFF303943,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),

              // HEADER

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  15,
                  10,
                  10,
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _title(type),

                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 21,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed:
                          () => Get.back(),

                      icon:
                          const Icon(
                        Icons.close,
                        color:
                            Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                    SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    5,
                    20,
                    30,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      // IMAGE

                      if (imageUrl
                          .isNotEmpty)
                        ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),

                          child:
                              Image.network(
                            imageUrl,

                            width:
                                double.infinity,

                            height: 230,

                            fit:
                                BoxFit.cover,

                            errorBuilder:
                                (
                              _,
                              __,
                              ___,
                            ) {
                              return _largePlaceholder();
                            },
                          ),
                        )
                      else
                        _largePlaceholder(),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==================================================
                      // ALERT INFORMATION
                      // ==================================================

                      const Text(
                        'Alert Information',

                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _infoCard(
                              Icons
                                  .warning_amber,
                              'Type',
                              type,
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _infoCard(
                              Icons
                                  .verified,
                              'Status',
                              status,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _infoCard(
                              Icons
                                  .location_on,
                              'Zone',
                              zone,
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _infoCard(
                              Icons
                                  .analytics,
                              'Confidence',
                              confidence,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _infoCard(
                        Icons.access_time,
                        'Alert Time',
                        _formatDateTime(
                          time,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // ==================================================
                      // SENSOR DATA
                      // ==================================================

                      const Text(
                        'Sensor Data',

                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      const Text(
                        'Firebase sensor readings around the alert time',

                        style:
                            TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      GridView.count(
                        crossAxisCount:
                            2,

                        shrinkWrap:
                            true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        crossAxisSpacing:
                            12,

                        mainAxisSpacing:
                            12,

                        childAspectRatio:
                            1.45,

                        children: [
                          _sensorCard(
                            Icons
                                .thermostat,
                            'Temperature',
                            _value(
                              alert[
                                  'temperature'],
                              '°C',
                            ),
                          ),

                          _sensorCard(
                            Icons
                                .water_drop,
                            'Humidity',
                            _value(
                              alert[
                                  'humidity'],
                              '%',
                            ),
                          ),

                          _sensorCard(
                            Icons.air,
                            'Gas',
                            _value(
                              alert[
                                  'gasValue'],
                              'ppm',
                            ),
                          ),

                          _sensorCard(
                            Icons.sensors,
                            'DHT Status',
                            _value(
                              alert['dht'],
                            ),
                          ),

                          _sensorCard(
                            Icons.memory,
                            'System',
                            _value(
                              alert[
                                  'systemStatus'],
                            ),
                          ),

                          _sensorCard(
                            Icons.timer,
                            'Uptime',
                            _value(
                              alert[
                                  'uptime'],
                              'sec',
                            ),
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
  // INFO CARD
  // ============================================================

  Widget _infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color: cardColor,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        border: Border.all(
          color: Colors.white
              .withOpacity(
            0.05,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          Icon(
            icon,
            color: accentColor,
            size: 22,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            title,

            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            value,

            maxLines: 2,

            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SENSOR CARD
  // ============================================================

  Widget _sensorCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color: cardColor,

        borderRadius:
            BorderRadius.circular(
          17,
        ),

        border: Border.all(
          color: Colors.white
              .withOpacity(
            0.05,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: accentColor,
            size: 24,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            title,

            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            value,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VALUE
  // ============================================================

  String _value(
    dynamic value, [
    String unit = '',
  ]) {
    if (value == null) {
      return 'N/A';
    }

    final text =
        value.toString().trim();

    if (text.isEmpty ||
        text == 'null') {
      return 'N/A';
    }

    return '$text $unit'.trim();
  }

  // ============================================================
  // CONFIDENCE
  // ============================================================

  String _confidence(
    dynamic value,
  ) {
    if (value == null) {
      return 'N/A';
    }

    final number =
        double.tryParse(
      value.toString(),
    );

    if (number == null) {
      return value.toString();
    }

    if (number <= 1) {
      return '${(number * 100).toStringAsFixed(1)}%';
    }

    return '${number.toStringAsFixed(1)}%';
  }

  // ============================================================
  // TITLE
  // ============================================================

  String _title(
    String type,
  ) {
    if (type.isEmpty) {
      return 'AI Alert';
    }

    return type
        .replaceAll(
          '_',
          ' ',
        )
        .split(' ')
        .map(
          (word) {
            if (word.isEmpty) {
              return word;
            }

            return word[0]
                    .toUpperCase() +
                word.substring(1)
                    .toLowerCase();
          },
        )
        .join(' ');
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  String _description(
    String type,
  ) {
    final value =
        type.toLowerCase();

    if (value.contains('fire')) {
      return 'Fire detected by AI monitoring system';
    }

    if (value.contains('smoke')) {
      return 'Smoke detected by AI monitoring system';
    }

    if (value.contains('helmet')) {
      return 'Helmet violation detected';
    }

    if (value.contains('gas')) {
      return 'Gas level alert detected';
    }

    return 'Safety event detected';
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
    String status,
  ) {
    Color color;

    switch (
        status.toUpperCase()) {
      case 'CRITICAL':
        color =
            Colors.redAccent;
        break;

      case 'WARNING':
        color =
            Colors.orangeAccent;
        break;

      case 'NORMAL':
        color =
            accentColor;
        break;

      default:
        color =
            Colors.grey;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration:
          BoxDecoration(
        color:
            color.withOpacity(
          0.12,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color:
              color.withOpacity(
            0.20,
          ),
        ),
      ),

      child: Text(
        status.toUpperCase(),

        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder() {
    return Container(
      width: 78,
      height: 78,

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF1C252E,
        ),

        borderRadius:
            BorderRadius.circular(
          15,
        ),
      ),

      child: const Icon(
        Icons.image_outlined,
        color: Colors.grey,
        size: 30,
      ),
    );
  }

  // ============================================================
  // LARGE PLACEHOLDER
  // ============================================================

  Widget _largePlaceholder() {
    return Container(
      width: double.infinity,
      height: 230,

      decoration:
          BoxDecoration(
        color: cardColor,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color: Colors.white
              .withOpacity(
            0.05,
          ),
        ),
      ),

      child: const Icon(
        Icons.image_outlined,
        color: Colors.grey,
        size: 60,
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          25,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 95,
              height: 95,

              decoration:
                  BoxDecoration(
                color:
                    accentColor
                        .withOpacity(
                  0.10,
                ),

                shape:
                    BoxShape.circle,

                border: Border.all(
                  color:
                      accentColor
                          .withOpacity(
                    0.15,
                  ),
                ),
              ),

              child: const Icon(
                Icons
                    .notifications_none,
                color:
                    accentColor,
                size: 48,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'No Alerts',

              style:
                  TextStyle(
                color:
                    Colors.white,
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'No smoke, fire or safety alerts detected.',

              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                color:
                    Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorState(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          25,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline,
              color:
                  Colors.redAccent,
              size: 55,
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(
              'Unable to load alerts',

              style:
                  TextStyle(
                color:
                    Colors.white,
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              error,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed:
                  controller
                      .refreshAlerts,

              icon: const Icon(
                Icons.refresh,
              ),

              label:
                  const Text(
                'Retry',
              ),

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    accentColor,

                foregroundColor:
                    Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDateTime(
    DateTime? date,
  ) {
    if (date == null) {
      return 'Unknown time';
    }

    final d =
        date.toLocal();

    String two(
      int n,
    ) =>
        n
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '${two(d.day)}/${two(d.month)}/${d.year} '
        '${two(d.hour)}:${two(d.minute)}';
  }
}