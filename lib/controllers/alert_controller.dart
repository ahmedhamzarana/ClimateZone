import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertController extends GetxController {
  // ============================================================
  // SUPABASE
  // ============================================================

  final SupabaseClient supabase =
      Supabase.instance.client;

  static const String alertsTable = 'alerts';

  static const String bucketName =
      'clearzone-alerts';

  // ============================================================
  // FIREBASE
  // ============================================================

  final DatabaseReference currentRef =
      FirebaseDatabase.instance.ref(
    'smokeSystem/current',
  );

  final DatabaseReference historyRef =
      FirebaseDatabase.instance.ref(
    'smokeSystem/history',
  );

  StreamSubscription<DatabaseEvent>?
      currentSubscription;

  // ============================================================
  // GETX VARIABLES
  // ============================================================

  final RxList<Map<String, dynamic>> alerts =
      <Map<String, dynamic>>[].obs;

  final RxMap<String, dynamic> latestSensor =
      <String, dynamic>{}.obs;

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadAlerts();

    listenToCurrentSensor();
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    currentSubscription?.cancel();

    super.onClose();
  }

  // ============================================================
  // LOAD ALERTS
  // ============================================================

  Future<void> loadAlerts() async {
    try {
      isLoading.value = true;

      errorMessage.value = '';

      print('');
      print('================================');
      print('LOADING ALERTS');
      print('================================');

      // ----------------------------------------------------------
      // GET LATEST FIREBASE SENSOR
      // ----------------------------------------------------------

      await getLatestSensor();

      // ----------------------------------------------------------
      // GET SUPABASE ALERTS
      // ----------------------------------------------------------

      final response = await supabase
          .from(alertsTable)
          .select(
            '''
            id,
            alert_type,
            timestamp,
            image_url,
            confidence,
            zone,
            status
            ''',
          )
          .order(
            'timestamp',
            ascending: false,
          );

      final List data =
          response as List;

      print(
        'Supabase alerts found: ${data.length}',
      );

      final List<Map<String, dynamic>>
          loadedAlerts = [];

      // ----------------------------------------------------------
      // PROCESS EVERY ALERT
      // ----------------------------------------------------------

      for (final item in data) {
        final Map<String, dynamic> alert =
            Map<String, dynamic>.from(item);

        // --------------------------------------------------------
        // TIME
        // --------------------------------------------------------

        final DateTime? alertTime =
            parseDate(
          alert['timestamp'],
        );

        alert['time'] = alertTime;

        // --------------------------------------------------------
        // ALERT TYPE
        // --------------------------------------------------------

        alert['type'] =
            alert['alert_type']
                    ?.toString() ??
                'AI ALERT';

        // --------------------------------------------------------
        // TITLE
        // --------------------------------------------------------

        alert['title'] =
            getAlertTitle(
          alert['alert_type'],
        );

        // --------------------------------------------------------
        // DESCRIPTION
        // --------------------------------------------------------

        alert['description'] =
            getAlertDescription(
          alert,
        );

        // --------------------------------------------------------
        // IMAGE
        // --------------------------------------------------------

        alert['imageUrl'] =
            await getImageUrl(
          alert['image_url'],
        );

        // --------------------------------------------------------
        // FIREBASE SENSOR DATA
        // --------------------------------------------------------

        final Map<String, dynamic>
            sensorData =
            await getSensorDataForAlert(
          alertTime,
        );

        alert['temperature'] =
            sensorData['temperature'];

        alert['humidity'] =
            sensorData['humidity'];

        alert['gasValue'] =
            sensorData['gasValue'];

        alert['dht'] =
            sensorData['dht'];

        alert['systemStatus'] =
            sensorData['systemStatus'];

        alert['uptime'] =
            sensorData['uptime'];

        // --------------------------------------------------------
        // DEBUG
        // --------------------------------------------------------

        print('');
        print('------------------------------');

        print(
          'ID: ${alert['id']}',
        );

        print(
          'TYPE: ${alert['alert_type']}',
        );

        print(
          'TIME: ${alert['timestamp']}',
        );

        print(
          'IMAGE: ${alert['image_url']}',
        );

        print(
          'CONFIDENCE: ${alert['confidence']}',
        );

        print(
          'ZONE: ${alert['zone']}',
        );

        print(
          'STATUS: ${alert['status']}',
        );

        print(
          'TEMP: ${alert['temperature']}',
        );

        print(
          'HUMIDITY: ${alert['humidity']}',
        );

        print(
          'GAS: ${alert['gasValue']}',
        );

        print(
          'DHT: ${alert['dht']}',
        );

        print(
          'SYSTEM: ${alert['systemStatus']}',
        );

        print(
          'UPTIME: ${alert['uptime']}',
        );

        print('------------------------------');

        loadedAlerts.add(alert);
      }

      // ========================================================
      // SORT LATEST FIRST
      // ========================================================

      loadedAlerts.sort(
        (a, b) {
          final DateTime? aTime =
              a['time'] as DateTime?;

          final DateTime? bTime =
              b['time'] as DateTime?;

          if (aTime == null &&
              bTime == null) {
            return 0;
          }

          if (aTime == null) {
            return 1;
          }

          if (bTime == null) {
            return -1;
          }

          return bTime.compareTo(aTime);
        },
      );

      alerts.assignAll(
        loadedAlerts,
      );

      print('');
      print('================================');
      print(
        'TOTAL ALERTS: ${alerts.length}',
      );
      print('================================');
    } catch (e, stackTrace) {
      print('');
      print('================================');
      print('ALERT LOAD ERROR');
      print(e);
      print(stackTrace);
      print('================================');

      errorMessage.value =
          e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshAlerts() async {
    await loadAlerts();
  }

  // ============================================================
  // FIREBASE CURRENT LISTENER
  // ============================================================

  void listenToCurrentSensor() {
    currentSubscription =
        currentRef.onValue.listen(
      (event) {
        try {
          final value =
              event.snapshot.value;

          if (value == null) {
            return;
          }

          if (value is Map) {
            final Map<String, dynamic>
                data =
                Map<String, dynamic>.from(
              value,
            );

            latestSensor.assignAll(
              normalizeSensorData(
                data,
              ),
            );

            print('');
            print(
              'FIREBASE CURRENT SENSOR',
            );
            print(latestSensor);
          }
        } catch (e) {
          print(
            'Firebase current error: $e',
          );
        }
      },
    );
  }

  // ============================================================
  // GET LATEST FIREBASE SENSOR
  // ============================================================

  Future<void> getLatestSensor() async {
    try {
      final snapshot =
          await currentRef.get();

      if (!snapshot.exists) {
        print(
          'Firebase current sensor not found',
        );

        return;
      }

      final value =
          snapshot.value;

      if (value is Map) {
        final Map<String, dynamic>
            data =
            Map<String, dynamic>.from(
          value,
        );

        latestSensor.assignAll(
          normalizeSensorData(
            data,
          ),
        );

        print('');
        print(
          'LATEST FIREBASE SENSOR',
        );

        print(
          latestSensor,
        );
      }
    } catch (e) {
      print(
        'Latest sensor error: $e',
      );
    }
  }

  // ============================================================
  // SENSOR DATA FOR ALERT
  // ============================================================

  Future<Map<String, dynamic>>
      getSensorDataForAlert(
    DateTime? alertTime,
  ) async {
    try {
      // ----------------------------------------------------------
      // GET HISTORY
      // ----------------------------------------------------------

      final snapshot =
          await historyRef.get();

      if (snapshot.exists) {
        final value =
            snapshot.value;

        final List<
                Map<String, dynamic>>
            history = [];

        // --------------------------------------------------------
        // HISTORY IS MAP
        // --------------------------------------------------------

        if (value is Map) {
          value.forEach(
            (key, item) {
              if (item is Map) {
                final Map<String, dynamic>
                    data =
                    Map<String, dynamic>.from(
                  item,
                );

                history.add(
                  normalizeSensorData(
                    data,
                  ),
                );
              }
            },
          );
        }

        // --------------------------------------------------------
        // HISTORY IS LIST
        // --------------------------------------------------------

        if (value is List) {
          for (final item in value) {
            if (item is Map) {
              final Map<String, dynamic>
                  data =
                  Map<String, dynamic>.from(
                item,
              );

              history.add(
                normalizeSensorData(
                  data,
                ),
              );
            }
          }
        }

        print(
          'Firebase history records: '
          '${history.length}',
        );

        // --------------------------------------------------------
        // FIND CLOSEST READING
        // --------------------------------------------------------

        if (history.isNotEmpty) {
          final nearest =
              findNearestSensor(
            history,
            alertTime,
          );

          if (nearest != null) {
            return nearest;
          }
        }
      }

      // ----------------------------------------------------------
      // FALLBACK CURRENT SENSOR
      // ----------------------------------------------------------

      if (latestSensor.isNotEmpty) {
        return Map<String, dynamic>.from(
          latestSensor,
        );
      }
    } catch (e) {
      print(
        'Firebase history error: $e',
      );
    }

    // ----------------------------------------------------------
    // NO DATA
    // ----------------------------------------------------------

    return {
      'temperature': null,
      'humidity': null,
      'gasValue': null,
      'dht': null,
      'systemStatus': null,
      'uptime': null,
      'timestamp': null,
    };
  }

  // ============================================================
  // FIND NEAREST SENSOR
  // ============================================================

  Map<String, dynamic>?
      findNearestSensor(
    List<Map<String, dynamic>>
        history,
    DateTime? alertTime,
  ) {
    if (history.isEmpty) {
      return null;
    }

    if (alertTime == null) {
      return history.last;
    }

    Map<String, dynamic>?
        nearest;

    Duration?
        smallestDifference;

    for (final item in history) {
      final DateTime? sensorTime =
          parseDate(
        item['timestamp'],
      );

      if (sensorTime == null) {
        continue;
      }

      final difference =
          sensorTime
              .difference(alertTime)
              .abs();

      if (smallestDifference ==
              null ||
          difference <
              smallestDifference) {
        smallestDifference =
            difference;

        nearest = item;
      }
    }

    return nearest ??
        history.last;
  }

  // ============================================================
  // NORMALIZE FIREBASE
  // ============================================================

  Map<String, dynamic>
      normalizeSensorData(
    Map<String, dynamic> data,
  ) {
    return {
      'temperature': firstValue(
        data,
        [
          'temperature',
          'temp',
          'Temperature',
          'Temperature_C',
        ],
      ),

      'humidity': firstValue(
        data,
        [
          'humidity',
          'Humidity',
          'hum',
        ],
      ),

      'gasValue': firstValue(
        data,
        [
          'gasValue',
          'gas',
          'gas_value',
          'Gas',
          'mq2',
          'mq135',
        ],
      ),

      'dht': firstValue(
        data,
        [
          'dht',
          'dhtStatus',
          'DHT',
          'dht_status',
        ],
      ),

      'systemStatus': firstValue(
        data,
        [
          'systemStatus',
          'system_status',
          'status',
          'System',
        ],
      ),

      'uptime': firstValue(
        data,
        [
          'uptime',
          'Uptime',
        ],
      ),

      'timestamp': firstValue(
        data,
        [
          'timestamp',
          'time',
          'created_at',
        ],
      ),
    };
  }

  // ============================================================
  // FIRST VALUE
  // ============================================================

  dynamic firstValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (!data.containsKey(key)) {
        continue;
      }

      final value = data[key];

      if (value != null &&
          value
              .toString()
              .trim()
              .isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  // ============================================================
  // IMAGE URL
  // ============================================================

  Future<String> getImageUrl(
    dynamic imageValue,
  ) async {
    if (imageValue == null) {
      return '';
    }

    final path =
        imageValue
            .toString()
            .trim();

    if (path.isEmpty) {
      return '';
    }

    // Already full URL
    if (path.startsWith(
      'http://',
    ) ||
        path.startsWith(
          'https://',
        )) {
      return path;
    }

    try {
      final url =
          supabase.storage
              .from(bucketName)
              .getPublicUrl(
                path,
              );

      return url;
    } catch (e) {
      print(
        'Image URL error: $e',
      );

      return '';
    }
  }

  // ============================================================
  // ALERT TITLE
  // ============================================================

  String getAlertTitle(
    dynamic type,
  ) {
    final value =
        type?.toString() ?? '';

    if (value.isEmpty) {
      return 'AI Alert';
    }

    switch (value.toLowerCase()) {
      case 'fire':
      case 'fire detected':
        return 'Fire Detected';

      case 'smoke':
      case 'smoke detected':
        return 'Smoke Detected';

      case 'helmet':
      case 'helmet violation':
        return 'Helmet Violation';

      case 'gas':
      case 'gas alert':
        return 'Gas Alert';

      default:
        return value
            .replaceAll(
              '_',
              ' ',
            )
            .toUpperCase();
    }
  }

  // ============================================================
  // ALERT DESCRIPTION
  // ============================================================

  String getAlertDescription(
    Map<String, dynamic> alert,
  ) {
    final type =
        alert['alert_type']
                ?.toString()
                .toLowerCase() ??
            '';

    if (type.contains('fire')) {
      return 'Fire detected by the AI monitoring system.';
    }

    if (type.contains('smoke')) {
      return 'Smoke detected by the AI monitoring system.';
    }

    if (type.contains('helmet')) {
      return 'Helmet safety violation detected.';
    }

    if (type.contains('gas')) {
      return 'Abnormal gas level detected.';
    }

    return 'Safety event detected by the monitoring system.';
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  DateTime? parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime
          .fromMillisecondsSinceEpoch(
        value,
      );
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(
      text,
    );
  }
}