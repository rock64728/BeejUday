import 'package:flutter/material.dart';

class FarmerExtendedRegistration extends StatefulWidget {
  final void Function(Map<String, dynamic>) onComplete;

  const FarmerExtendedRegistration({super.key, required this.onComplete});

  @override
  State<FarmerExtendedRegistration> createState() =>
      _FarmerExtendedRegistrationState();
}

class _FarmerExtendedRegistrationState
    extends State<FarmerExtendedRegistration> {
  final _formKey = GlobalKey<FormState>();

  String? soil;
  String? irrigation;
  String? experience;
  String? cropPreference;
  String? mandiAccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farmer Profile Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _dropdown("Soil Type", ["Sandy", "Loamy", "Clayey"], (v) => soil = v),
              _dropdown("Irrigation", ["Rainfed", "Irrigated"], (v) => irrigation = v),
              _dropdown("Experience", ["Beginner", "1-3 years", "3+ years"], (v) => experience = v),
              _dropdown("Preferred Crop", ["Mustard", "Groundnut", "Paddy", "Maize"], (v) => cropPreference = v),
              _dropdown("Market Access", ["Nearby Mandi", "Local Trader", "FPO Member"], (v) => mandiAccess = v),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onComplete({
                      "soil": soil,
                      "irrigation": irrigation,
                      "experience": experience,
                      "cropPreference": cropPreference,
                      "market": mandiAccess,
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }
}
