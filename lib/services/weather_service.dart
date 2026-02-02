import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast?"
      "latitude=$lat&longitude=$lon&current_weather=true&"
      "hourly=temperature_2m,relative_humidity_2m,precipitation_probability&"
      "daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch weather");
    }
  }
}
