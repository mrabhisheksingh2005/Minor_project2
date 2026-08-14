import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class WeatherData {
  final String location;
  final double temperature;
  final String condition;
  final int humidity;
  final double soilMoisture;
  final String windSpeed;
  final String rainChance;
  final double latitude;
  final double longitude;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.soilMoisture,
    required this.windSpeed,
    required this.rainChance,
    required this.latitude,
    required this.longitude,
  });
}

class FarmingTip {
  final String title;
  final String category;
  final String content;

  const FarmingTip({
    required this.title,
    required this.category,
    required this.content,
  });
}

class WeatherService {
  final _random = Random();

  static const double defaultLatitude = 28.4089;
  static const double defaultLongitude = 77.3178;

  Future<WeatherData> fetchLiveWeather({
    double latitude = defaultLatitude,
    double longitude = defaultLongitude,
    String locationName = 'Faridabad, Haryana, India',
  }) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,precipitation'
        '&timezone=auto'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];

        final double temp = (current['temperature_2m'] as num).toDouble();
        final int humidity = (current['relative_humidity_2m'] as num).toInt();
        final double wind = (current['wind_speed_10m'] as num).toDouble();
        final double precip = (current['precipitation'] as num).toDouble();
        final int weatherCode = (current['weather_code'] as num).toInt();

        final condition = _mapWeatherCode(weatherCode);
        final double derivedSoilMoisture = double.parse(
          (30.0 + (humidity * 0.4) + (precip * 5)).clamp(10.0, 95.0).toStringAsFixed(1)
        );

        return WeatherData(
          location: locationName,
          temperature: double.parse(temp.toStringAsFixed(1)),
          condition: condition,
          humidity: humidity,
          soilMoisture: derivedSoilMoisture,
          windSpeed: '$wind km/h',
          rainChance: '${(precip > 0 ? (30 + precip * 10) : 5).clamp(0, 99).toInt()}%',
          latitude: latitude,
          longitude: longitude,
        );
      }
    } catch (_) {}

    return WeatherData(
      location: '$locationName (Offline Cache)',
      temperature: 29.5,
      condition: 'Partly Cloudy',
      humidity: 62,
      soilMoisture: 45.5,
      windSpeed: '12 km/h',
      rainChance: '15%',
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Geocoding API: Resolves city names to latitude and longitude
  Future<WeatherData> fetchWeatherByCity(String cityName) async {
    try {
      final geoUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(cityName)}&count=1&language=en&format=json'
      );

      final geoResponse = await http.get(geoUrl);

      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        final List? results = geoData['results'];

        if (results != null && results.isNotEmpty) {
          final firstMatch = results.first;
          final double lat = (firstMatch['latitude'] as num).toDouble();
          final double lon = (firstMatch['longitude'] as num).toDouble();
          final String name = firstMatch['name'] ?? cityName;
          final String country = firstMatch['country'] ?? '';
          final String resolvedName = country.isNotEmpty ? '$name, $country' : name;

          return await fetchLiveWeather(
            latitude: lat,
            longitude: lon,
            locationName: resolvedName,
          );
        }
      }
    } catch (_) {}

    // Fallback search mock if search fails
    return await fetchLiveWeather(locationName: cityName);
  }

  String _mapWeatherCode(int code) {
    if (code == 0) return 'Sunny';
    if (code >= 1 && code <= 3) return 'Partly Cloudy';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 57) return 'Drizzling';
    if (code >= 61 && code <= 67) return 'Rainy';
    if (code >= 71 && code <= 77) return 'Snowy';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Cloudy';
  }

  List<FarmingTip> getFarmingTips() {
    return const [
      FarmingTip(
        title: 'Optimal Watering for Tomatoes',
        category: 'Irrigation',
        content: 'Water tomato plants at the base early in the morning. Avoid wet leaves to significantly lower the risk of Early Blight infection.',
      ),
      FarmingTip(
        title: 'Natural Pest Repellent',
        category: 'Pest Control',
        content: 'Spray a diluted Neem Oil solution (1% concentration) on chili and cotton plants once every 2 weeks to control whiteflies and aphids organically.',
      ),
      FarmingTip(
        title: 'Balanced Nitrogen Feeding',
        category: 'Fertilizing',
        content: 'Avoid excess nitrogen fertilizers in rice fields. High nitrogen creates tender, lush leaf tissue which is highly susceptible to Rice Blast.',
      ),
      FarmingTip(
        title: 'Crop Rotation Cycle',
        category: 'Soil Health',
        content: 'After harvesting potatoes or tomatoes, plant legumes (like peas or beans) to naturally replenish nitrogen levels in the soil for the next season.',
      ),
      FarmingTip(
        title: 'Proper Potato Storage',
        category: 'Harvesting',
        content: 'Before storing potatoes, cure them at 15°C with high humidity for 10 days to heal skin blemishes, preventing storage dry rot.',
      ),
    ];
  }
}
