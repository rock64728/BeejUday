import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Access the global Supabase client
  final supabase = Supabase.instance.client;

  // 🔴 UPDATED: Cloud Registration with Role
  Future<bool> register(String name, String email, String password, {String role = 'farmer'}) async {
    try {
      // 1. Create secure Auth User in Supabase
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final User? user = res.user;
      if (user == null) return false;

      // 2. Assign their Role in the database
      await supabase.from('user_roles').insert({
        'id': user.id,
        'role': role,
      });

      // 3. Create their Cloud Profile based on their role
      if (role == 'farmer') {
        await supabase.from('farmer_profiles').insert({
          'id': user.id,
          'full_name': name,
          'land_size_acres': 1.5 // Setting a default
        });
      } else if (role == 'buyer') {
        await supabase.from('buyer_profiles').insert({
          'id': user.id,
          'company_name': name,
        });
      }

      // Keep this for legacy compatibility in your app for now
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("logged_in_user", email);

      return true;
    } catch (e) {
      print("Cloud Registration Error: $e");
      return false;
    }
  }

  // 🔴 UPDATED: Cloud Login
  Future<bool> login(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (res.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("logged_in_user", email);
        return true;
      }
      return false;
    } catch (e) {
      print("Cloud Login Error: $e");
      return false;
    }
  }

  // 🔴 UPDATED: Supabase automatically securely manages the session!
  Future<bool> isLoggedIn() async {
    return supabase.auth.currentSession != null;
  }

  Future<String?> getLoggedInUser() async {
    return supabase.auth.currentUser?.email;
  }

  Future<void> logout() async {
    await supabase.auth.signOut(); // Securely ends the cloud session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("logged_in_user");
  }
}