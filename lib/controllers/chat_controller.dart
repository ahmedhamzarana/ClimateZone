import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatController extends GetxController {
  // ============================================================
  // FIREBASE REFERENCES
  // ============================================================

  final DatabaseReference currentRef =
      FirebaseDatabase.instance.ref('smokeSystem/current');

  final DatabaseReference historyRef =
      FirebaseDatabase.instance.ref('smokeSystem/history');

  // ============================================================
  // GEMINI
  // ============================================================

  late final GenerativeModel geminiModel;

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
  // HISTORY
  // ============================================================

  final history = <Map<String, dynamic>>[].obs;

  // ============================================================
  // CHAT MESSAGES
  // ============================================================

  final messages = <Map<String, dynamic>>[
    {
      'isBot': true,
      'message':
          'Hello! I am SmartSense AI. Ask me about temperature, humidity, gas level, system status, or sensor history.',
    },
  ].obs;

  // ============================================================
  // LOADING
  // ============================================================

  final isLoading = false.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    listenToRealtimeData();
    listenToHistory();

    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception(
        'GEMINI_API_KEY is missing from .env',
      );
    }

    geminiModel = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: apiKey,
    );
  }

  // ============================================================
  // CURRENT REALTIME DATA
  // ============================================================

  void listenToRealtimeData() {
    currentRef.onValue.listen(
      (DatabaseEvent event) {
        try {
          final data = event.snapshot.value;

          if (data == null) return;

          if (data is! Map) return;

          final values =
              Map<String, dynamic>.from(data);

          temperature.value =
              double.tryParse(
                    values['temperature'].toString(),
                  ) ??
                  0;

          humidity.value =
              double.tryParse(
                    values['humidity'].toString(),
                  ) ??
                  0;

          gasValue.value =
              double.tryParse(
                    values['gasValue'].toString(),
                  ) ??
                  0;

          status.value =
              values['status']?.toString() ??
              'UNKNOWN';

          dhtStatus.value =
              values['dht']?.toString() ??
              'UNKNOWN';

          uptime.value =
              int.tryParse(
                    values['uptime'].toString(),
                  ) ??
                  0;
        } catch (e) {
          print('Realtime data error: $e');
        }
      },
      onError: (error) {
        print('Firebase realtime error: $error');
      },
    );
  }

  // ============================================================
  // HISTORY
  // ============================================================

  void listenToHistory() {
    historyRef
        .orderByKey()
        .limitToLast(24)
        .onValue
        .listen(
      (DatabaseEvent event) {
        try {
          final data = event.snapshot.value;

          if (data == null) {
            history.clear();
            return;
          }

          if (data is! Map) return;

          final values =
              Map<String, dynamic>.from(data);

          final List<Map<String, dynamic>> result =
              [];

          values.forEach((key, value) {
            if (value == null) return;

            if (value is! Map) return;

            final item =
                Map<String, dynamic>.from(value);

            result.add({
              'id': key,
              'temperature':
                  double.tryParse(
                        item['temperature']
                            .toString(),
                      ) ??
                      0,
              'humidity':
                  double.tryParse(
                        item['humidity'].toString(),
                      ) ??
                      0,
              'gasValue':
                  double.tryParse(
                        item['gasValue'].toString(),
                      ) ??
                      0,
              'status':
                  item['status']?.toString() ??
                  'UNKNOWN',
              'dht':
                  item['dht']?.toString() ??
                  'UNKNOWN',
              'uptime':
                  int.tryParse(
                        item['uptime'].toString(),
                      ) ??
                      0,
            });
          });

          history.value = result;
        } catch (e) {
          print('History data error: $e');
        }
      },
      onError: (error) {
        print('Firebase history error: $error');
      },
    );
  }

  // ============================================================
  // BUILD SENSOR CONTEXT FOR GEMINI
  // ============================================================

  String buildSensorContext() {
    final recentHistory = history.take(5).toList();

    final historyText = recentHistory.isEmpty
        ? 'No historical records available.'
        : recentHistory.map((item) {
            return '''
Temperature: ${item['temperature']} °C
Humidity: ${item['humidity']} %
Gas: ${item['gasValue']} ppm
Status: ${item['status']}
DHT: ${item['dht']}
Uptime: ${item['uptime']} seconds
''';
          }).join('\n');

    return '''
CURRENT SMARTSENSE SENSOR DATA

Temperature: ${temperature.value.toStringAsFixed(1)} °C
Humidity: ${humidity.value.toStringAsFixed(0)} %
Gas: ${gasValue.value.toStringAsFixed(0)} ppm
System Status: ${status.value}
DHT Status: ${dhtStatus.value}
ESP32 Uptime: ${uptime.value} seconds

Recent history records:
$historyText
''';
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage(String question) async {
    final text = question.trim();

    if (text.isEmpty || isLoading.value) {
      return;
    }

    messages.add({
      'isBot': false,
      'message': text,
    });

    isLoading.value = true;

    messages.add({
      'isBot': true,
      'message': 'Thinking...',
      'loading': true,
    });

    try {
      final answer = await generateAnswer(text);

      if (messages.isNotEmpty &&
          messages.last['loading'] == true) {
        messages.removeLast();
      }

      messages.add({
        'isBot': true,
        'message': answer,
      });
    } catch (e, stackTrace) {
  print('================ GEMINI ERROR ================');
  print(e);
  print(stackTrace);
  print('==============================================');

  if (messages.isNotEmpty &&
      messages.last['loading'] == true) {
    messages.removeLast();
  }

  messages.add({
    'isBot': true,
    'message': 'Gemini Error: $e',
  });
} finally {
  isLoading.value = false;
}
  }

  // ============================================================
  // GEMINI
  // ============================================================

  Future<String> generateAnswer(
    String question,
  ) async {
    final sensorContext =
        buildSensorContext();

    final prompt = '''
You are SmartSense AI, an environmental monitoring assistant for an ESP32-based monitoring system.

$sensorContext

IMPORTANT RULES:

1. Use the sensor values above when answering questions about the user's environment.
2. Never invent a temperature, humidity, gas value, status, DHT state, uptime, or history value.
3. If the user asks for current sensor information, use CURRENT SMARTSENSE SENSOR DATA.
4. If the user asks about recent measurements or trends, use the history information.
5. If the user asks whether a value is high or low, explain it simply.
6. Keep answers concise and easy to understand.
7. If the question is unrelated to the SmartSense environment monitor, politely explain that you mainly help with the monitoring system.
8. Do not claim that you physically inspected the environment.
9. Do not provide dangerous instructions.

USER QUESTION:

$question
''';

    final response =
        await geminiModel.generateContent([
      Content.text(prompt),
    ]);

    return response.text?.trim() ??
        'Gemini did not return a response.';
  }

  // ============================================================
  // CLEAR CHAT
  // ============================================================

  void clearChat() {
    messages.clear();

    messages.add({
      'isBot': true,
      'message':
          'Hello! I am SmartSense AI. How can I help you?',
    });
  }

  // ============================================================
  // DISPOSE FIREBASE LISTENERS
  // ============================================================

  @override
  void onClose() {
    currentRef.onValue.drain();
    historyRef.onValue.drain();

    super.onClose();
  }
}