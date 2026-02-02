import 'dart:convert';
import 'dart:async'; // Import for delay
import 'package:http/http.dart' as http;

class GeminiService {
  // 🔴 PASTE YOUR API KEY HERE
  static const String _apiKey = "AIzaSyDaCQ9UrAsvO4M-XzkNIDKn0CJM2ilMDZo"; 

  Future<String> getExplanation(String crop, String soil, double temp, double rain, String languageCode) async {
    // 1. Setup Instruction
    String instruction = "Answer in English.";
    if (languageCode == 'hi') instruction = "Answer in Hindi (Devanagari script).";
    if (languageCode == 'gu') instruction = "Answer in Gujarati language.";

    // 2. The Prompt
    String prompt = "$instruction Explain in one short sentence why $crop is good for $soil soil with $temp°C temp and ${rain.toInt()}mm rain. Keep it simple for a farmer.";

    // 3. TRY PRIMARY MODEL (Gemini 1.5 Flash - Best for Free Tier)
    // We use 'gemini-flash-latest' as seen in your logs. It is very efficient.
    String? result = await _makeRequest("gemini-flash-latest", prompt);
    
    // 4. IF FAILED, TRY BACKUP MODEL (Gemini 2.0 Flash)
    if (result == null) {
      print("⚠️ Primary model quota exceeded. Trying backup...");
      result = await _makeRequest("gemini-2.0-flash", prompt);
    }

    // 5. Return Result or Fallback
    return result ?? _getFallbackText(languageCode);
  }

  // Helper method to handle the API call and errors
  Future<String?> _makeRequest(String modelName, String prompt) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [{"text": prompt}]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
      } else if (response.statusCode == 429) {
        // Quota exceeded
        print("⏳ Quota Exceeded for $modelName (429).");
        return null; // Return null to trigger backup model or fallback
      } else {
        print("❌ API Error ($modelName): ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Network Error ($modelName): $e");
      return null;
    }
    return null;
  }

  // Fallback
  String _getFallbackText(String lang) {
    if (lang == 'hi') return "मिट्टी और मौसम की अनुकूलता के आधार पर अनुशंसित। (AI Offline)";
    if (lang == 'gu') return "જમીન અને હવામાનની અનુકૂળતાને આધારે ભલામણ કરેલ. (AI Offline)";
    return "Recommended based on soil and weather compatibility. (AI Offline)";
  }
}