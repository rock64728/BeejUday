import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔴 ADDED
import 'package:firebase_messaging/firebase_messaging.dart'; // 🔴 ADDED
import 'firebase_options.dart'; // 🔴 ADDED

import 'services/language_provider.dart';
import 'services/economics_service.dart';
import 'services/market_provider.dart';
import 'screens/language_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// 🔴 ADDED: This MUST be a top-level function. It wakes up the app when closed.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Background message received: ${message.messageId}");
}

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔴 ADDED: Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔴 ADDED: Register the background listener
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://kbuwbeysbxlnnbnjwatf.supabase.co', // Keep your actual keys here!
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtidXdiZXlzYnhsbm5ibmp3YXRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3MzA2NjYsImV4cCI6MjA4ODMwNjY2Nn0.-Ga8UNRcS_zKZkbnW7UK-kX6GLXwiHeUHUrrpn4U768',
  );

  final economicsService = EconomicsService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
      ],
      child: MyApp(economics: economicsService),
    ),
  );
}

class MyApp extends StatefulWidget {
  final EconomicsService economics;
  const MyApp({super.key, required this.economics});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState() {
    super.initState();
    _setupNotifications(); // 🔴 ADDED: Ask for permission when app starts
  }

  // 🔴 ADDED: Setup Notification Permissions & Get Token
  Future<void> _setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      print('🔥 THIS DEVICE FCM TOKEN: $token');
      
      // 🔴 NEW LOGIC: Save the token to Supabase if the user is logged in!
      final user = supabase.auth.currentUser;
      if (user != null && token != null) {
        try {
          await supabase.from('user_roles').update({
            'fcm_token': token
          }).eq('id', user.id);
          print("✅ FCM Token saved securely to Cloud!");
        } catch (e) {
          print("Failed to save token to cloud: $e");
        }
      }
      
      // Listen for token refreshes (in case the device changes its token)
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (user != null) {
          await supabase.from('user_roles').update({'fcm_token': newToken}).eq('id', user.id);
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("🔔 FOREGROUND NOTIFICATION: ${message.notification?.title}");
        
        if (message.notification != null) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text("${message.notification!.title} - ${message.notification!.body}"),
              backgroundColor: Colors.blue.shade800,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20), // Standard bottom banner
            ),
          );
        }
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'BeejuDay',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: LanguageScreen(economics: widget.economics),
    );
  }
}