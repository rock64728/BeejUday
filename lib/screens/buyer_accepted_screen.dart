import 'package:flutter/material.dart';
import '../services/fpo_service.dart';

class BuyerAcceptedScreen extends StatefulWidget {
  const BuyerAcceptedScreen({super.key});

  @override
  State<BuyerAcceptedScreen> createState() => _BuyerAcceptedScreenState();
}

class _BuyerAcceptedScreenState extends State<BuyerAcceptedScreen> {
  List<Map<String, dynamic>> deals = [];
  bool isLoading = true; // 🔴 ADDED: Loading state

  @override
  void initState() {
    super.initState();
    _loadDeals(); // 🔴 FIX: Call the async function
  }

  // 🔴 FIX: Made this an async function to wait for the cloud
  Future<void> _loadDeals() async {
    final acceptedDeals = await FPOService().getAcceptedDeals();
    if (mounted) {
      setState(() {
        deals = acceptedDeals;
        isLoading = false; // Turn off loading spinner
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Accepted Requests"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green)) // Show spinner while loading
        : deals.isEmpty 
        ? const Center(child: Text("No accepted deals yet."))
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
                  title: Text(deal['farmer'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${deal['crop']} • ${deal['qty']} @ ${deal['price']}"),
                ),
              );
            },
          ),
    );
  }
}