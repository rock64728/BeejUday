import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/economics_service.dart';
import '../services/profile_service.dart';

class ProfitsScreen extends StatefulWidget {
  final EconomicsService economics;

  const ProfitsScreen({super.key, required this.economics});

  @override
  State<ProfitsScreen> createState() => _ProfitsScreenState();
}

class _ProfitsScreenState extends State<ProfitsScreen> {
  // --- LOGIC PRESERVED ---
  double hectares = 1.0;
  bool isLoading = true;
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    _loadProfileAndCalculate();
  }

  Future<void> _loadProfileAndCalculate() async {
    final profile = await ProfileService(economics: EconomicsService()).getProfile();
    if (profile != null && profile["landSize"] != null) {
      hectares = double.tryParse(profile["landSize"].toString()) ?? 1.0;
    }

    await widget.economics.loadRealTimeData();

    _runCalculation(); 

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _runCalculation() {
    final cropKeys = widget.economics.getAvailableCrops();
    
    results = cropKeys.map((key) {
      final data = widget.economics.calculate(key, hectares);
      data["key"] = key; 
      return data;
    }).toList();

    results.sort((a, b) => b["profit"].compareTo(a["profit"]));
  }
  // -----------------------

  @override
  Widget build(BuildContext context) {
    // 🔴 CHANGE 1: Initialize Provider
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        // 🔴 CHANGE 2: Translate Header
        title: Text(
          lang.translate('crop_economics'),
          style: const TextStyle(
            color: Color(0xFF6A1B9A), 
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Land Size Slider Section
                  // 🔴 CHANGE 3: Translate Label
                  Text(
                    "${lang.translate('land_size')}: ${hectares.toStringAsFixed(1)} ${lang.translate('ha')}",
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                    ),
                  ),
                  const SizedBox(height: 5),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.orange,
                      thumbColor: Colors.orange,
                      inactiveTrackColor: Colors.orange.withOpacity(0.2),
                      trackHeight: 4.0,
                    ),
                    child: Slider(
                      value: hectares,
                      min: 0.5,
                      max: 10,
                      divisions: 95,
                      label: "${hectares.toStringAsFixed(1)} ha",
                      onChanged: (value) {
                        setState(() {
                          hectares = value;
                          _runCalculation();
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // "Winner" Card
                  if (results.isNotEmpty) _buildWinnerCard(results.first, lang),

                  const SizedBox(height: 25),
                  
                  // Comparison List Header
                  // 🔴 CHANGE 4: Translate Header
                  Text(
                    lang.translate('all_crops_comparison'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // List of crops
                  Expanded(
                    child: ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        return _buildCropCard(results[i], lang, isWinner: i == 0);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Special Card for the Highest Profit
  // 🔴 CHANGE 5: Pass lang to helper
  Widget _buildWinnerCard(Map<String, dynamic> data, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFCC4D), Colors.orange.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              // 🔴 CHANGE 6: Translate 'Highest Profit'
              Text(
                lang.translate('highest_profit').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 🔴 CHANGE 7: Translate Crop Name (e.g., 'Wheat' -> 'गेहूँ')
          Text(
            lang.translate(data['name'] ?? ""),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "₹${data['profit'].toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          // 🔴 CHANGE 8: Translate 'Net Profit'
          Text(
            lang.translate('net_profit'),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Standard Card for List items
  // 🔴 CHANGE 9: Pass lang to helper
  Widget _buildCropCard(Map<String, dynamic> data, LanguageProvider lang, {bool isWinner = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isWinner 
            ? Border.all(color: Colors.orange, width: 2) 
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row: Name + Profit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔴 CHANGE 10: Translate Crop Name
              Text(
                lang.translate(data['name'] ?? ""),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "₹${data['profit'].toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          // Details Row
          // 🔴 CHANGE 11: Translate Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(lang.translate('revenue'), "₹${data['revenue']}"),
              _buildDetailItem(lang.translate('cost'), "₹${data['cost']}"),
              _buildDetailItem(lang.translate('yield'), "${data['yield']} ${lang.translate('qtl')}"),
              _buildDetailItem(lang.translate('price'), "₹${data['price']}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}