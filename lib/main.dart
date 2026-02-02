import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/language_provider.dart';
import 'services/economics_service.dart';
import 'screens/language_screen.dart'; // Import your Language Screen

void main() {
  // 1. Create the Service once at the top level
  final economicsService = EconomicsService();

  runApp(
    MultiProvider(
      providers: [
        // Register the Language Provider so it works everywhere
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MyApp(economics: economicsService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final EconomicsService economics;
  const MyApp({super.key, required this.economics});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeejuDay',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // 🔴 FIX: Set LanguageScreen as the starting point
      home: LanguageScreen(economics: economics),
    );
  }
}