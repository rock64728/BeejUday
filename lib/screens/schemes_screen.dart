import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  bool loading = true;
  List schemes = [];

  final String apiUrl = "https://api.npoint.io/d0e07cd9c2d91392a619"; 

  @override
  void initState() {
    super.initState();
    fetchSchemes();
  }

  Future<void> fetchSchemes() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          schemes = json.decode(response.body);
          loading = false;
        });
      } else {
        throw Exception("Failed to load");
      }
    } catch (e) {
      print("Error fetching schemes: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔴 CHANGE 1: Initialize Provider
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
        // 🔴 CHANGE 2: Translate Header
        title: Text(
          lang.translate('govt_schemes'),
          style: const TextStyle(
            color: Color(0xFF880E4F),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : schemes.isEmpty 
              // 🔴 CHANGE 3: Translate Error/Empty Message
              ? Center(child: Text(lang.translate('no_schemes_found')))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: schemes.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    return _buildSchemeCard(schemes[i], lang);
                  },
                ),
    );
  }

  // 🔴 CHANGE 4: Pass 'lang' to helper
  Widget _buildSchemeCard(Map<String, dynamic> s, LanguageProvider lang) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: const Color(0xFFFFB300)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔴 CHANGE 5: Translate Scheme Name (If it matches a key, or use fallback)
                    // Note: Dynamic API text usually stays in English unless you have a translation API.
                    // Here we wrap it just in case you add keys for specific schemes later.
                    Text(
                      s['name'] ?? lang.translate('scheme_name'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s['description'] ?? "",
                      style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔴 CHANGE 6: Translate 'Eligibility' Label
                              Text(lang.translate('eligibility'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(
                                s['eligibility'] ?? "N/A",
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              // 🔴 CHANGE 7: Translate Benefit (or 'Apply' button text if it was a button)
                              s['benefit'] ?? lang.translate('apply'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}