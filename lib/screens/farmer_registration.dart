import 'package:beeju_day/screens/dashboard_screen.dart';
import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/economics_service.dart';
import '../services/profile_service.dart';


class FarmerRegistration extends StatefulWidget {
  final EconomicsService economics;

  const FarmerRegistration({super.key, required this.economics});

  @override
  State<FarmerRegistration> createState() => _FarmerRegistrationState();
}

class _FarmerRegistrationState extends State<FarmerRegistration> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController villageController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController landSizeController = TextEditingController();

  String? soilType;
  String? irrigation;
  String? marketAccess;
  String? cropPreference;
  String? experience;

  @override
  Widget build(BuildContext context) {
    // 🔴 CHANGE 1: Initialize Provider
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  // 🔴 CHANGE 2: Translate Header Title
                  Text(
                    lang.translate('farmer_registration'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A), 
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // 🔴 CHANGE 3: Translate Labels & Hints for Text Fields
                      _styledTextField(
                        controller: villageController,
                        label: lang.translate('village_district'),
                        hint: lang.translate('enter_here'),
                        lang: lang, // Pass lang for validation message
                      ),
                      
                      _styledTextField(
                        controller: stateController,
                        label: lang.translate('state'),
                        hint: lang.translate('enter_state'),
                        lang: lang,
                      ),
                      
                      _styledTextField(
                        controller: landSizeController,
                        label: lang.translate('land_size_hectares'),
                        hint: lang.translate('enter_here'),
                        inputType: TextInputType.number,
                        lang: lang,
                      ),

                      const SizedBox(height: 10),

                      // 🔴 CHANGE 4: Translate Dropdown Labels & Options
                      // We pass 'lang' to the helper so it can translate the list items dynamically
                      _dropdown(lang.translate('soil_type'), ["Sandy", "Loamy", "Clayey"], (v) => soilType = v, lang),
                      _dropdown(lang.translate('irrigation'), ["Rainfed", "Irrigated"], (v) => irrigation = v, lang),
                      _dropdown(lang.translate('market_access'), ["Nearby Mandi", "Local Trader", "FPO Member"], (v) => marketAccess = v, lang),
                      _dropdown(lang.translate('preferred_crop'), ["Mustard", "Groundnut", "Paddy", "Maize"], (v) => cropPreference = v, lang),
                      _dropdown(lang.translate('experience'), ["Beginner", "1-3 years", "3+ years"], (v) => experience = v, lang),

                      const SizedBox(height: 30),

                      // Submit Button
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
                          onPressed: _onSubmit,
                          child: Text(
                            // 🔴 CHANGE 5: Translate Button Text
                            lang.translate('submit').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for text fields
  // 🔴 CHANGE 6: Added 'lang' parameter for validation
  Widget _styledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required LanguageProvider lang, 
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.orange, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          // 🔴 CHANGE 7: Translate Validation Message
          validator: (v) => v == null || v.isEmpty ? lang.translate('required') : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper for Dropdowns
  // 🔴 CHANGE 8: Added 'lang' parameter to translate list items
  Widget _dropdown(String label, List<String> items, Function(String?) onChanged, LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        DropdownButtonFormField<String>(
          icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            // 🔴 CHANGE 9: Translate Hint "Choose Soil Type"
            hintText: "${lang.translate('choose')} $label",
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.orange, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
          ),
          // 🔴 CHANGE 10: Translate Display Items
          // Value remains "Sandy" (English), but Child becomes "रेतीلی" (Translated)
          items: items.map((i) => DropdownMenuItem(
            value: i, 
            child: Text(lang.translate(i))
          )).toList(),
          onChanged: onChanged,
          // 🔴 CHANGE 11: Translate Validation
          validator: (v) => v == null ? lang.translate('required') : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final profileData = {
      "village": villageController.text.trim(),
      "state": stateController.text.trim(),
      "landSize": landSizeController.text.trim(),
      "soil": soilType,
      "irrigation": irrigation,
      "market": marketAccess,
      "cropPreference": cropPreference,
      "experience": experience,
    };

    await ProfileService(economics: EconomicsService()).saveProfile(profileData);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(),
      ),
    );
  }
}