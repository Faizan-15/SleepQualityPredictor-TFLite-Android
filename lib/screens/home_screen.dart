import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sleep_prediction.dart';
import '../services/tflite_sleep_service.dart';
import '../widgets/prediction_result_card.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

/// Main interactive screen allowing users to input daily health metrics,
/// compute BMI from weight & height, trigger on-device TensorFlow Lite inference,
/// and inspect results.
class SleepHomeScreen extends StatefulWidget {
  const SleepHomeScreen({super.key});

  @override
  State<SleepHomeScreen> createState() => _SleepHomeScreenState();
}

class _SleepHomeScreenState extends State<SleepHomeScreen> {
  final TFLiteSleepService _tfliteService = TFLiteSleepService();

  // Input controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _stressController = TextEditingController();
  final TextEditingController _weightController = TextEditingController(); // kg
  final TextEditingController _heightFeetController = TextEditingController(); // feet
  final TextEditingController _heightInchesController = TextEditingController(); // inches

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
    _weightController.dispose();
    // _heightController disposed (replaced by feet/inches controllers)
    super.dispose();
  }

  void _populateSampleData() {
    setState(() {
      _ageController.text = '28';
      _sleepController.text = '8.0';
      _activityController.text = '60';
      _stressController.text = '3';
      _weightController.text = '70'; // kg
      _heightFeetController.text = '5'; // feet
      _heightInchesController.text = '9'; // inches
    });
    setState(() {
      _ageController.text = '28';
      _sleepController.text = '8.0';
      _activityController.text = '60';
      _stressController.text = '3';
      _weightController.text = '70'; // kg
      _heightFeetController.text = '5'; // feet
      _heightInchesController.text = '9'; // inches
    });
    setState(() {
      _ageController.text = '28';
      _sleepController.text = '8.0';
      _activityController.text = '60';
      _stressController.text = '3';
      _weightController.text = '70'; // kg

    });
  }

  void _runInference() {
    // Ensure all fields are filled
    if (_ageController.text.trim().isEmpty ||
        _sleepController.text.trim().isEmpty ||
        _activityController.text.trim().isEmpty ||
        _stressController.text.trim().isEmpty ||
        _weightController.text.trim().isEmpty ||
        _heightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all health metrics before predicting.'),
        ),
      );
      return;
    }

    try {
      final age = double.parse(_ageController.text.trim());
      final sleepDuration = double.parse(_sleepController.text.trim());
      final activity = double.parse(_activityController.text.trim());
      final stress = double.parse(_stressController.text.trim());
      final weight = double.parse(_weightController.text.trim());
      final heightFeet = int.parse(_heightFeetController.text.trim());
      final heightInches = int.parse(_heightInchesController.text.trim());
      final heightCm = (heightFeet * 12 + heightInches) * 2.54;

      // Range validation
      if (age < 10 || age > 120) {
        _showValidationAlert('Age must be between 10 and 120 years.');
        return;
      }
      if (sleepDuration <= 0 || sleepDuration > 24) {
        _showValidationAlert('Sleep duration must be between 0.5 and 24 hours.');
        return;
      }
      if (activity < 0 || activity > 720) {
        _showValidationAlert('Physical activity must be between 0 and 720 minutes.');
        return;
      }
      if (stress < 1 || stress > 10) {
        _showValidationAlert('Stress level must be on a scale of 1 to 10.');
        return;
      }
      if (weight < 2 || weight > 300) {
        _showValidationAlert('Weight must be between 2 and 300 kg.');
        return;
      }
      if (heightCm < 30 || heightCm > 250) {
        _showValidationAlert('Height must be between 30 and 250 cm.');
        return;
      }

      // BMI calculation
      final heightM = heightCm / 100.0;
      final bmi = weight / (heightM * heightM);

      final metrics = SleepInputMetrics(
        age: age,
        sleepDurationHours: sleepDuration,
        physicalActivityMinutes: activity,
        stressLevel: stress,
        bmi: bmi,
      );

      final result = _tfliteService.predict(metrics);
      setState(() => _predictionResult = result);

      // Show BMI as a friendly SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your BMI: ${bmi.toStringAsFixed(1)}'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      _showValidationAlert('Invalid numeric input. Please check all fields.');
    }
  }

  void _showValidationAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                _weightController,
                _heightController,
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
                          _buildNumericField(
                            label: 'Age (years):',
                            hint: 'e.g. 28 (10 - 120)',
                            controller: _ageController,
                            allowDecimal: false,
                          ),
                          _buildNumericField(
                            label: 'Sleep Duration (hours):',
                            hint: 'e.g. 8.0 (0.5 - 24)',
                            controller: _sleepController,
                            allowDecimal: true,
                          ),
                          _buildNumericField(
                            label: 'Physical Activity (minutes/day):',
                            hint: 'e.g. 60 (0 - 720)',
                            controller: _activityController,
                            allowDecimal: false,
                          ),
                          _buildNumericField(
                            label: 'Stress Level (1 - 10):',
                            hint: 'e.g. 3 (scale 1 - 10)',
                            controller: _stressController,
                            allowDecimal: false,
                          ),
                          // New weight & height fields for BMI calculation
                          _buildNumericField(
                            label: 'Weight (kg):',
                            hint: 'e.g. 70 (2 - 300)',
                            controller: _weightController,
                            allowDecimal: false,
                          ),
                          _buildNumericField(
                            label: 'Height (feet):',
                            hint: 'e.g. 5 (1 - 8)',
                            controller: _heightFeetController,
                            allowDecimal: false,
                          ),
                          _buildNumericField(
                            label: 'Height (inches):',
                            hint: 'e.g. 9 (0 - 11)',
                            controller: _heightInchesController,
                            allowDecimal: false,
                          ),
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

  Widget _buildNumericField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool allowDecimal,
  }) {
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
            keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
            inputFormatters: [
              if (allowDecimal)
                FilteringTextInputFormatter.allow(RegExp(r'^\\d*\\.?\\d{0,2}'))
              else
                FilteringTextInputFormatter.digitsOnly,
            ],
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
