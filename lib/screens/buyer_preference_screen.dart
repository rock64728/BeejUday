import 'package:flutter/material.dart';
import '../services/fpo_service.dart';

class BuyerPreferenceScreen extends StatefulWidget {
  const BuyerPreferenceScreen({super.key});

  @override
  State<BuyerPreferenceScreen> createState() => _BuyerPreferenceScreenState();
}

class _BuyerPreferenceScreenState extends State<BuyerPreferenceScreen> {
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _timelineController = TextEditingController();
  final _msgController = TextEditingController();
  
  bool loading = false;

// Inside _save() method:
Future<void> _save() async {
  if (_qtyController.text.isEmpty || _priceController.text.isEmpty) return;
  setState(() => loading = true);
  
  try {
    // 1. Post to FPO Service
    await FPOService().postBuyerRequirement(
      "My Buyer Company", // You can fetch real name here if you want
      "Mustard", // Hardcoded crop for demo, or add a Dropdown
      double.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
      double.tryParse(_qtyController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
      _msgController.text
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Requirement Posted to Farmer Marketplace!")),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    print("Error: $e");
  }
  
  setState(() => loading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Header Button Style
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text("Choose your preference", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 30),

              // FORM FIELDS
              _label("Required Quantity"),
              _inputField(_qtyController, "e.g., 50 Quintals", isNumber: true),
              
              _label("Offered Price"),
              _inputField(_priceController, "e.g., ₹5000", isNumber: true),

              _label("Delivery Timeline"),
              _inputField(_timelineController, "e.g., Within 2 days"),

              _label("Any specific message"),
              _inputField(_msgController, "e.g., High moisture content acceptable", maxLines: 3),

              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Contrast button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: loading ? null : _save,
                  child: const Text("Save Preference", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _inputField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade200, // Light grey background like design
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}