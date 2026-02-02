import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BuyerService {
  // Save Buyer Preference
  Future<void> savePreference(Map<String, String> preference) async {
    final prefs = await SharedPreferences.getInstance();
    // In a real app, this would go to a database.
    // Here we save locally for the demo.
    await prefs.setString('buyer_preference', jsonEncode(preference));
  }

  // Get Saved Preference
  Future<Map<String, String>?> getPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('buyer_preference');
    if (raw == null) return null;
    return Map<String, String>.from(jsonDecode(raw));
  }

  // Mock Data: Get Fake Requests from Farmers
  List<Map<String, dynamic>> getFarmerRequests() {
    return [
      {
        "id": "101",
        "farmer": "Ramesh Patel",
        "crop": "Mustard",
        "qty": "50 Quintals",
        "price": "₹5,800/qtl",
        "distance": "12 km away",
        "status": "pending"
      },
      {
        "id": "102",
        "farmer": "Suresh Kumar",
        "crop": "Wheat",
        "qty": "120 Quintals",
        "price": "₹2,350/qtl",
        "distance": "25 km away",
        "status": "pending"
      },
      {
        "id": "103",
        "farmer": "Anita Devi",
        "crop": "Mustard",
        "qty": "30 Quintals",
        "price": "₹5,750/qtl",
        "distance": "8 km away",
        "status": "pending"
      },
    ];
  }
}