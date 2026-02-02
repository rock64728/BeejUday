import 'package:beeju_day/services/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool loading = true;
  Map<String, dynamic>? weather;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  // --- LOGIC PRESERVED ---
  Future<void> fetchWeather() async {
    try {
      final position = await LocationService.getPosition();
      final data = await WeatherService().getWeather(
          position.latitude, position.longitude);

      setState(() {
        weather = data;
        loading = false;
      });
    } catch (e) {
      print(e);
      // Optional: Handle error state in UI
    }
  }
  // -----------------------

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
        // 🔴 CHANGE 2: Translate Title
        title: Text(
          lang.translate('current_weather'),
          style: const TextStyle(
            color: Color(0xFF6A1B9A), 
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Current Weather Card
                  _buildCurrentWeatherCard(lang),
                  
                  const SizedBox(height: 24),

                  // 2. Forecast Header
                  // 🔴 CHANGE 3: Translate Header
                  Text(
                    lang.translate('forecast_header'), // e.g., "3 Days forecast"
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // 3. Forecast Table Header
                  _buildForecastHeader(lang),
                  
                  // 4. Forecast List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (_, i) {
                      return _buildForecastRow(i, lang);
                    },
                  ),

                  const SizedBox(height: 24),

                  // 5. AI Suggestion Box
                  // 🔴 CHANGE 4: Translate Header
                  Text(
                    lang.translate('ai_suggestion'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        left: BorderSide(color: Colors.amber.shade700, width: 6),
                        top: BorderSide(color: Colors.grey.shade200),
                        right: BorderSide(color: Colors.grey.shade200),
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    // 🔴 CHANGE 5: Translate Suggestion Text
                    child: Text(
                      lang.translate('ai_weather_tip'), // "Based on forecast, delay sowing..."
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 6. See Full Forecast Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC4D), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Action for full forecast
                      },
                      // 🔴 CHANGE 6: Translate Button
                      child: Text(
                        lang.translate('see_full_forecast').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildCurrentWeatherCard(LanguageProvider lang) {
    final temp = weather!['current_weather']['temperature'];
    final wind = weather!['current_weather']['windspeed'];
    final humidity = weather!['hourly']['relative_humidity_2m'][0];
    final rainProb = weather!['daily']['precipitation_probability_max'][0]; 

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🔴 CHANGE 7: Translate Row Labels
          _buildWeatherRow("${lang.translate('temperature')}:", "$temp°C"),
          const SizedBox(height: 12),
          _buildWeatherRow("${lang.translate('humidity')}:", "$humidity%"),
          const SizedBox(height: 12),
          _buildWeatherRow("${lang.translate('rain_prob')}:", "$rainProb%"),
          const SizedBox(height: 12),
          _buildWeatherRow("${lang.translate('wind_speed')}:", "$wind Km/h"),
        ],
      ),
    );
  }

  Widget _buildWeatherRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildForecastHeader(LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 🔴 CHANGE 8: Translate Headers
          Expanded(flex: 2, child: Text(lang.translate('day'), style: const TextStyle(fontWeight: FontWeight.bold))),
          const VerticalDivider(width: 1, color: Colors.orange),
          Expanded(flex: 2, child: Text(lang.translate('temp'), style: const TextStyle(fontWeight: FontWeight.bold))),
          const VerticalDivider(width: 1, color: Colors.orange),
          Expanded(flex: 2, child: Text(lang.translate('rain_percent'), style: const TextStyle(fontWeight: FontWeight.bold))),
          const VerticalDivider(width: 1, color: Colors.orange),
          Expanded(flex: 4, child: Text(lang.translate('advisory'), style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildForecastRow(int i, LanguageProvider lang) {
    final maxTemp = weather!['daily']['temperature_2m_max'][i];
    final rainChance = weather!['daily']['precipitation_probability_max'][i];
    
    // 🔴 CHANGE 9: Translate Advisory Logic
    // Instead of raw string, we set a translation key
    String advisoryKey = "good_condition";
    if (rainChance > 50) {
      advisoryKey = "delay_irrigation";
    } else if (maxTemp > 35) {
      advisoryKey = "heat_alert";
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // Day Column
          Expanded(
            flex: 2, 
            // 🔴 CHANGE 10: Translate "Today" / "Day X"
            child: Text(i == 0 ? lang.translate('today') : "${lang.translate('day')} ${i+1}", style: const TextStyle(fontSize: 13)),
          ),
          
          // Divider
          Container(height: 30, width: 1, color: Colors.orange.withOpacity(0.5)),
          const SizedBox(width: 8),

          // Temp Column
          Expanded(
            flex: 2, 
            child: Text("$maxTemp°C", style: const TextStyle(fontSize: 13)),
          ),

          // Divider
          Container(height: 30, width: 1, color: Colors.orange.withOpacity(0.5)),
          const SizedBox(width: 8),

          // Rain Column
          Expanded(
            flex: 2, 
            child: Text("$rainChance%", style: const TextStyle(fontSize: 13)),
          ),

          // Divider
          Container(height: 30, width: 1, color: Colors.orange.withOpacity(0.5)),
          const SizedBox(width: 8),

          // Advisory Column
          Expanded(
            flex: 4, 
            // 🔴 CHANGE 11: Translate Advisory Key
            child: Text(
              lang.translate(advisoryKey), 
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}