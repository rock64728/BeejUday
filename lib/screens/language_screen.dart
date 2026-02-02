import 'package:beeju_day/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/economics_service.dart';
import '../services/language_provider.dart'; // Import Provider


class LanguageScreen extends StatelessWidget {
  final EconomicsService economics;
  const LanguageScreen({super.key, required this.economics});

  @override
  Widget build(BuildContext context) {
    // Access the provider
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Animated Header based on selection
              Text(
                languageProvider.currentLanguage == 'en' ? "Namaste" : 
                (languageProvider.currentLanguage == 'hi' ? "नमस्ते" : "નમસ્તે"),
                style: const TextStyle(
                  fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto'
                ),
              ),
              const SizedBox(height: 40),
              
              Text(
                languageProvider.translate('choose_lang'), // Translated Title
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Language Buttons (Updates Provider on Click)
              _buildLanguageButton(context, "ENGLISH", 'en'),
              const SizedBox(height: 16),
              _buildLanguageButton(context, "हिन्दी", 'hi'),
              const SizedBox(height: 16),
              _buildLanguageButton(context, "ગુજરાતી", 'gu'),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Changed to black for better contrast
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoleSelectionScreen(economics: economics),
                  ),
                );
              },
                  child: Text(
                    languageProvider.translate('next'), // Translated Button
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String text, String code) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSelected = languageProvider.currentLanguage == code;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          // Highlight selected button with Green/Black
          backgroundColor: isSelected ? Colors.green.shade50 : Colors.white,
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.black, 
            width: isSelected ? 2.5 : 1.5
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          // ⚡ CHANGE LANGUAGE HERE
          languageProvider.changeLanguage(code);
        },
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isSelected ? Colors.green.shade800 : Colors.black,
          ),
        ),
      ),
    );
  }
}