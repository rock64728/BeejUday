import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  // 🔴 UPDATED: Added 'name' parameter
  Future<bool> register(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = prefs.getString("users");
    List users = userData != null ? json.decode(userData) : [];

    bool exists = users.any((u) => u["email"] == email);
    if (exists) return false;

    // 🔴 UPDATED: Saving 'name' to the user object
    users.add({
      "name": name, 
      "email": email, 
      "password": password,
      "role": "farmer" // Default role
    });
    
    await prefs.setString("users", json.encode(users));
    await prefs.setString("logged_in_user", email);
    
    // 🔴 UPDATED: Also save specifically to 'farmer_profile' for the Dashboard to find easily
    // This bridges the gap between Auth and Profile Service
    await prefs.setString('farmer_profile', json.encode({
      "name": name,
      "email": email,
      "landSize": "1.5"
    }));

    return true;
  }

  // ... (Login logic remains same) ...
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString("users");
    if (userData == null) return false;

    List users = json.decode(userData);
    var user = users.firstWhere(
      (u) => u["email"] == email && u["password"] == password,
      orElse: () => null,
    );

    if (user != null) {
      await prefs.setString("logged_in_user", email);
      // Optional: Update profile with logged-in user's name if missing
      return true;
    }
    return false;
  }

  // ... (Rest of the file remains same) ...
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("logged_in_user") != null;
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("logged_in_user");
  }
}