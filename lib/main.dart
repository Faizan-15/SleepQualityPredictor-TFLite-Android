import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

/// ============================================================================
/// Assignment No. 2: AI-Based Mini Application Development
/// Project: Sleep Quality Predictor (Flutter + On-Device TensorFlow Lite)
/// Author: Muhammad Faizan Ashraf (Roll No: 242201089, BSCS-5B)
/// Flow: Splash -> Login / Signup (local auth) -> Home (TFLite prediction)
/// ============================================================================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SleepQualityPredictorApp());
}

class SleepQualityPredictorApp extends StatelessWidget {
  const SleepQualityPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E));
    return MaterialApp(
      title: 'Sleep Quality AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
