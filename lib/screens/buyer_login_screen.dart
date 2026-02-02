import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/economics_service.dart';
import 'buyer_signup_screen.dart';
import 'buyer_dashboard_screen.dart'; // Placeholder

class BuyerLoginScreen extends StatefulWidget {
  final EconomicsService economics;
  const BuyerLoginScreen({super.key, required this.economics});

  @override
  State<BuyerLoginScreen> createState() => _BuyerLoginScreenState();
}

class _BuyerLoginScreenState extends State<BuyerLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> _login() async {
    setState(() => loading = true);
    
    // Simple Login Logic (Same as Farmer for now)
    final success = await AuthService().login(emailController.text, passwordController.text);
    
    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const BuyerDashboardScreen())
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Credentials")));
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_mall_directory, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text("Buyer Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email, color: Colors.blue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: loading ? null : _login,
                  child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BuyerSignupScreen(economics: widget.economics))),
                child: const Text("New Buyer? Register Here", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}