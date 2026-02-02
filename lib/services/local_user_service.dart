import 'package:shared_preferences/shared_preferences.dart';

class LocalUserService {
  Future<void> saveUser(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_name", name);
    await prefs.setString("user_email", email);
    await prefs.setBool("signed_up", true);
  }

  Future<bool> isSignedUp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("signed_up") ?? false;
  }

  Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString("user_name"),
      "email": prefs.getString("user_email"),
    };
  }
}
