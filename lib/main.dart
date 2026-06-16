import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/screens/home_screen.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:raabta/services/deadline_notification_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await DeadlineNotificationService.instance.initialize();
  runApp(
    const ProviderScope(
      child: RaabtaApp(),
    ),
  );
}

class RaabtaApp extends StatelessWidget {
  const RaabtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raabta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF050A0F),
      ),
      home: const SplashScreen(),
    );
  }
}

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
    debugPrint('Ready to navigate');
    if (!mounted) return;

    Widget nextScreen = const LanguageScreen();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(LanguageScreen.languageKey);
      if (savedLanguage != null) {
        nextScreen = const HomeScreen();
      }
    } catch (e) {
      debugPrint('SharedPreferences unavailable, going to LanguageScreen: $e');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
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
            const Text(
              '🌙',
              style: TextStyle(fontSize: 60),
            ),
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
