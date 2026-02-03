import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import 'dart:convert';
import 'buyer_preference_screen.dart';
import 'buyer_requests_screen.dart';
import 'buyer_accepted_screen.dart';
import 'buyer_notification_screen.dart';

class BuyerDashboardScreen extends StatefulWidget { // Changed to StatefulWidget
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  String buyerName = "Welcome, Buyer"; // Default

  @override
  void initState() {
    super.initState();
    _fetchBuyerName();
  }

  // 🔴 NEW FUNCTION: Fetch Name
  Future<void> _fetchBuyerName() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming you saved buyer profile similar to farmer profile
    // Or simpler: get the user from the 'users' list using the logged_in_email
    final email = prefs.getString("logged_in_user");
    final userData = prefs.getString("users");
    
    if (email != null && userData != null) {
      List users = json.decode(userData);
      var user = users.firstWhere((u) => u["email"] == email, orElse: () => null);
      if (user != null && user['name'] != null) {
        setState(() {
          buyerName = "Welcome, ${user['name']}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔴 UPDATED: Dynamic Name Text
                  Text(
                    buyerName, 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuyerNotificationScreen()),
                      );
                    },
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications, size: 30),
                        Positioned(
                          right: 0, top: 0,
                          child: Container(
                            width: 10, height: 10,
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50),

              // BUTTONS (Rest remains exactly the same)
              _buildDashboardButton(
                context, 
                "Choose your preference", 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerPreferenceScreen()))
              ),
              const SizedBox(height: 20),
              
              _buildDashboardButton(
                context, 
                "Farmer Requests", 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerRequestsScreen()))
              ),
              const SizedBox(height: 20),
              
              _buildDashboardButton(
                context, 
                "List of requests accepted", 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyerAcceptedScreen()))
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC4D),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}