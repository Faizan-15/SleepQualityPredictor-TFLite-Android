import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Animated splash screen shown at app launch.
/// After a short delay it routes to Home (if a session exists) or Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final results = await Future.wait([
      AuthService.instance.init(),
      Future.delayed(const Duration(milliseconds: 2200)),
    ]);
    if (!mounted) return;
    final loggedIn = results.first as bool;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
            loggedIn ? const SleepHomeScreen() : const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1442), Color(0xFF1A237E), Color(0xFF3949AB)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
            child: ScaleTransition(
              scale: Tween(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    child: const Icon(Icons.nightlight_round,
                        size: 84, color: Colors.amberAccent),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Sleep Quality AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'On-device TensorFlow Lite prediction',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                  ),
                  const SizedBox(height: 48),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.amberAccent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
