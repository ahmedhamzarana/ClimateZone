import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertController extends GetxController{

final DatabaseReference currentRef = FirebaseDatabase.instance.ref('smokeSystem/current');
final DatabaseReference historyRef = FirebaseDatabase.instance.ref('smokeSystem/history');
final SupabaseClient supabase = Supabase.instance.client;

  // Current values
  final temperature = 0.0.obs;
  final humidity = 0.0.obs;
  final gasValue = 0.0.obs;
  final status = 'UNKNOWN'.obs;
  final dhtStatus = 'UNKNOWN'.obs;
  final uptime = 0.obs;

  // Last 24 history records
  final history = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    listenToRealtimeData();
    listenToHistory();
  }

  // ============================================================
  // CURRENT REALTIME DATA
  // ============================================================

  void listenToRealtimeData() {
    currentRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data == null) return;
      final values = Map<String, dynamic>.from(data as Map);
      temperature.value = double.tryParse(values['temperature'].toString()) ?? 0;
      humidity.value = double.tryParse(values['humidity'].toString()) ?? 0;
      gasValue.value = double.tryParse(values['gasValue'].toString()) ?? 0;
      status.value = values['status']?.toString() ?? 'UNKNOWN';
      dhtStatus.value = values['dht']?.toString() ?? 'UNKNOWN';
      uptime.value = int.tryParse(values['uptime'].toString()) ?? 0;
    });
  }

  // ============================================================
  // LAST 24 HISTORY RECORDS
  // ============================================================

  void listenToHistory() {
    historyRef.orderByKey().limitToLast(24).onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data == null) {
        history.clear();
        return;
      }
      final values = Map<String, dynamic>.from(data as Map);
      final List<Map<String, dynamic>> result = [];
      values.forEach((key, value) {
        if (value == null) return;
        final item = Map<String, dynamic>.from(value as Map);
        result.add({
          'id': key,
          'temperature':double.tryParse(item['temperature'].toString()) ?? 0,
          'humidity':double.tryParse(item['humidity'].toString()) ?? 0,
          'gasValue':double.tryParse(item['gasValue'].toString()) ?? 0,
          'status':item['status']?.toString() ?? 'UNKNOWN',
          'dht':item['dht']?.toString() ?? 'UNKNOWN',
          'uptime': int.tryParse(item['uptime'].toString()) ?? 0,
        });
      });

      history.value = result;
    });
  }

}