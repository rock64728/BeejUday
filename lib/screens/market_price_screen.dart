import 'package:beeju_day/services/economics_service.dart';
import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../services/profile_service.dart';
import '../services/weather_service.dart';
import 'dart:math';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  bool loading = true;
  // 🔴 CHANGE 1: Use key for loading message
  String statusMessage = "loading_market_data";

  // 1. CROP SELECTION
  String selectedCrop = "Mustard";
  final List<String> cropList = [
    "Mustard", "Wheat", "Rice", "Maize", "Cotton", 
    "Groundnut", "Sugarcane", "Bajra", "Soybean", "Jeera"
  ];

  // 2. REALISTIC DATA FACTORS
  final Map<String, Map<String, double>> cropFactors = {
    "Mustard":   {"basePrice": 6050, "baseYield": 18},
    "Wheat":     {"basePrice": 2400, "baseYield": 35},
    "Rice":      {"basePrice": 2450, "baseYield": 40},
    "Maize":     {"basePrice": 2200, "baseYield": 30},
    "Cotton":    {"basePrice": 6800, "baseYield": 22},
    "Groundnut": {"basePrice": 6500, "baseYield": 20},
    "Sugarcane": {"basePrice": 360,  "baseYield": 800},
    "Bajra":     {"basePrice": 2600, "baseYield": 25},
    "Soybean":   {"basePrice": 4800, "baseYield": 15},
    "Jeera":     {"basePrice": 29000,"baseYield": 5},
  };

  // Data variables
  List<double> prices = [];
  String region = "Gujarat"; 
  // 🔴 CHANGE 2: Store status as a code ('rising', 'falling', 'stable')
  String trendStatus = "stable"; 
  
  // AI Results
  double? predictedPrice;
  double? predictedYield;
  double? predictedProfit;

  // Real-time Inputs
  double realTemp = 30.0;
  double realHumidity = 70.0;
  double realRainfall = 100.0;
  Map<String, dynamic>? profile;

  late Interpreter priceInterpreter;
  late Interpreter yieldInterpreter;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadProfile();
    await _loadModels();
    await _fetchRealWeather();
    _updateCropData(); 
  }

  void _updateCropData() {
    setState(() => loading = true);
    _generateGraphData();
    _runPrediction();
    
    // Update Trend
    double current = prices.last;
    double prev = prices[prices.length - 2];
    
    // 🔴 CHANGE 3: Set trend status code instead of English text
    if (current > prev) trendStatus = "rising";
    else if (current < prev) trendStatus = "falling";
    else trendStatus = "stable";

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => loading = false);
    });
  }

  void _generateGraphData() {
    double base = cropFactors[selectedCrop]!["basePrice"]!;
    Random random = Random();
    
    prices = [];
    for (int i = 0; i < 7; i++) {
      double variation = (random.nextDouble() * 0.08) - 0.04; // +/- 4%
      prices.add(base + (base * variation));
    }
  }

  Future<void> _runPrediction() async {
    try {
      String soilType = profile?["soil"] ?? "Loamy";
      String irrigation = profile?["irrigation"] ?? "Rainfed";
      double landSize = double.tryParse(profile?["landSize"] ?? "1.0") ?? 1.0;

      double n = 80, p = 40, k = 40;
      if (soilType == "Sandy") { n = 20; p = 10; k = 10; }
      else if (soilType == "Clayey") { n = 40; p = 20; k = 20; }
      else if (soilType == "Black") { n = 50; p = 25; k = 25; }

      double finalRain = realRainfall + (irrigation == "Irrigated" ? 100 : 0);

      var priceIn = [[finalRain, realTemp, realHumidity]];
      var priceOut = List.filled(1, 0.0).reshape([1, 1]);
      priceInterpreter.run(priceIn, priceOut);
      double rawPriceFactor = priceOut[0][0]; 

      var yieldIn = [[n, p, k, realTemp, finalRain, realHumidity]];
      var yieldOut = List.filled(1, 0.0).reshape([1, 1]);
      yieldInterpreter.run(yieldIn, yieldOut);
      double rawYieldFactor = yieldOut[0][0];

      double basePrice = cropFactors[selectedCrop]!["basePrice"]!;
      double baseYield = cropFactors[selectedCrop]!["baseYield"]!;

      predictedPrice = basePrice * (1 + (rawPriceFactor % 0.15)); 
      double yieldPerHa = baseYield * (1 + (rawYieldFactor % 0.15));
      predictedYield = yieldPerHa / 2.47;
      
      

      double cost = 30000.0 * landSize;
      predictedProfit = (predictedPrice! * predictedYield! * landSize) - cost;

    } catch (e) {
      print("Prediction Error: $e");
    }
  }

  Future<void> _loadModels() async {
    priceInterpreter = await Interpreter.fromAsset('assets/model/price_model.tflite');
    yieldInterpreter = await Interpreter.fromAsset('assets/model/yield_model.tflite');
  }

  Future<void> _loadProfile() async {
    profile = await ProfileService(economics: EconomicsService()).loadProfile();
  }

  Future<void> _fetchRealWeather() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      final data = await WeatherService().getWeather(pos.latitude, pos.longitude);
      if (data['current_weather'] != null) realTemp = data['current_weather']['temperature'];
      realRainfall = 120.0; 
    } catch (e) {
      print("Weather Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔴 CHANGE 4: Initialize Provider
    final lang = Provider.of<LanguageProvider>(context);

    // Dynamic Y-Axis
    double minY = 0;
    double maxY = 100;
    if (prices.isNotEmpty) {
      minY = prices.reduce(min) * 0.95; 
      maxY = prices.reduce(max) * 1.05; 
    }

    // 🔴 CHANGE 5: Determine Trend UI based on status code
    bool isRising = trendStatus == 'rising';
    Color trendColor = isRising ? Colors.green : (trendStatus == 'falling' ? Colors.red : Colors.grey);
    String emoji = isRising ? "📈" : (trendStatus == 'falling' ? "📉" : "⚖️");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 🔴 CHANGE 6: Translate Title
        title: Text(lang.translate('market_insights')), 
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        foregroundColor: Colors.black
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CROP DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))]
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCrop, // Keeps internal English value
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  items: cropList.map((String crop) {
                    return DropdownMenuItem<String>(
                      value: crop,
                      child: Row(children: [
                        Icon(Icons.agriculture, size: 20, color: Colors.green.shade700),
                        const SizedBox(width: 10),
                        // 🔴 CHANGE 7: Translate Crop Name in UI
                        Text(lang.translate(crop)),
                      ]),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedCrop = newValue;
                        _updateCropData();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. LIVE PRICE & TREND
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // 🔴 CHANGE 8: Translate "Live Price"
                  Text("${lang.translate('live_price')} ($region)", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  loading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green))
                  : Text("₹${prices.last.toStringAsFixed(0)}", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: trendColor.withOpacity(0.3))
                  ),
                  // 🔴 CHANGE 9: Translate Trend Text (Rising/Falling)
                  child: Text(
                    "${lang.translate(trendStatus)} $emoji", 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: trendColor
                    )
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // 3. AI PREDICTION CARD
            if (predictedPrice != null && !loading) _buildPredictionCard(lang),

            const SizedBox(height: 32),

            // 4. PERFECT GRAPH
            // 🔴 CHANGE 10: Translate "Price History"
            Text(lang.translate('price_history'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            
            Container(
              height: 250,
              padding: const EdgeInsets.only(right: 16, top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: loading 
                ? const Center(child: CircularProgressIndicator(color: Colors.green)) 
                : LineChart(
                  LineChartData(
                    minY: minY, 
                    maxY: maxY, 
                    gridData: FlGridData(
                      show: true, 
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 == 0 && value >= 0 && value < 7) {
                              // 🔴 CHANGE 11: Translate Days of Week
                              // We use keys like 'mon', 'tue', etc.
                              List<String> days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
                              String dayKey = days[value.toInt()];
                              
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  lang.translate(dayKey),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(prices.length, (i) => FlSpot(i.toDouble(), prices[i])),
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: const Color(0xFF43A047),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: Colors.green);
                        }),
                        belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
                      ),
                    ],
                  ),
                ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // 🔴 CHANGE 12: Translate Header
            Text(lang.translate('ai_forecast'), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 11)),
            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ]),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔴 CHANGE 13: Translate Labels
              _infoColumn(lang.translate('est_price'), "₹${predictedPrice!.toStringAsFixed(0)}"),
              Container(width: 1, height: 40, color: Colors.white24),
              _infoColumn(lang.translate('est_yield'), "${predictedYield!.toStringAsFixed(1)} ${lang.translate('qtl_ha')}"),
              Container(width: 1, height: 40, color: Colors.white24),
              _infoColumn(lang.translate('net_profit'), "₹${predictedProfit!.toStringAsFixed(0)}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }
}