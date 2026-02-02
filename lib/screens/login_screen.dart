import 'package:beeju_day/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/language_provider.dart';
import '../screens/signup_screen.dart';
import '../services/economics_service.dart';

class LoginScreen extends StatefulWidget {
  final EconomicsService economics;

  const LoginScreen({super.key, required this.economics});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- LOGIC PRESERVED ---
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    final auth = AuthService();
    final success = await auth.login(emailCtrl.text, passCtrl.text);

    setState(() => loading = false);

    if (!success) {
      if (mounted) {
        // 🔴 CHANGE 1: Translate SnackBar Message (Note: Requires access to context/provider)
        // Since we are inside a method, we fetch provider with listen: false
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(lang.translate('invalid_login'))),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    }
  }
  // -----------------------

  @override
  Widget build(BuildContext context) {
    // 🔴 CHANGE 2: Initialize Provider
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
                        // Back Button
                        IconButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 20),

                        // 🔴 CHANGE 3: Translate Title
                        Text(
                          lang.translate('login'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // 🔴 CHANGE 4: Translate Subtitle
                        Text(
                          lang.translate('welcome_back'),
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 40),

                        // Email Field
                        _buildTextField(
                          controller: emailCtrl,
                          // 🔴 CHANGE 5: Translate Hint
                          hintText: lang.translate('enter_email'),
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        _buildTextField(
                          controller: passCtrl,
                          // 🔴 CHANGE 6: Translate Hint
                          hintText: lang.translate('enter_password'),
                          isPassword: true,
                          icon: Icons.lock_outline,
                        ),

                        // Spacer pushes content to bottom
                        const Spacer(),

                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCC4D), 
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: login,
                            child: loading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : Text(
                                    // 🔴 CHANGE 7: Translate Button Text
                                    lang.translate('login').toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Footer: Don't have an account? Create one
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🔴 CHANGE 8: Translate "Don't have an account?"
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
                              // 🔴 CHANGE 9: Translate "Create one"
                              child: Text(
                                lang.translate('create_one'),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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

  // Helper method for the rounded orange text fields
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