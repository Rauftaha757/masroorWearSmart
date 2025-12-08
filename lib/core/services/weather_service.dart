import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String city;
  final double tempC;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final String description;
  final String icon;

  WeatherData({
    required this.city,
    required this.tempC,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
  });
}

class WeatherService {
  final String apiKey;
  final String _base = 'https://api.openweathermap.org/data/2.5';
  final String _geo = 'https://api.openweathermap.org/geo/1.0';

  WeatherService({required this.apiKey});

  Future<WeatherData> fetchByCity(String city) async {
    final cleaned = city.trim();
    // Resolve city to lat/lon via geocoding (more reliable than q=)
    final resolved = await _resolveCity(cleaned);
    if (resolved == null && !cleaned.contains(',')) {
      // Fallback: try default country PK if none provided and first lookup failed
      final fallback = await _resolveCity('$cleaned,PK');
      if (fallback == null) {
        throw Exception('City not found: $city');
      }
      return _fetchByCoords(fallback['lat'], fallback['lon'], fallback['name']);
    } else if (resolved == null) {
      throw Exception('City not found: $city');
    }
    return _fetchByCoords(resolved['lat'], resolved['lon'], resolved['name']);
  }

  Future<Map<String, dynamic>?> _resolveCity(String query) async {
    final uri = Uri.parse('$_geo/direct?q=$query&limit=1&appid=$apiKey');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body);
    if (data is List && data.isNotEmpty) {
      final e = data.first;
      return {
        'name': (e['name'] ?? query).toString(),
        'lat': (e['lat'] as num).toDouble(),
        'lon': (e['lon'] as num).toDouble(),
        'country': (e['country'] ?? '').toString(),
      };
    }
    return null;
  }

  Future<WeatherData> _fetchByCoords(
    double lat,
    double lon,
    String resolvedName,
  ) async {
    final uri = Uri.parse(
      '$_base/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );
    final resp = await http.get(uri);
    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200) {
      return WeatherData(
        city: resolvedName,
        tempC: (data['main']['temp'] as num).toDouble(),
        feelsLike: (data['main']['feels_like'] as num).toDouble(),
        humidity: (data['main']['humidity'] as num).toDouble(),
        windSpeed: (data['wind']['speed'] as num).toDouble(),
        description: (data['weather'][0]['description'] as String),
        icon: (data['weather'][0]['icon'] as String),
      );
    }
    final msg = data is Map && data['message'] != null
        ? data['message']
        : 'Failed to fetch weather';
    throw Exception(msg);
  }

  String iconUrl(String icon) =>
      'https://openweathermap.org/img/wn/$icon@2x.png';
}
