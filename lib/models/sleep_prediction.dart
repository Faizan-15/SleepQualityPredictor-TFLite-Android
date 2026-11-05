import 'package:flutter/material.dart';

/// Represents the structured input features for the Sleep Quality TFLite model.
class SleepInputMetrics {
  final double age;
  final double sleepDurationHours;
  final double physicalActivityMinutes;
  final double stressLevel;
  final double bmi;

  const SleepInputMetrics({
    required this.age,
    required this.sleepDurationHours,
    required this.physicalActivityMinutes,
    required this.stressLevel,
    required this.bmi,
  });

  /// Returns the raw feature vector in the exact order expected by the model:
  /// [Age, SleepDuration, PhysicalActivity, StressLevel, BMI]
  List<double> toRawList() => [
        age,
        sleepDurationHours,
        physicalActivityMinutes,
        stressLevel,
        bmi,
      ];
}

/// Enumerates the 3 output sleep quality classifications from the neural network.
enum SleepQualityTier {
  poor,
  moderate,
  optimal,
}

/// Encapsulates the final interpreted prediction result from the TFLite Interpreter.
class SleepPredictionResult {
  final SleepQualityTier tier;
  final String label;
  final double confidence;
  final List<double> probabilities;
  final String recommendation;
  final Color statusColor;

  const SleepPredictionResult({
    required this.tier,
    required this.label,
    required this.confidence,
    required this.probabilities,
    required this.recommendation,
    required this.statusColor,
  });
}