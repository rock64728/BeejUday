import 'dart:convert';
import 'package:beeju_day/services/economics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // 🔴 FIX: Removed 'required EconomicsService' to make it simple
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService({required EconomicsService economics}) => _instance;
  ProfileService._internal();

  Future<void> saveProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_profile', json.encode(data));
  }

  Future<Map<String, dynamic>?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('farmer_profile');
    if (raw == null) return null;
    return json.decode(raw);
  }

  Future<Map<String, dynamic>?> getProfile() => loadProfile();

  Future<void> updateValue(String key, dynamic value) async {
    final profile = await loadProfile() ?? {};
    profile[key] = value;
    await saveProfile(profile);
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('farmer_profile');
  }
}