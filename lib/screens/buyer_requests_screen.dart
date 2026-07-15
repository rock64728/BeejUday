import 'package:flutter/material.dart';
import '../services/fpo_service.dart'; // Import Service

class BuyerRequestsScreen extends StatefulWidget {
  const BuyerRequestsScreen({super.key});

  @override
  State<BuyerRequestsScreen> createState() => _BuyerRequestsScreenState();
}

class _BuyerRequestsScreenState extends State<BuyerRequestsScreen> {
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final cloudRequests = await FPOService().getRequestsForBuyer();
    if (mounted) {
      setState(() {
        requests = cloudRequests;
      });
    }
  }

  Future<void> _accept(String id) async {
    await FPOService().acceptRequest(id);
    await _loadRequests(); // Refresh UI directly from cloud
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Accepted!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Farmer Requests"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: requests.isEmpty 
        ? const Center(child: Text("No requests from farmers yet."))
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildRequestCard(requests[index]);
            },
          ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE1BEE7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _infoRow("Farmer's Name", req['farmer']),
          _infoRow("Price", req['price']),
          _infoRow("Crop", req['crop']),
          _infoRow("Quantity", req['qty']),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _actionButton("Accept", const Color(0xFFFFCC4D), () => _accept(req['request_id']))),
              const SizedBox(width: 10),
              Expanded(child: _actionButton("Decline", const Color(0xFFFFCC4D), () {})),
            ],
          )
        ],
      ),
    );
  }
  
  // ... _infoRow and _actionButton helper widgets remain same ...
    Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(width: 1.5)),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}