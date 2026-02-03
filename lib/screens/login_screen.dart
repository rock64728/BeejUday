import 'dart:convert'; // 🔴 ADDED for JSON
import 'package:beeju_day/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔴 ADDED for fetching user data
import '../services/auth_service.dart';
import '../services/language_provider.dart';
import '../screens/signup_screen.dart';
import '../services/economics_service.dart';
import '../services/profile_service.dart'; // 🔴 ADDED

class LoginScreen extends StatefulWidget {
  final EconomicsService economics;

  const LoginScreen({super.key, required this.economics});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    final auth = AuthService();
    final success = await auth.login(emailCtrl.text, passCtrl.text);

    if (!success) {
      setState(() => loading = false);
      if (mounted) {
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(lang.translate('invalid_login'))),
        );
      }
      return;
    }

    // 🔴 FIX: Retrieve User Name and Sync to Profile
    // This ensures that when you log in, "Jenil" appears instead of "Farmer"
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString("users");
      
      if (userData != null) {
        List users = json.decode(userData);
        // Find the user who just logged in
        var user = users.firstWhere(
          (u) => u["email"] == emailCtrl.text, 
          orElse: () => null
        );

        if (user != null) {
          // Sync this user's name to the current active profile
          await ProfileService(economics: widget.economics).saveProfile({
            "name": user['name'] ?? "Farmer",
            "email": user['email'],
            "landSize": "1.5" // Default fallback if missing
          });
        }
      }
    } catch (e) {
      print("Error syncing profile: $e");
    }

    setState(() => loading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          lang.translate('login'),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lang.translate('welcome_back'),
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 40),

                        _buildTextField(
                          controller: emailCtrl,
                          hintText: lang.translate('enter_email'),
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: passCtrl,
                          hintText: lang.translate('enter_password'),
                          isPassword: true,
                          icon: Icons.lock_outline,
                        ),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCC4D), 
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: login,
                            child: loading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : Text(
                                    lang.translate('login').toUpperCase(),
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${lang.translate('no_account')} ",
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SignupScreen(economics: widget.economics),
                                  ),
                                );
                              },
                              child: Text(
                                lang.translate('create_one'),
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.orange),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.orange, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.orange, width: 2.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}