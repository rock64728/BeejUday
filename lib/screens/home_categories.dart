import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather_screen.dart';
import 'profits_screen.dart';
import '../services/economics_service.dart';
import 'fpo_procurement_screen.dart';
import 'market_price_screen.dart';
import 'schemes_screen.dart';
import 'crop_recommendation_screen.dart';
import 'profile_screen.dart'; // ✅ Added import for navigation

class HomeCategories extends StatefulWidget {
  final EconomicsService economics;

  const HomeCategories({
    super.key,
    required this.economics,
  });

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  int _currentIndex = 1; // ✅ Default to 'Categories' index

  // Navigation Logic
  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      // Home -> Go back to Dashboard (Pop this screen)
      Navigator.pop(context);
    } else if (index == 1) {
      // Stay on Categories (Do nothing)
    } else if (index == 2) {
      // Profile -> Navigate to Profile Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(economics: widget.economics),
        ),
      ).then((_) {
        // Reset to categories tab when coming back from profile
        setState(() => _currentIndex = 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang.translate('categories'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            // 1. Weather
            _buildTile(
              context,
              lang.translate('weather_prediction'),
              Icons.cloud_queue,
              Colors.lightBlue,
              const WeatherScreen(),
            ),

            // 2. Govt Schemes
            _buildTile(
              context,
              lang.translate('govt_subsidies'),
              Icons.account_balance,
              Colors.teal,
              const SchemesScreen(),
            ),

            // 3. Profits
            _buildTile(
              context,
              lang.translate('profits'),
              Icons.monetization_on_outlined,
              Colors.orange,
              ProfitsScreen(economics: widget.economics),
            ),

            // 4. Market Price
            _buildTile(
              context,
              lang.translate('market_value_prediction'),
              Icons.show_chart,
              Colors.black87,
              const MarketPriceScreen(),
            ),

            // 5. FPO
            _buildTile(
              context,
              lang.translate('fpo_procurement'),
              Icons.store_mall_directory_outlined,
              Colors.deepPurple,
              const FPOProcurementScreen(),
            ),

            // 6. AI Recommendation
            _buildTile(
              context,
              lang.translate('ai_crop_recommendation'),
              Icons.tips_and_updates_outlined,
              Colors.blueAccent,
              const CropRecommendationScreen(),
            ),
          ],
        ),
      ),
      
      // ✅ Added Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: _onBottomNavTapped,
            selectedItemColor: Colors.orange.shade700,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 28),
                activeIcon: Icon(Icons.home, size: 28),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded, size: 28),
                label: "Categories",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 28),
                activeIcon: Icon(Icons.person, size: 28),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, String title, IconData icon, Color iconColor, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle Background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}