import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/economics_service.dart';
import '../services/language_provider.dart';
import 'login_screen.dart'; // Farmer Login
import 'buyer_login_screen.dart'; // Buyer Login (We will create this next)

class RoleSelectionScreen extends StatelessWidget {
  final EconomicsService economics;
  const RoleSelectionScreen({super.key, required this.economics});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                // ignore: dead_code
                lang.translate('who_are_you'), 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                lang.translate('select_role'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),

              // 1. FARMER BUTTON
              _buildRoleCard(
                context,
                title: lang.translate('i_am_farmer'),
                icon: Icons.agriculture,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => LoginScreen(economics: economics))
                  );
                },
              ),

              const SizedBox(height: 24),

              // 2. BUYER BUTTON
              _buildRoleCard(
                context,
                title: lang.translate('i_am_buyer'),
                icon: Icons.store_mall_directory,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => BuyerLoginScreen(economics: economics))
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.withOpacity(0.8)),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}