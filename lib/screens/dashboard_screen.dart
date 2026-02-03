import 'package:beeju_day/screens/weather_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ 1. Imported URL Launcher
import '../services/language_provider.dart';
import '../services/weather_service.dart';
import '../services/profile_service.dart';
import '../services/economics_service.dart';


// Import Feature Screens
import 'market_price_screen.dart';
import 'crop_recommendation_screen.dart';
import 'fpo_procurement_screen.dart';
import 'home_categories.dart';
import 'profile_screen.dart';
import 'schemes_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Data Variables
  String userName = "Farmer";
  String landLocation = "Your Land";
  double temp = 30.0;
  String weatherDesc = "Sunny";
  bool loadingWeather = true;

  // ✅ 2. REAL SCHEME DATA (For URL Launcher)
  final List<Map<String, String>> governmentSchemes = [
    {
      "name": "PM-KISAN Samman Nidhi",
      "amount": "₹6,000/year",
      "desc": "Financial support of ₹6,000 per year in three equal installments to all land-holding farmer families.",
      "url": "https://pmkisan.gov.in/"
    },
    {
      "name": "NMEO-OS (Oilseeds)",
      "amount": "Seed Subsidy",
      "desc": "Special focus on increasing production of Edible Oils. Subsidies on seeds and inputs.",
      "url": "https://nmeo.dac.gov.in/"
    },
    {
      "name": "Agri Infra Fund",
      "amount": "Interest Subvention",
      "desc": "Financing facility for setting up Post-Harvest Management Infrastructure.",
      "url": "https://agriinfra.dac.gov.in/"
    }
  ];

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    await _fetchWeather();
    await _fetchUserData();
  }

  // --- DATA FETCHING ---

  Future<void> _fetchUserData() async {
    try {
      final profile = await ProfileService(economics: EconomicsService()).loadProfile(); // No economics needed here

      if (mounted && profile != null) {
        setState(() {
          userName = profile['name'] ?? "Farmer";
          
          String v = profile['village'] ?? "";
          String s = profile['state'] ?? "";
          String land = profile['landSize'] ?? ""; 

          String loc = "";
          if (v.isNotEmpty) loc += v;
          if (v.isNotEmpty && s.isNotEmpty) loc += ", ";
          if (s.isNotEmpty) loc += s;

          if (land.isNotEmpty) {
             if (loc.isNotEmpty) loc += " • ";
             loc += "$land Acres"; 
          }
          
          if (loc.isNotEmpty) landLocation = loc;
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  Future<void> _fetchWeather() async {
    setState(() => loadingWeather = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      final data = await WeatherService().getWeather(pos.latitude, pos.longitude);

      if (mounted) {
        setState(() {
          if (data['current_weather'] != null) {
            temp = (data['current_weather']['temperature'] ?? temp).toDouble();
            weatherDesc = "Clear Sky"; 
          }
          loadingWeather = false;
        });
      }
    } catch (e) {
      print("Weather Error: $e");
      if (mounted) setState(() => loadingWeather = false);
    }
  }

  // --- LOGIC FOR URL LAUNCHER ---

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showSchemeDetails(Map<String, String> scheme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(scheme['name']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(scheme['amount']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(height: 30),
              const Text("Description", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(scheme['desc']!, style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close popup
                    _launchURL(scheme['url']!); // Open Website
                  },
                  child: const Text("Apply on Official Website", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);

    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomeCategories(economics: EconomicsService())));
    } else if (index == 2) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => ProfileScreen(economics: EconomicsService()))
      ).then((_) {
        _fetchUserData(); 
        setState(() => _currentIndex = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(lang),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // HERO CARDS
                    _buildHeroSection(lang),

                    const SizedBox(height: 20),

                    // Categories Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(lang.translate('categories'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomeCategories(economics: EconomicsService()))),
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Category Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCategoryCircle(
                          icon: Icons.wb_sunny, 
                          label: lang.translate('weather_prediction'), 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()))
                        ),
                        _buildCategoryCircle(
                          icon: Icons.show_chart, 
                          label: lang.translate('market_insights'), 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketPriceScreen()))
                        ),
                        _buildCategoryCircle(
                          icon: Icons.money, 
                          label: lang.translate('govt_subsidies'), 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchemesScreen()))
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text("Trending Opportunities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),

                    // 1. Internal App Feature (FPO)
                    _buildFPOCard(
                      "Sahyadri FPO Procurement", 
                      "Wheat @ ₹2400/qt", 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FPOProcurementScreen()))
                    ),
                    const SizedBox(height: 12),

                    // 2. External Govt Schemes (Mapped from List)
                    ...governmentSchemes.map((scheme) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildGovtSchemeCard(scheme),
                    )).toList(),

                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(lang),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildTopHeader(LanguageProvider lang) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        landLocation,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28, color: Colors.black87),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No new notifications"), duration: Duration(seconds: 1)),
                  );
                },
              ),
              Positioned(
                right: 8, top: 8,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(color: Colors.amber.shade600, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white, width: 1.5)),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(LanguageProvider lang) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _heroCard(
            image: 'https://cdn.pixabay.com/photo/2021/01/11/08/53/sky-5907605_1280.jpg',
            text: "${temp.toStringAsFixed(1)}°C\n$weatherDesc",
            onTap: _fetchWeather
          ),
          const SizedBox(width: 12),
          _heroCard(
            image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJfMc_4zL9h3CIbzokQriuZs7IiXPBT6W8lQ&s', 
            text: lang.translate('ai_recommendation'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropRecommendationScreen()))
          ),
        ],
      ),
    );
  }

  Widget _heroCard({required String image, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.78,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.shade300.withOpacity(0.6), blurRadius: 10, offset: const Offset(0, 6))],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(image, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.green.shade200)),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCircle({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(child: Icon(icon, size: 32, color: Colors.orange.shade700)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            label, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ✅ SPECIAL CARD FOR INTERNAL FPO
  Widget _buildFPOCard(String title, String amount, {required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200, width: 1.5), // Green border for FPO
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              Text(amount, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
            ]),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text("View", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
          )
        ],
      ),
    );
  }

  // ✅ CARD FOR GOVT SCHEMES (Uses _showSchemeDetails)
  Widget _buildGovtSchemeCard(Map<String, String> scheme) {
    return GestureDetector(
      onTap: () => _showSchemeDetails(scheme),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.shade100, width: 1),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(scheme['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(scheme['amount']!, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
              child: const Text("Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(LanguageProvider lang) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -3))]),
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
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded, size: 28), label: "Categories"),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: "Profile"),
          ],
        ),
      ),
    );
  }
}