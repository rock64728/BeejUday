import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fpo_service.dart';
import 'fpo_offer_detail_screen.dart';

class FPOProcurementScreen extends StatefulWidget {
  const FPOProcurementScreen({super.key});

  @override
  State<FPOProcurementScreen> createState() => _FPOProcurementScreenState();
}

class _FPOProcurementScreenState extends State<FPOProcurementScreen> {
  bool loading = true;
  List<Map<String, dynamic>> offers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    offers = await FPOService().loadOffers();
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang.translate('fpo_offers'),
          style: const TextStyle(
            color: Color(0xFF6A1B9A), 
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                final o = offers[i];
                return _buildOfferCard(o, lang);
              },
            ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> o, LanguageProvider lang) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FPOOfferDetailScreen(offer: o),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            // Top Row: Icon + Details + Price
            Row(
              children: [
                // Icon Section
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                
                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o['fpo_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lang.translate(o['crop']),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${lang.translate('valid_till')}: ${o['valid_till']}",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),

                // Price Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), 
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "₹${o['price_per_qtl']}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "/ ${lang.translate('qtl')}",
                        style: const TextStyle(fontSize: 10, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 🔴 NEW: Sell Now Button (Triggers API logic you requested)
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                onPressed: () async {
                  // 1. Show Loading feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sending interest..."), duration: Duration(seconds: 1)),
                  );

                  // 2. Call Service (Your Logic Here)
                  await FPOService().sendInterest(
                    o["id"], 
                    "Rahul Farmer", // Replace with dynamic name if stored in Profile
                    double.tryParse(o["min_qtl"].toString()) ?? 10
                  );

                  // 3. Show Success Message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Interest sent to ${o["fpo_name"]}!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text(
                  lang.translate('sell_now'), // e.g., "Sell Now" / "बेचें"
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}