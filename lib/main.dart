import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// ============================================================================
/// Assignment No. 2: AI-Based Mini Application Development
/// Project: Sleep Quality Predictor (Flutter + On-Device TensorFlow Lite)
/// Author: Muhammad Faizan Ashraf (Roll No: 242201089, BSCS-5B)
/// ============================================================================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SleepQualityPredictorApp());
}

class SleepQualityPredictorApp extends StatelessWidget {
  const SleepQualityPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Quality AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      home: const SleepHomeScreen(),
    );
  }
}