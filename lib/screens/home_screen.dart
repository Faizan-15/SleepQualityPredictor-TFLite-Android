import 'package:flutter/material.dart';
import '../models/sleep_prediction.dart';
import '../services/tflite_sleep_service.dart';
import '../widgets/prediction_result_card.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

/// Main interactive screen allowing users to input 5 daily health metrics,
/// trigger on-device TensorFlow Lite inference, and inspect results.
class SleepHomeScreen extends StatefulWidget {
  const SleepHomeScreen({super.key});

  @override
  State<SleepHomeScreen> createState() => _SleepHomeScreenState();
}

class _SleepHomeScreenState extends State<SleepHomeScreen> {
  final TFLiteSleepService _tfliteService = TFLiteSleepService();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _stressController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();

  SleepPredictionResult? _predictionResult;
  bool _isModelReady = false;

  @override
  void initState() {
    super.initState();
    _initTFLite();
  }

  Future<void> _initTFLite() async {
    await _tfliteService.loadModel();
    if (mounted) {
      setState(() => _isModelReady = true);
    }
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    _ageController.dispose();
    _sleepController.dispose();
    _activityController.dispose();
    _stressController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  void _populateSampleData() {
    setState(() {
      _ageController.text = '28';
      _sleepController.text = '8.0';
      _activityController.text = '60';
      _stressController.text = '3';
      _bmiController.text = '22.4';
    });
  }

  void _runInference() {
    if (_ageController.text.trim().isEmpty ||
        _sleepController.text.trim().isEmpty ||
        _activityController.text.trim().isEmpty ||
        _stressController.text.trim().isEmpty ||
        _bmiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 5 health metrics before predicting.'),
        ),
      );
      return;
    }

    try {
      final metrics = SleepInputMetrics(
        age: double.parse(_ageController.text.trim()),
        sleepDurationHours: double.parse(_sleepController.text.trim()),
        physicalActivityMinutes: double.parse(_activityController.text.trim()),
        stressLevel: double.parse(_stressController.text.trim()),
        bmi: double.parse(_bmiController.text.trim()),
      );

      final result = _tfliteService.predict(metrics);
      setState(() => _predictionResult = result);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid number entered. Please check inputs.'),
        ),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to use the app.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Log out')),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Quality AI',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'On-Device Flutter TensorFlow Lite Prediction',
              style: TextStyle(fontSize: 12, color: Color(0xFFC5CAE9)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear inputs',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              for (final c in [
                _ageController,
                _sleepController,
                _activityController,
                _stressController,
                _bmiController
              ]) {
                c.clear();
              }
              _predictionResult = null;
            }),
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: !_isModelReady
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Hello, ${AuthService.instance.currentName ?? 'there'} 👋',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B)),
                    ),
                  ),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter Daily Lifestyle Metrics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildNumericField('Age (years):', 'e.g. 28', _ageController),
                          _buildNumericField(
                              'Sleep Duration (hours):', 'e.g. 8.0', _sleepController),
                          _buildNumericField('Physical Activity (minutes/day):',
                              'e.g. 60', _activityController),
                          _buildNumericField(
                              'Stress Level (1 - 10):', 'e.g. 3', _stressController),
                          _buildNumericField(
                              'Body Mass Index (BMI):', 'e.g. 22.4', _bmiController),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _runInference,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A237E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Predict Sleep',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: OutlinedButton(
                                  onPressed: _populateSampleData,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    foregroundColor: const Color(0xFF1E293B),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Auto Fill'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_predictionResult != null) ...[
                    const SizedBox(height: 18),
                    PredictionResultCard(result: _predictionResult!),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildNumericField(
      String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}