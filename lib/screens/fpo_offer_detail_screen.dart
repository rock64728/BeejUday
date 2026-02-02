import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';


class FPOOfferDetailScreen extends StatefulWidget {
  final Map<String, dynamic> offer;

  const FPOOfferDetailScreen({super.key, required this.offer});

  @override
  State<FPOOfferDetailScreen> createState() => _FPOOfferDetailScreenState();
}

class _FPOOfferDetailScreenState extends State<FPOOfferDetailScreen> {
  final TextEditingController _farmerNameController = TextEditingController(text: "Farmer Ji");
  final TextEditingController _quantityController = TextEditingController(text: "5");

  @override
  Widget build(BuildContext context) {
    // 🔴 CHANGE 1: Initialize Provider
    final lang = Provider.of<LanguageProvider>(context);
    final o = widget.offer;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        // 🔴 CHANGE 2: Translate Title
        title: Text(
          lang.translate('offer_details'),
          style: const TextStyle(
            color: Color(0xFF6A1B9A), 
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o['fpo_name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.orange, thickness: 1, height: 20),
                  // 🔴 CHANGE 3: Translate Detail Rows
                  // We pass 'lang' to the helper method
                  _buildDetailRow(Icons.location_on, lang.translate('location'), o['location']),
                  _buildDetailRow(Icons.grass, lang.translate('crop'), o['crop']),
                  _buildDetailRow(Icons.attach_money, lang.translate('price'), "₹${o['price_per_qtl']} / ${lang.translate('qtl')}"),
                  _buildDetailRow(Icons.scale, lang.translate('quantity_limit'), "${o['min_qtl']} – ${o['max_qtl']} ${lang.translate('qtl')}"),
                  _buildDetailRow(Icons.timer, lang.translate('valid_till'), "${o['valid_till']}"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Input Section
            // 🔴 CHANGE 4: Translate Section Header
            Text(
              lang.translate('commit_produce'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 🔴 CHANGE 5: Translate Text Fields
            _buildStyledTextField(
              controller: _farmerNameController,
              label: lang.translate('farmer_name'),
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              controller: _quantityController,
              label: "${lang.translate('quantity')} (${lang.translate('qtl')})",
              icon: Icons.production_quantity_limits,
              isNumber: true,
            ),

            const SizedBox(height: 40),

            // Primary Button (PDF)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC4D), 
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                // 🔴 CHANGE 6: Pass 'lang' to PDF generator
                onPressed: () => _generatePdf(lang),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
                label: Text(
                  lang.translate('generate_slip').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      // 🔴 CHANGE 7: Translate Toast Message
                      content: Text(lang.translate('interest_sent_msg')),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text(
                  lang.translate('send_interest').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }

  // 🔴 CHANGE 8: Generate PDF with Translated Text
  // Note: Standard PDF fonts often don't support Hindi/Gujarati scripts.
  // For a real app, you need to load a Unicode font (like NotoSans).
  // For this prototype, I will keep the PDF in English to avoid "Rectangle Box" errors,
  // OR use transliteration if preferred.
  Future<void> _generatePdf(LanguageProvider lang) async {
    final o = widget.offer;
    final farmerName = _farmerNameController.text.trim();
    final qty = _quantityController.text.trim();

    final doc = pw.Document();

    // Ideally, load a font that supports Indic languages
    // var font = await PdfGoogleFonts.notoSansDevanagariRegular();

    doc.addPage(
      pw.Page(
        // theme: pw.ThemeData.withFont(base: font), // Enable this if you add the font package
        build: (ctx) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "BeejuDay",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  "Procurement Assurance Slip", // Keep PDF headers in English for safety
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text("FPO Name: ${o['fpo_name']}"),
                pw.Text("Location: ${o['location']}"),
                pw.Text("Crop: ${o['crop']}"),
                pw.Text("Price per quintal: ₹${o['price_per_qtl']}"),
                pw.Text("Offer valid till: ${o['valid_till']}"),
                pw.SizedBox(height: 12),
                pw.Text("Farmer Name: $farmerName"),
                pw.Text("Committed Quantity: $qty qtl"),
                pw.SizedBox(height: 16),
                pw.Text(
                  "Note: This is a pre-contract assurance generated via BeejuDay prototype. "
                  "Final procurement will depend on quality, grading, and FPO terms.",
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 32),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(children: [
                      pw.Text("Farmer Signature"),
                      pw.SizedBox(height: 24),
                      pw.Text("_______________________"),
                    ]),
                    pw.Column(children: [
                      pw.Text("FPO Representative"),
                      pw.SizedBox(height: 24),
                      pw.Text("_______________________"),
                    ]),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'BeejuDay_Assurance_Slip.pdf',
    );
  }
}