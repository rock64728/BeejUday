import 'package:flutter/material.dart';
import '../services/auth_service.dart'; 
import '../services/economics_service.dart';
import 'buyer_dashboard_screen.dart'; 
import 'buyer_login_screen.dart';

class BuyerSignupScreen extends StatefulWidget {
  final EconomicsService economics;
  const BuyerSignupScreen({super.key, required this.economics});

  @override
  State<BuyerSignupScreen> createState() => _BuyerSignupScreenState();
}

class _BuyerSignupScreenState extends State<BuyerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final stateController = TextEditingController();
  final uniqueIdController = TextEditingController(); // GST or License No.
  final passwordController = TextEditingController();

  String? buyerType;
  bool loading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    // 1. Register User using the UPDATED Auth Service
    final auth = AuthService();
    
    // 🔴 CHANGE: Passing 'nameController.text' first so it gets saved!
    final success = await auth.register(
      nameController.text, 
      emailController.text, 
      passwordController.text
    );

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BuyerDashboardScreen()), 
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signup Failed. User may exist.")));
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Buyer Registration", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Join as a Verified Buyer", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 8),
              const Text("Access verified crops directly from farmers.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              _buildTextField(nameController, "Company / Buyer Name", Icons.business),
              _buildTextField(emailController, "Email Address", Icons.email),
              _buildTextField(phoneController, "Mobile Number", Icons.phone, isNumber: true),
              _buildTextField(stateController, "State", Icons.map),
              
              const SizedBox(height: 16),
              // Buyer Type Dropdown
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Buyer Type", Icons.category),
                items: ["Wholesaler", "Retailer", "Exporter", "Food Processing Unit"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => buyerType = v,
                validator: (v) => v == null ? "Required" : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(uniqueIdController, "Unique ID (GST / License No.)", Icons.verified_user),
              _buildTextField(passwordController, "Password", Icons.lock, isPassword: true),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: loading ? null : _signup,
                  child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("REGISTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already registered? "),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BuyerLoginScreen(economics: widget.economics))),
                    child: const Text("Login", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: _inputDecoration(label, icon),
        validator: (v) => v!.isEmpty ? "$label is required" : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue, width: 2)),
    );
  }
}