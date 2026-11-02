import 'package:flutter/material.dart';
import '../core/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 100, color: Colors.white),
            SizedBox(height: 24),
            Text('Absensi QR Live',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Hadir tercatat, real-time.',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                  backgroundColor: Colors.white24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
