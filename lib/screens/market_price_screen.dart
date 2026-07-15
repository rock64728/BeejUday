import 'dart:convert';
import 'dart:math'; // Required for exp() logic
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../services/profile_service.dart';
import '../services/weather_service.dart';
import 'package:beeju_day/services/economics_service.dart';
import 'package:beeju_day/services/language_provider.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  bool loading = true;
  String statusMessage = "loading_market_data";

  // 1. CROP SELECTION
  String selectedCrop = "Mustard";
  final List<String> cropList = [
    "Mustard", "Wheat", "Rice", "Maize", "Cotton", 
    "Groundnut", "Sugarcane", "Bajra", "Soybean", "Jeera"
  ];

  // 2. REALISTIC DATA FACTORS (Fallback)
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

  // 🟢 NEW: Scientific NPK Standards (For Yield Input)
  // Used if we don't have real soil test data
  final Map<String, Map<String, double>> cropStandards = {
    'Wheat':     {'N': 60, 'P': 30, 'K': 30},
    'Rice':      {'N': 80, 'P': 40, 'K': 40},
    'Maize':     {'N': 70, 'P': 35, 'K': 30},
    'Cotton':    {'N': 90, 'P': 45, 'K': 45},
    'Sugarcane': {'N': 120,'P': 50, 'K': 50},
    'Mustard':   {'N': 50, 'P': 25, 'K': 20},
    'Soybean':   {'N': 40, 'P': 60, 'K': 40},
    'Groundnut': {'N': 20, 'P': 50, 'K': 40},
    'Bajra':     {'N': 40, 'P': 20, 'K': 20},
    'Jeera':     {'N': 30, 'P': 20, 'K': 15},
  };

  // Data variables
  List<double> prices = [];
  String region = "Gujarat"; 
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

  // 🟢 AI VARIABLES (Price Model)
  late Interpreter marketModelInterpreter;
  Map<String, dynamic>? encoders;
  Map<String, dynamic>? scaler;
  
  // 🟢 AI VARIABLES (Yield Model)
  late Interpreter yieldModelInterpreter;
  Map<String, dynamic>? yieldEncoders;
  Map<String, dynamic>? yieldScaler;

  bool isModelLoaded = false;

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

  // 🟢 UPDATED: Load BOTH Models
  Future<void> _loadModels() async {
    try {
      // 1. PRICE MODEL FILES
      marketModelInterpreter = await Interpreter.fromAsset('assets/model/final_market_model_v2.tflite');
      String encoderString = await rootBundle.loadString('assets/model/encoders.json');
      encoders = json.decode(encoderString);
      String scalerString = await rootBundle.loadString('assets/model/scaler.json');
      scaler = json.decode(scalerString);

      // 2. YIELD MODEL FILES
      yieldModelInterpreter = await Interpreter.fromAsset('assets/model/final_yield_model.tflite');
      String yieldEncoderString = await rootBundle.loadString('assets/model/yield_encoders.json');
      yieldEncoders = json.decode(yieldEncoderString);
      String yieldScalerString = await rootBundle.loadString('assets/model/yield_scaler.json');
      yieldScaler = json.decode(yieldScalerString);

      setState(() {
        isModelLoaded = true;
      });
      print("✅ AI Models Loaded Successfully");
    } catch (e) {
      print("❌ Error loading AI models: $e");
    }
  }

  Future<void> _loadProfile() async {
    profile = await ProfileService(economics: EconomicsService()).loadProfile();
    if (profile != null && profile!.containsKey('state')) {
      setState(() {
        region = profile!['state'];
      });
    }
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

  void _updateCropData() {
    setState(() => loading = true);
    _generateGraphData(); 
    _runPrediction();     
    
    // Update Trend
    if (prices.isNotEmpty && prices.length > 1) {
      double current = prices.last;
      double prev = prices[prices.length - 2];
      
      if (current > prev) trendStatus = "rising";
      else if (current < prev) trendStatus = "falling";
      else trendStatus = "stable";
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => loading = false);
    });
  }

  void _generateGraphData() {
    double base = cropFactors[selectedCrop]?["basePrice"] ?? 2000.0;
    Random random = Random();
    
    prices = [];
    for (int i = 0; i < 7; i++) {
      double variation = (random.nextDouble() * 0.08) - 0.04; // +/- 4%
      prices.add(base + (base * variation));
    }
  }

  // 🟢 CORE PREDICTION LOGIC
  Future<void> _runPrediction() async {
    if (!isModelLoaded || encoders == null || scaler == null || yieldEncoders == null || yieldScaler == null) {
      print("⚠️ AI Models not ready.");
      return;
    }

    try {
      // COMMON INPUTS
      String state = profile?["state"] ?? "Gujarat";
      String district = profile?["district"] ?? "Ahmedabad";
      String market = "Bavla"; 
      String commodity = selectedCrop;
      
      // ===========================
      // 1. PRICE PREDICTION
      // ===========================
      DateTime now = DateTime.now();
      double valState = _encode(encoders!, 'State', state);
      double valDistrict = _encode(encoders!, 'District Name', district);
      double valMarket = _encode(encoders!, 'Market Name', market);
      double valCommodity = _encode(encoders!, 'Commodity', commodity);
      double valVariety = _encode(encoders!, 'Variety', 'Other');
      double valGrade = _encode(encoders!, 'Grade', 'FAQ');
      double valMonth = now.month.toDouble();
      double valYear = now.year.toDouble(); 

      List<double> rawPriceInput = [
        valState, valDistrict, valMarket, valCommodity, 
        valVariety, valGrade, valMonth, valYear
      ];

      // Scale Price Inputs
      List<dynamic> priceMean = scaler!['mean'];
      List<dynamic> priceScale = scaler!['scale'];
      List<double> scaledPriceInput = [];
      for (int i = 0; i < rawPriceInput.length; i++) {
        scaledPriceInput.add((rawPriceInput[i] - priceMean[i]) / priceScale[i]);
      }

      var priceInputTensor = [scaledPriceInput]; 
      var priceOutputTensor = List.filled(1, [0.0]).reshape([1, 1]);

      marketModelInterpreter.run(priceInputTensor, priceOutputTensor);
      double aiPrice = priceOutputTensor[0][0];

      // ===========================
      // 2. YIELD PREDICTION (NEW)
      // ===========================
      // Encode Inputs (Note: 'District ' has a space in Yield logic)
      double valStateYield = _encode(yieldEncoders!, 'State', state);
      double valDistrictYield = _encode(yieldEncoders!, 'District ', district); 
      double valCropYield = _encode(yieldEncoders!, 'Crop_Label', commodity);

      // Get NPK (Use defaults if we don't have sensors yet)
      Map<String, double> standards = cropStandards[selectedCrop] ?? {'N':50, 'P':25, 'K':20};
      double inputN = standards['N']!;
      double inputP = standards['P']!;
      double inputK = standards['K']!;
      double inputTemp = realTemp;
      double inputRain = 120.0; // Or realRainfall
      double inputPH = 6.5; 

      List<double> rawYieldInput = [
        valStateYield, valDistrictYield, valCropYield,
        inputN, inputP, inputK, inputTemp, inputRain, inputPH
      ];

      // Scale Yield Inputs
      List<dynamic> yieldMean = yieldScaler!['mean'];
      List<dynamic> yieldScale = yieldScaler!['scale'];
      List<double> scaledYieldInput = [];
      for (int i = 0; i < rawYieldInput.length; i++) {
        scaledYieldInput.add((rawYieldInput[i] - yieldMean[i]) / yieldScale[i]);
      }

      var yieldInputTensor = [scaledYieldInput];
      var yieldOutputTensor = List.filled(1, [0.0]).reshape([1, 1]);

      yieldModelInterpreter.run(yieldInputTensor, yieldOutputTensor);

      // REVERSE LOG (Math: exp(output) - 1)
      double logYield = yieldOutputTensor[0][0];
      double realYieldTonnes = exp(logYield) - 1;
      if (realYieldTonnes < 0) realYieldTonnes = 0;

      // CONVERT TO QUINTALS (1 Tonne = 10 Quintals)
      // We do this because your UI says 'qtl_ha' and Price is per Quintal
      double realYieldQuintals = realYieldTonnes * 10;

      setState(() {
        predictedPrice = aiPrice;
        predictedYield = realYieldQuintals; 
        
        // ===========================
        // 3. PROFIT CALCULATION (UNCHANGED LOGIC)
        // ===========================
        double landSize = double.tryParse(profile?["landSize"] ?? "1.0") ?? 1.0;
        double costOfCultivation = 25000 * landSize;
        
        // This formula remains exactly as you had it
        predictedProfit = (predictedPrice! * predictedYield! * landSize) - costOfCultivation;
      });

      print("🔮 Predicted: $commodity | Price: ₹$predictedPrice | Yield: $predictedYield qtl/ha");

    } catch (e) {
      print("❌ Prediction Logic Error: $e");
    }
  }

  // Generic helper for encoding (Works for both Price and Yield maps)
  double _encode(Map<String, dynamic> encoderMap, String category, String value) {
    // Handle "District " vs "District" key differences automatically
    if (!encoderMap.containsKey(category)) {
      if (encoderMap.containsKey("$category ")) category = "$category "; // Try adding space
      else if (encoderMap.containsKey(category.trim())) category = category.trim(); // Try trimming
      else return 0.0;
    }

    var categoryMap = encoderMap[category];
    if (categoryMap == null) return 0.0;

    // Try exact match
    if (categoryMap.containsKey(value)) return categoryMap[value].toDouble();
    
    // Try Title Case (e.g. "ahmedabad" -> "Ahmedabad")
    if (value.isNotEmpty) {
      String titleCase = value[0].toUpperCase() + value.substring(1).toLowerCase();
      if (categoryMap.containsKey(titleCase)) return categoryMap[titleCase].toDouble();
    }
    
    return 0.0; 
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    // Dynamic Y-Axis
    double minY = 0;
    double maxY = 100;
    if (prices.isNotEmpty) {
      minY = prices.reduce(min) * 0.95; 
      maxY = prices.reduce(max) * 1.05; 
    }

    bool isRising = trendStatus == 'rising';
    Color trendColor = isRising ? Colors.green : (trendStatus == 'falling' ? Colors.red : Colors.grey);
    String emoji = isRising ? "📈" : (trendStatus == 'falling' ? "📉" : "⚖️");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                  value: selectedCrop,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  items: cropList.map((String crop) {
                    return DropdownMenuItem<String>(
                      value: crop,
                      child: Row(children: [
                        Icon(Icons.agriculture, size: 20, color: Colors.green.shade700),
                        const SizedBox(width: 10),
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
                  Text("${lang.translate('live_price')} ($region)", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  loading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green))
                  : Text("₹${prices.isNotEmpty ? prices.last.toStringAsFixed(0) : '0'}", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: trendColor.withOpacity(0.3))
                  ),
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

            // 4. GRAPH
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
            Text(lang.translate('ai_forecast'), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 11)),
            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ]),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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