import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertController extends GetxController {
  // ============================================================
  // FIREBASE
  // ============================================================

  final DatabaseReference currentRef = FirebaseDatabase.instance.ref(
    'smokeSystem/current',
  );

  final DatabaseReference historyRef = FirebaseDatabase.instance.ref(
    'smokeSystem/history',
  );

  // ============================================================
  // SUPABASE
  // ============================================================

  final SupabaseClient supabase = Supabase.instance.client;

  static const String bucketName = 'clearzone-alerts';

  // ============================================================
  // CURRENT SENSOR VALUES
  // ============================================================

  final temperature = 0.0.obs;
  final humidity = 0.0.obs;
  final gasValue = 0.0.obs;

  final status = 'UNKNOWN'.obs;
  final dhtStatus = 'UNKNOWN'.obs;
  final uptime = 0.obs;

  // ============================================================
  // FIREBASE HISTORY
  // ============================================================

  final history = <Map<String, dynamic>>[].obs;

  // ============================================================
  // ALERTS
  // ============================================================

  final alerts = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;

  // ============================================================
  // PROCESSED IMAGES
  // ============================================================

  final Set<String> processedImages = {};

  // ============================================================
  // SUBSCRIPTIONS / TIMER
  // ============================================================

  StreamSubscription<DatabaseEvent>? historySubscription;

  StreamSubscription<DatabaseEvent>? currentSubscription;

  Timer? supabaseTimer;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    // Firebase current sensor data
    listenToRealtimeData();

    // Firebase sensor history
    listenToHistory();

    // Check Supabase every 5 seconds
    supabaseTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadSupabaseAlerts();
    });

    // Initial load
    loadSupabaseAlerts();
  }

  // ============================================================
  // CURRENT REALTIME DATA
  // ============================================================

  void listenToRealtimeData() {
    currentSubscription = currentRef.onValue.listen((DatabaseEvent event) {
      try {
        final data = event.snapshot.value;

        if (data == null) {
          return;
        }

        if (data is! Map) {
          return;
        }

        final values = Map<String, dynamic>.from(data);

        temperature.value = _toDouble(values['temperature']);

        humidity.value = _toDouble(values['humidity']);

        gasValue.value = _toDouble(values['gasValue']);

        status.value = values['status']?.toString() ?? 'UNKNOWN';

        dhtStatus.value = values['dht']?.toString() ?? 'UNKNOWN';

        uptime.value = _toInt(values['uptime']);
      } catch (e) {
        debugPrint('Firebase current error: $e');
      }
    });
  }

  // ============================================================
  // FIREBASE HISTORY
  // ============================================================

  void listenToHistory() {
    historySubscription = historyRef
        .orderByKey()
        .limitToLast(100)
        .onValue
        .listen((DatabaseEvent event) {
          try {
            final data = event.snapshot.value;

            if (data == null) {
              history.clear();
              return;
            }

            if (data is! Map) {
              return;
            }

            final values = Map<String, dynamic>.from(data);

            final List<Map<String, dynamic>> result = [];

            values.forEach((key, value) {
              if (value == null) {
                return;
              }

              if (value is! Map) {
                return;
              }

              final item = Map<String, dynamic>.from(value);

              // ----------------------------------------------
              // TIMESTAMP
              // ----------------------------------------------

              final timestamp = _parseTimestamp(item['timestamp']);

              result.add({
                'id': key,

                'timestamp': timestamp,

                'temperature': _toDouble(item['temperature']),

                'humidity': _toDouble(item['humidity']),

                'gasValue': _toDouble(item['gasValue']),

                'status': item['status']?.toString() ?? 'UNKNOWN',

                'dht': item['dht']?.toString() ?? 'UNKNOWN',

                'uptime': _toInt(item['uptime']),
              });
            });

            // ----------------------------------------------
            // SORT BY TIMESTAMP
            // ----------------------------------------------

            result.sort((a, b) {
              final DateTime? aTime = a['timestamp'] as DateTime?;

              final DateTime? bTime = b['timestamp'] as DateTime?;

              if (aTime == null && bTime == null) {
                return 0;
              }

              if (aTime == null) {
                return -1;
              }

              if (bTime == null) {
                return 1;
              }

              return aTime.compareTo(bTime);
            });

            history.value = result;

            debugPrint(
              'Firebase history records: '
              '${history.length}',
            );
          } catch (e) {
            debugPrint('Firebase history error: $e');
          }
        });
  }

  // ============================================================
  // LOAD SUPABASE ALERTS
  // ============================================================

  Future<void> loadSupabaseAlerts() async {
    try {
      final files = await supabase.storage.from(bucketName).list();

      debugPrint(
        'Supabase files found: '
        '${files.length}',
      );

      for (final file in files) {
        final fileName = file.name;

        if (fileName.isEmpty) {
          continue;
        }

        // ------------------------------------------------------
        // ONLY IMAGES
        // ------------------------------------------------------

        if (!_isImage(fileName)) {
          continue;
        }

        // ------------------------------------------------------
        // DUPLICATE CHECK
        // ------------------------------------------------------

        if (processedImages.contains(fileName)) {
          continue;
        }

        // ------------------------------------------------------
        // IMAGE CREATED TIME
        // ------------------------------------------------------

        final createdAt = file.createdAt;

        if (createdAt == null || createdAt.isEmpty) {
          debugPrint(
            'Image has no createdAt: '
            '$fileName',
          );

          continue;
        }

        final detectionTime = DateTime.tryParse(createdAt);

        if (detectionTime == null) {
          debugPrint(
            'Invalid createdAt: '
            '$createdAt',
          );

          continue;
        }

        // ------------------------------------------------------
        // IMAGE URL
        // ------------------------------------------------------

        final imageUrl = supabase.storage
            .from(bucketName)
            .getPublicUrl(fileName);

        // ------------------------------------------------------
        // DETECTION TYPE
        // ------------------------------------------------------

        final type = getDetectionType(fileName);

        // ------------------------------------------------------
        // FIND MATCHING HISTORY
        // ------------------------------------------------------

        final sensorData = getSensorDataForAlert(detectionTime);

        // ------------------------------------------------------
        // CREATE ALERT
        // ------------------------------------------------------

        final alert = <String, dynamic>{
          'id': fileName,

          'type': type,

          'title': '$type DETECTED',

          'description': getDescription(type),

          'status': getAlertStatus(type),

          'time': detectionTime,

          'imageUrl': imageUrl,

          // ----------------------------------------------
          // SENSOR DATA FROM MATCHED HISTORY
          // ----------------------------------------------
          'temperature': sensorData?['temperature'] ?? temperature.value,

          'humidity': sensorData?['humidity'] ?? humidity.value,

          'gasValue': sensorData?['gasValue'] ?? gasValue.value,

          'systemStatus': sensorData?['status'] ?? status.value,

          'dht': sensorData?['dht'] ?? dhtStatus.value,

          'uptime': sensorData?['uptime'] ?? uptime.value,

          // Useful for debugging
          'historyTime': sensorData?['timestamp'],
        };

        // ------------------------------------------------------
        // ADD ALERT
        // ------------------------------------------------------

        alerts.insert(0, alert);

        // ------------------------------------------------------
        // MARK AS PROCESSED
        // ------------------------------------------------------

        processedImages.add(fileName);

        // ------------------------------------------------------
        // DEBUG
        // ------------------------------------------------------

        debugPrint('================================');

        debugPrint('NEW ALERT');

        debugPrint('IMAGE: $fileName');

        debugPrint(
          'IMAGE TIME: '
          '$detectionTime',
        );

        debugPrint(
          'HISTORY TIME: '
          '${sensorData?['timestamp']}',
        );

        debugPrint(
          'TEMPERATURE: '
          '${alert['temperature']}',
        );

        debugPrint(
          'HUMIDITY: '
          '${alert['humidity']}',
        );

        debugPrint(
          'GAS: '
          '${alert['gasValue']}',
        );

        debugPrint(
          'STATUS: '
          '${alert['systemStatus']}',
        );

        debugPrint(
          'DHT: '
          '${alert['dht']}',
        );

        debugPrint(
          'UPTIME: '
          '${alert['uptime']}',
        );

        debugPrint(
          'IMAGE URL: '
          '$imageUrl',
        );

        debugPrint('================================');
      }
    } catch (e) {
      debugPrint('Supabase alert error: $e');
    }
  }

  // ============================================================
  // FIND SENSOR DATA FOR IMAGE TIME
  // ============================================================

  Map<String, dynamic>? getSensorDataForAlert(DateTime detectionTime) {
    if (history.isEmpty) {
      debugPrint('Firebase history is empty.');

      return null;
    }

    Map<String, dynamic>? closestRecord;

    Duration? smallestDifference;

    // ----------------------------------------------------------
    // FIND NEAREST TIMESTAMP
    // ----------------------------------------------------------

    for (final record in history) {
      final recordTime = record['timestamp'] as DateTime?;

      if (recordTime == null) {
        continue;
      }

      final difference = recordTime.difference(detectionTime).abs();

      if (smallestDifference == null || difference < smallestDifference) {
        smallestDifference = difference;

        closestRecord = record;
      }
    }

    if (closestRecord == null || smallestDifference == null) {
      debugPrint('No matching history found.');

      return null;
    }

    // ----------------------------------------------------------
    // MAXIMUM DIFFERENCE
    //
    // Image and history must be within 2 minutes.
    // ----------------------------------------------------------

    const maxDifference = Duration(minutes: 2);

    if (smallestDifference > maxDifference) {
      debugPrint('History too far from image.');

      debugPrint(
        'Image time: '
        '$detectionTime',
      );

      debugPrint(
        'Closest history: '
        '${closestRecord['timestamp']}',
      );

      debugPrint(
        'Difference: '
        '$smallestDifference',
      );

      return null;
    }

    debugPrint('MATCHED HISTORY');

    debugPrint(
      'Image time: '
      '$detectionTime',
    );

    debugPrint(
      'History time: '
      '${closestRecord['timestamp']}',
    );

    debugPrint(
      'Difference: '
      '$smallestDifference',
    );

    return closestRecord;
  }

  // ============================================================
  // DETECTION TYPE
  // ============================================================

  String getDetectionType(String fileName) {
    final name = fileName.toLowerCase();

    if (name.contains('fire')) {
      return 'FIRE';
    }

    if (name.contains('smoke')) {
      return 'SMOKE';
    }

    if (name.contains('no_helmet')) {
      return 'NO HELMET';
    }

    if (name.contains('no-helmet')) {
      return 'NO HELMET';
    }

    if (name.contains('helmet')) {
      return 'HELMET';
    }

    return 'AI ALERT';
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  String getDescription(String type) {
    switch (type) {
      case 'FIRE':
        return 'Fire detected by factory camera.';

      case 'SMOKE':
        return 'Smoke detected by factory camera.';

      case 'NO HELMET':
        return 'Worker helmet was not detected.';

      case 'HELMET':
        return 'Helmet detected by factory camera.';

      default:
        return 'Factory safety event detected.';
    }
  }

  // ============================================================
  // ALERT STATUS
  // ============================================================

  String getAlertStatus(String type) {
    switch (type) {
      case 'FIRE':
      case 'SMOKE':
        return 'CRITICAL';

      case 'NO HELMET':
        return 'WARNING';

      case 'HELMET':
        return 'NORMAL';

      default:
        return 'WARNING';
    }
  }

  // ============================================================
  // CHECK IMAGE
  // ============================================================

  bool _isImage(String fileName) {
    final name = fileName.toLowerCase();

    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif');
  }

  // ============================================================
  // PARSE TIMESTAMP
  // ============================================================

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) {
      return null;
    }

    // Firebase ServerValue.timestamp
    // normally becomes milliseconds.
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    final stringValue = value.toString();

    // Try milliseconds
    final milliseconds = int.tryParse(stringValue);

    if (milliseconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }

    // Try ISO date
    return DateTime.tryParse(stringValue);
  }

  // ============================================================
  // DOUBLE CONVERTER
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // INT CONVERTER
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // REMOVE ALERT
  // ============================================================

  void removeAlert(int index) {
    if (index >= 0 && index < alerts.length) {
      alerts.removeAt(index);
    }
  }

  // ============================================================
  // CLEAR ALERTS
  // ============================================================

  void clearAlerts() {
    alerts.clear();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    currentSubscription?.cancel();

    historySubscription?.cancel();

    supabaseTimer?.cancel();

    super.onClose();
  }
}
