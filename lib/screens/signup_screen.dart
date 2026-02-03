import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/economics_service.dart';
import 'farmer_registration.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final EconomicsService economics;

  const SignupScreen({super.key, required this.economics});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // --- LOGIC PRESERVED ---
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> _signup() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
       return;
    }

    setState(() => loading = true);

    final auth = AuthService();
    
    // 🔴 UPDATED: Passing 'nameController.text' first
    final success = await auth.register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    if (!success) {
      if (mounted) {
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.translate('user_exists'))),
        );
      }
      setState(() => loading = false);
      return;
    }

    // Note: ProfileService saving is partially redundant now because AuthService does it,
    // but we keep it to ensure 'landSize' is set defaults.
    await ProfileService(economics: EconomicsService()).saveProfile({
      "name": nameController.text,
      "email": emailController.text,
      "landSize": 1.5,
    });

    if (mounted) {
      setState(() => loading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FarmerRegistration(economics: widget.economics),
        ),
      );
    }
  }
  // --- END OF LOGIC ---

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
                        // Custom Back Button
                        IconButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 28),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 20),
            
                        // 🔴 CHANGE 3: Translate Title
                        Text(
                          lang.translate('create_account'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),
            
                        // Name Field
                        _buildTextField(
                          controller: nameController,
                          // 🔴 CHANGE 4: Translate Hint
                          hintText: lang.translate('name'),
                        ),
                        const SizedBox(height: 20),
            
                        // Email Field
                        _buildTextField(
                          controller: emailController,
                          // 🔴 CHANGE 5: Translate Hint
                          hintText: lang.translate('enter_email'),
                        ),
                        const SizedBox(height: 20),
            
                        // Password Field
                        _buildTextField(
                          controller: passwordController,
                          // 🔴 CHANGE 6: Translate Hint
                          hintText: lang.translate('enter_password'),
                          isPassword: true,
                        ),
            
                        const SizedBox(height: 15),
            
                        // Terms and Conditions Text
                        // 🔴 CHANGE 7: Translate "By tapping SIGN UP you accept all terms..."
                        // Note: This is slightly complex because of the spans. 
                        // I will simplify it by constructing the sentence.
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              children: [
                                TextSpan(text: "${lang.translate('accept_terms_prefix')} \n"),
                                TextSpan(
                                  text: lang.translate('terms'),
                                  style: const TextStyle(color: Colors.orange),
                                ),
                                TextSpan(text: " ${lang.translate('and')} "),
                                TextSpan(
                                  text: lang.translate('conditions'),
                                  style: const TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                        ),
            
                        const Spacer(),
                        const SizedBox(height: 20),
            
                        // SIGN UP BUTTON
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
                            onPressed: _signup,
                            child: loading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : Text(
                                    // 🔴 CHANGE 8: Translate Button Text
                                    lang.translate('sign_up').toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
            
                        const SizedBox(height: 20),
            
                        // Footer: Already have an account? Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🔴 CHANGE 9: Translate "Already have an account?"
                            Text(
                              "${lang.translate('already_have_account')} ",
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(economics: widget.economics),
                                  ),
                                );
                              },
                              // 🔴 CHANGE 10: Translate "Login"
                              child: Text(
                                lang.translate('login'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
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