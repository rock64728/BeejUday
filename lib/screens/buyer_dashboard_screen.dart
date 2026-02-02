import 'package:flutter/material.dart';
import 'buyer_preference_screen.dart';
import 'buyer_requests_screen.dart';
import 'buyer_accepted_screen.dart'; // We will create this small file too
import 'buyer_notification_screen.dart';

class BuyerDashboardScreen extends StatelessWidget {
  const BuyerDashboardScreen({super.key});

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
                  const Text(
                    "Buyers name", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector( // Make icon clickable
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuyerNotificationScreen()),
                      );
                    },
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications, size: 30),
                        // Red Dot for unread status
                        Positioned(
                         right: 0,
                          top: 0,
                          child: Container(
                           width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50),

              // BUTTONS
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
          backgroundColor: const Color(0xFFFFCC4D), // The specific yellow-orange from your image
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.black, width: 1.5), // Thick black border
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}