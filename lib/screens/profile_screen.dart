import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/economics_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  // 🔴 FIX: Added 'economics' parameter to solve Error 4
  final EconomicsService economics;

  const ProfileScreen({super.key, required this.economics});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final nameController = TextEditingController();
  final landSizeController = TextEditingController();
  
  // Data
  String selectedSoil = "Loamy";
  String selectedIrrigation = "Rainfed";
  String selectedCrop = "Wheat";
  String selectedExperience = "2-5 Years";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 🔴 Note: ProfileService no longer needs 'economics' passed to it if you updated it as per previous steps.
    // If your ProfileService still demands it, pass widget.economics.
    final data = await ProfileService(economics: EconomicsService()).loadProfile();
    
    if (data != null) {
      setState(() {
        nameController.text = data['name'] ?? "";
        landSizeController.text = (data['landSize'] ?? "1.0").toString();
        selectedSoil = data['soil'] ?? "Loamy";
        selectedIrrigation = data['irrigation'] ?? "Rainfed";
        selectedCrop = data['crop'] ?? "Wheat";
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);
      
      await ProfileService(economics: EconomicsService()).saveProfile({
        "name": nameController.text,
        "landSize": landSizeController.text, // This is now treated as Acres
        "soil": selectedSoil,
        "irrigation": selectedIrrigation,
        "crop": selectedCrop,
        "experience": selectedExperience,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Provider.of<LanguageProvider>(context, listen: false).translate('profile_saved')))
        );
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(lang.translate('my_profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: loading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _buildLabel(lang.translate('full_name')),
                  TextFormField(
                    controller: nameController,
                    decoration: _inputDecoration(lang.translate('name')),
                  ),
                  const SizedBox(height: 20),

                  // Land Size (Acres)
                  // 🔴 The key 'land_size_hectares' was updated in LanguageProvider to say "Land Size (Acres)"
                  _buildLabel(lang.translate('land_size_hectares')), 
                  TextFormField(
                    controller: landSizeController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("e.g. 2.5"),
                  ),
                  const SizedBox(height: 20),

                  // Soil Dropdown
                  _buildLabel(lang.translate('soil_type')),
                  _buildDropdown(
                    value: selectedSoil,
                    items: ["Sandy", "Loamy", "Clayey", "Black", "Red"],
                    onChanged: (v) => setState(() => selectedSoil = v!),
                    lang: lang
                  ),
                  const SizedBox(height: 20),

                  // Irrigation Dropdown
                  _buildLabel(lang.translate('irrigation')),
                  _buildDropdown(
                    value: selectedIrrigation,
                    items: ["Rainfed", "Irrigated"],
                    onChanged: (v) => setState(() => selectedIrrigation = v!),
                    lang: lang
                  ),
                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: _saveProfile,
                      child: Text(lang.translate('update_profile'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Logout Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Pass economics to login screen to keep chain alive
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(economics: widget.economics)));
                      },
                      child: const Text("Log Out", style: TextStyle(color: Colors.red)),
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged, required LanguageProvider lang}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(
            value: e, 
            child: Text(lang.translate(e)) // Translate item
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}