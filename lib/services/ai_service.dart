class AISuggestion {
  static String getSuggestion(Map weather) {
    int currentRain = weather['rain_prob'];
    List forecast = weather['forecast'];

    double avgRain = forecast.fold(0.0, (sum, day) => sum + day['rain_prob']) / forecast.length;

    if (avgRain > 50) {
      return "Based on forecast, delay sowing for 2 days.\nRecommended sowing: ${weather['sowing_window']['start']} – ${weather['sowing_window']['end']}";
    } else if (avgRain < 20) {
      return "Good time for irrigation and pesticide spray. Rain chances are low.";
    } else {
      return "Moderate weather. You can prepare land for sowing.";
    }
  }
}
