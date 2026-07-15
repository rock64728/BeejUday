import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beeju_day/services/economics_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService({EconomicsService? economics}) => _instance;
  ProfileService._internal();

  // Access Supabase securely
  final supabase = Supabase.instance.client;

  // 🔴 UPDATED: Save directly to the Cloud Database
  Future<void> saveProfile(Map<String, dynamic> data) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Map the UI keys to your exact Database column names
    final Map<String, dynamic> dbData = {};
    if (data.containsKey('name')) dbData['full_name'] = data['name'];
    if (data.containsKey('village')) dbData['village'] = data['village'];
    if (data.containsKey('state')) dbData['state'] = data['state'];
    if (data.containsKey('landSize')) {
      dbData['land_size_acres'] = double.tryParse(data['landSize'].toString()) ?? 1.5;
    }
    if (data.containsKey('soil')) dbData['soil_type'] = data['soil'];
    if (data.containsKey('irrigation')) dbData['irrigation_type'] = data['irrigation'];
    if (data.containsKey('experience')) dbData['experience_level'] = data['experience'];

    try {
      // Update the existing row that was created during the signup step
      await supabase.from('farmer_profiles').update(dbData).eq('id', user.id);
    } catch (e) {
      print("Error saving profile to cloud: $e");
    }
  }

  // 🔴 UPDATED: Fetch directly from the Cloud Database
  Future<Map<String, dynamic>?> loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await supabase.from('farmer_profiles').select().eq('id', user.id).single();
      
      // Map Database columns back to UI keys so the rest of your app works perfectly!
      return {
        "name": response['full_name'],
        "village": response['village'] ?? "",
        "state": response['state'] ?? "",
        "landSize": response['land_size_acres']?.toString() ?? "1.5",
        "soil": response['soil_type'] ?? "Loamy",
        "irrigation": response['irrigation_type'] ?? "Rainfed",
        "experience": response['experience_level'] ?? "Beginner",
      };
    } catch (e) {
      print("Error loading profile from cloud: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile() => loadProfile();

  Future<void> updateValue(String key, dynamic value) async {
    final profile = await loadProfile() ?? {};
    profile[key] = value;
    await saveProfile(profile);
  }

  Future<void> clearProfile() async {
    // We no longer need to clear local storage manually, Auth logout handles session clearing.
  }
}