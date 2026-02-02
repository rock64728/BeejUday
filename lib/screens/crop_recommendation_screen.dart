import 'package:beeju_day/services/economics_service.dart';
import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../services/profile_service.dart';
import '../services/weather_service.dart';
import '../services/gemini_service.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  late Interpreter cropModel;
  bool loading = true;
  
  // 🔴 CHANGE 1: We store translation KEYS here, not final text
  String statusMessage = "initializing"; 
  
  // Data Holders
  Map<String, dynamic>? profile;
  Map<String, dynamic>? weatherData;
  _CropScore? best;
  List<_CropScore> scores = [];
  String aiReasoning = "analyzing"; // Key for translation

  // Real-time variables
  double realTemp = 30.0;
  double realHumidity = 70.0;
  double estimatedRainfall = 100.0;

  final List<String> cropNames = [
    'Bajra', 'Barley', 'Cotton(lint)', 'Groundnut', 'Maize', 
    'Rice', 'Sesamum', 'Sugarcane', 'Tobacco', 'Wheat'
  ];

  @override
  void initState() {
    super.initState();
    // We delay execution slightly so 'context' is ready for Provider if needed
    WidgetsBinding.instance.addPostFrameCallback((_) => _fullWorkflow());
  }

  Future<void> _fullWorkflow() async {
    try {
      // 1. Load Profile
      setState(() => statusMessage = "loading_profile");
      profile = await ProfileService(economics: EconomicsService()).loadProfile();

      // 2. Load Model
      setState(() => statusMessage = "loading_model");
      cropModel = await Interpreter.fromAsset("assets/model/crop_recommendation.tflite");

      // 3. Get Real Location & Weather
      setState(() => statusMessage = "fetching_weather");
      await _fetchRealWeather();

      // 4. Run ML Prediction
      setState(() => statusMessage = "running_prediction");
      _calculateScores();

      // 5. Ask Gemini "Why?"
      if (best != null) {
        setState(() => statusMessage = "generating_insights");
        String soil = profile?["soil"] ?? "Loamy";
        
        // Pass language code ('en', 'hi', 'gu') to Gemini
        aiReasoning = await GeminiService().getExplanation(
          best!.name, 
          soil, 
          realTemp, 
          estimatedRainfall,
          Provider.of<LanguageProvider>(context, listen: false).currentLanguage 
        );
      }

    } catch (e) {
      print("Workflow Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _fetchRealWeather() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      final data = await WeatherService().getWeather(position.latitude, position.longitude);
      
      if (data['current_weather'] != null) {
        realTemp = data['current_weather']['temperature'];
      }
      
      if (data['daily'] != null && data['daily']['precipitation_probability_max'] != null) {
        List probs = data['daily']['precipitation_probability_max'];
        double prob = (probs.isNotEmpty ? probs[0] : 0).toDouble();

        if (prob < 20) estimatedRainfall = 50.0; 
        else if (prob < 60) estimatedRainfall = 120.0;
        else estimatedRainfall = 200.0; 
      }
    } catch (e) {
      print("Location/Weather failed, using defaults: $e");
    }
  }

  void _calculateScores() {
    String soilType = profile?["soil"] ?? "Loamy"; 
    String irrigation = profile?["irrigation"] ?? "Rainfed"; 

    double n = 80, p = 40, k = 40; 
    if (soilType == "Sandy") { n = 20; p = 10; k = 10; }
    else if (soilType == "Clayey") { n = 40; p = 20; k = 20; }
    else if (soilType == "Black") { n = 50; p = 25; k = 25; }
    else if (soilType == "Red") { n = 30; p = 15; k = 15; }

    double finalRain = estimatedRainfall;
    if (irrigation == "Irrigated") {
      finalRain += 80.0; 
    }

    List<double> input = [n, p, k, realTemp, realHumidity, finalRain];
    var output = List.filled(cropNames.length, 0.0).reshape([1, cropNames.length]);
    cropModel.run([input], output);

    List<double> probabilities = output[0];
    scores = [];
    for (int i = 0; i < probabilities.length; i++) {
        scores.add(_CropScore(cropNames[i], probabilities[i] * 100));
    }
    scores.sort((a, b) => b.score.compareTo(a.score));
    if (scores.isNotEmpty) best = scores.first;
  }

  @override
  Widget build(BuildContext context) {
    // 🔴 CHANGE 2: Initialize Provider
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 🔴 CHANGE 3: Translate Title
        title: Text(lang.translate('ai_recommendation'), 
            style: const TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.orange), onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.orange),
                  const SizedBox(height: 16),
                  // 🔴 CHANGE 4: Translate Status Message
                  Text(lang.translate(statusMessage), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weather Badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                            // 🔴 CHANGE 5: Translate Analysis Text (constructed string)
                            child: Text(
                                "${lang.translate('analysis_based_on_location')}:\n"
                                "${lang.translate('temp')}: ${realTemp.toStringAsFixed(1)}°C | "
                                "${lang.translate('rain_est')}: ${estimatedRainfall.toInt()}mm", 
                                style: const TextStyle(fontSize: 12)
                            )
                        ),
                      ],
                    ),
                  ),

                  if (best != null) _buildBestCard(best!, lang),
                  const SizedBox(height: 20),
                  
                  if (best != null) _buildReasoningCard(lang),

                  const SizedBox(height: 20),
                  // 🔴 CHANGE 6: Translate Ranking Title
                  Text(lang.translate('ranking_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildRankingList(lang),
                ],
              ),
            ),
    );
  }

  // Pass 'lang' to child widgets
  Widget _buildBestCard(_CropScore best, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF66BB6A)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          // 🔴 CHANGE 7: Translate 'Best Crop' Label
          Text(lang.translate('best_crop_label'), style: const TextStyle(color: Colors.white70, letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // 🔴 CHANGE 8: Translate The Dynamic Crop Name (e.g., 'Wheat' -> 'गेहूँ')
          Text(lang.translate(best.name), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          // 🔴 CHANGE 9: Translate Suitability
          Text("${best.score.toStringAsFixed(1)}% ${lang.translate('suitability')}", style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildReasoningCard(LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              // 🔴 CHANGE 10: Translate 'Why this crop?'
              Text(lang.translate('why_this_crop'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ],
          ),
          const SizedBox(height: 8),
          // AI Reasoning comes from Gemini already translated, or we translate the 'analyzing' placeholder
          Text(aiReasoning == "analyzing" ? lang.translate('analyzing') : aiReasoning, 
              style: const TextStyle(fontSize: 13, height: 1.4, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildRankingList(LanguageProvider lang) {
    return Column(
      children: scores.asMap().entries.map((entry) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade50,
              child: Text("${entry.key + 1}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
            // 🔴 CHANGE 11: Translate Crop Name in List
            title: Text(lang.translate(entry.value.name), style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text("${entry.value.score.toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }
}

class _CropScore {
  final String name;
  final double score;
  _CropScore(this.name, this.score);
}