import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fpo_service.dart';

class MarketProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _offers = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get offers => _offers;
  bool get isLoading => _isLoading;

  MarketProvider() {
    // Automatically load data as soon as the app starts up
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. INSTANT OFFLINE LOAD: Grab the saved data from the phone's memory
    final cachedData = prefs.getString('cached_market_offers');
    if (cachedData != null) {
      List<dynamic> decoded = jsonDecode(cachedData);
      // Convert it back to the format our UI expects
      _offers = List<Map<String, dynamic>>.from(decoded);
      _isLoading = false;
      notifyListeners(); // Instantly draw the UI!
    }

    // 2. SILENT BACKGROUND UPDATE: Try to get fresh data from the Cloud
    try {
      final freshOffers = await FPOService().loadOffers();
      
      // Only update and re-draw if the cloud data is actually different/successful
      if (freshOffers.isNotEmpty || _offers.isEmpty) {
        _offers = freshOffers;
        
        // Save this fresh data into the local cache for the next time they go offline
        await prefs.setString('cached_market_offers', jsonEncode(freshOffers));
      }
    } catch (e) {
      print("No internet! Falling back to cached offline offers. Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}