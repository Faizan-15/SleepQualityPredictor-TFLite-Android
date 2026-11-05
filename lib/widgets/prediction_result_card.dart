import 'package:flutter/material.dart';
import '../models/sleep_prediction.dart';

/// Displays the AI prediction outcome, class probability breakdown,
/// and personalized clinical sleep hygiene advice.
class PredictionResultCard extends StatelessWidget {
  final SleepPredictionResult result;

  const PredictionResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final pPoor = (result.probabilities[0] * 100).toStringAsFixed(0);
    final pMod = (result.probabilities[1] * 100).toStringAsFixed(0);
    final pOpt = (result.probabilities[2] * 100).toStringAsFixed(0);
    final conf = (result.confidence * 100).toStringAsFixed(1);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: result.statusColor, width: 1.4),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Prediction Outcome',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              result.label,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: result.statusColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: $conf%  (P: $pPoor%, M: $pMod%, O: $pOpt%)',
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF334155),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
            Text(
              result.recommendation,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}