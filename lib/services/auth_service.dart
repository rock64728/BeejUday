import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  Future<bool> register(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = prefs.getString("users");
    List users = userData != null ? json.decode(userData) : [];

    bool exists = users.any((u) => u["email"] == email);
    if (exists) return false;

    users.add({"email": email, "password": password});
    await prefs.setString("users", json.encode(users));
    await prefs.setString("logged_in_user", email);

    return true;
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString("users");

    if (userData == null) return false;

    List users = json.decode(userData);

    bool match = users.any(
      (u) => u["email"] == email && u["password"] == password,
    );

    if (match) {
      await prefs.setString("logged_in_user", email);
    }

    return match;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("logged_in_user") != null;
  }

  Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("logged_in_user");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("logged_in_user");
  }
}
