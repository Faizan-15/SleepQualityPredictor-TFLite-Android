import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_quality_predictor/models/sleep_prediction.dart';
import 'package:sleep_quality_predictor/services/tflite_sleep_service.dart';

void main() {
  group('TFLiteSleepService On-Device Inference Tests', () {
    final service = TFLiteSleepService();

    test('Predicts Optimal Sleep for healthy active profile (TC-01)', () {
      const input = SleepInputMetrics(
        age: 28,
        sleepDurationHours: 8.0,
        physicalActivityMinutes: 60,
        stressLevel: 3,
        bmi: 22.4,
      );
      final result = service.predict(input);
      expect(result.tier, SleepQualityTier.optimal);
      expect(result.confidence, greaterThan(0.85));
    });

    test('Predicts Moderate Sleep for average profile (TC-02)', () {
      const input = SleepInputMetrics(
        age: 35,
        sleepDurationHours: 6.5,
        physicalActivityMinutes: 35,
        stressLevel: 5,
        bmi: 25.2,
      );
      final result = service.predict(input);
      expect(result.tier, SleepQualityTier.moderate);
    });

    test('Predicts Poor Sleep for high-stress low-sleep profile (TC-03)', () {
      const input = SleepInputMetrics(
        age: 46,
        sleepDurationHours: 4.5,
        physicalActivityMinutes: 15,
        stressLevel: 9,
        bmi: 30.5,
      );
      final result = service.predict(input);
      expect(result.tier, SleepQualityTier.poor);
      expect(result.confidence, greaterThan(0.85));
    });
  });
}