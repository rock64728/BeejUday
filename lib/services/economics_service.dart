import 'dart:convert';
import 'package:http/http.dart' as http;

class EconomicsService {
  // 🔴 PASTE YOUR NEW NPOINT URL HERE
  final String _apiUrl = "https://api.npoint.io/bfa05963dde39534c615";

  // Stores all the crop data fetched from the internet
  Map<String, dynamic> _stats = {};

  // 1. Fetch Real Data
  Future<void> loadRealTimeData() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        _stats = json.decode(response.body);
        print("Live economics data loaded: ${_stats.length} crops found.");
      }
    } catch (e) {
      print("Failed to load live economics: $e");
      // Fallback data if internet fails
      _stats = {
        "mustard": { "price": 5650.0, "yield": 16.0, "cost": 30000.0, "name": "Mustard" },
        "wheat": { "price": 2275.0, "yield": 35.0, "cost": 34000.0, "name": "Wheat" }
      };
    }
  }

  // 2. Get list of all available crop keys (e.g., "mustard", "paddy_common")
  List<String> getAvailableCrops() {
    return _stats.keys.toList();
  }

  // 3. Calculate Logic (Now accepts Acres)
  Map<String, dynamic> calculate(String cropKey, double landSizeInAcres) {
    // Get data safely
    final data = _stats[cropKey];
    if (data == null) return {};

    final double price = (data["price"] as num).toDouble();
    
    // API Data is usually per Hectare
    final double yieldPerHa = (data["yield"] as num).toDouble(); 
    final double costPerHa = (data["cost"] as num).toDouble(); 
    final String readableName = data["name"] ?? cropKey;

    // 🔴 CRITICAL STEP: Convert Acres to Hectares for the Math
    // 1 Acre = 0.4047 Hectares
    // We must do this because the yieldPerHa and costPerHa are based on Hectares.
    final double equivalentHectares = landSizeInAcres * 0.4047;

    // Calculate Totals using the converted Hectares
    final totalYield = yieldPerHa * equivalentHectares;
    final totalRevenue = totalYield * price;
    final totalCost = costPerHa * equivalentHectares;
    final netProfit = totalRevenue - totalCost;

    return {
      "name": readableName,
      "yield": double.parse(totalYield.toStringAsFixed(1)), // Total Yield in Quintals
      "revenue": double.parse(totalRevenue.toStringAsFixed(0)),
      "cost": double.parse(totalCost.toStringAsFixed(0)),
      "profit": double.parse(netProfit.toStringAsFixed(0)),
      "price": price,
      "acres": landSizeInAcres // Sending back the acres for reference if needed
    };
  }
}