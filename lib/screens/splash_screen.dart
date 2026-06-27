import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    var nextLocation = '/language';

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(LanguageScreen.languageKey);
      if (savedLanguage != null) {
        nextLocation = '/home';
      }
    } catch (e) {
      debugPrint('SharedPreferences unavailable, going to LanguageScreen: $e');
    }

    if (!mounted) return;
    context.go(nextLocation);
  }

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌙', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 24),
            const Text(
              'Raabta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your Qatar Connection',
              style: TextStyle(
                color: _subtitleColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
