import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:personal_task_manager/core/env/env.dart';
import 'package:personal_task_manager/features/weather/domain/entities/weather_entity.dart';
import '../../../../core/services/weather_cache_service.dart';

class WeatherRemoteDataSource {
  final http.Client _client;
  final WeatherCacheService _cacheService;
  final Logger _logger = Logger();
  static const String _baseUrl = 'http://api.weatherapi.com/v1/current.json';
  static final String _apiKey = Env.weatherApiKey;
  WeatherRemoteDataSource(this._client, this._cacheService);

  Future<WeatherEntity?> getCurrentWeather(double lat, double lon) async {
    try {
      final cached = await _cacheService.getCachedWeather(lat, lon);
      if (cached != null) {
        _logger.i('Using cached weather for lat: $lat, lon: $lon');
        return WeatherEntity.fromJson(json.decode(cached.weatherJson));
      }

      final uri = Uri.parse('$_baseUrl?key=$_apiKey&q=$lat,$lon');
      final response = await _client
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final weatherData = json.decode(response.body);
        final weather = WeatherEntity.fromJson(weatherData);

        _cacheService.cacheWeather(lat, lon, jsonEncode(weatherData));

        return weather;
      } else {
        _logger.e('API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Network error: $e');

      final cached = await _cacheService.getCachedWeather(lat, lon);
      if (cached != null) {
        _logger.i('Using cached weather as fallback');
        return WeatherEntity.fromJson(json.decode(cached.weatherJson));
      }
      return null;
    }
  }
}
