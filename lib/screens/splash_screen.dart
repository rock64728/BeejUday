import 'package:flutter/material.dart';
import '../services/economics_service.dart';
import '../services/local_user_service.dart';
import 'language_screen.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  final EconomicsService economics;

  const SplashScreen({super.key, required this.economics});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSignupStatus();
  }

  Future<void> _checkSignupStatus() async {
    final storage = LocalUserService();
    bool signedUp = await storage.isSignedUp();

    await Future.delayed(const Duration(seconds: 2)); // splash delay

    if (signedUp) {
      print("USER FOUND → SKIPPING SIGNUP");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LanguageScreen(economics: widget.economics)),
      );
    } else {
      print("NO USER → SHOWING SIGNUP");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignupScreen(economics: widget.economics)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: const Center(
        child: Text(
          "BEEJUDAY",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
