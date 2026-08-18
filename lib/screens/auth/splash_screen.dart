import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF00D9A5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.sensors, size: 50, color: Colors.black),
            ),

            const SizedBox(height: 25),

            const Text(
              'SmartSense',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Real-Time Environment Monitor',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 35),

            const SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF00D9A5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
