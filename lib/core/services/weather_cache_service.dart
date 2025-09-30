import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';

class WeatherCacheService {
  final DatabaseService _dbService;
  final Logger _logger = Logger();
  static const int _cacheTTLMinutes = 30;

  WeatherCacheService(this._dbService);

  Future<void> cacheWeather(double lat, double lon, String weatherJson) async {
    final db = _dbService.database;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await db.insert('weather_cache', {
      'latitude': lat,
      'longitude': lon,
      'weather_json': weatherJson,
      'timestamp': timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    _logger.i('Weather cached for lat: $lat, lon: $lon');
  }

  Future<WeatherCacheData?> getCachedWeather(double lat, double lon) async {
    final db = _dbService.database;
    final result = await db.query(
      'weather_cache',
      where: 'latitude = ? AND longitude = ?',
      whereArgs: [lat, lon],
    );
    if (result.isEmpty) return null;

    final data = result.first;
    final timestamp = data['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    if ((now - timestamp) > (_cacheTTLMinutes * 60 * 1000)) {
      await db.delete(
        'weather_cache',
        where: 'id = ?',
        whereArgs: [data['id'] as int],
      );
      _logger.i('Weather cache expired for lat: $lat, lon: $lon');
      return null;
    }

    return WeatherCacheData(
      weatherJson: data['weather_json'] as String,
    );
  }
}

class WeatherCacheData {
  final String weatherJson;

  WeatherCacheData({
    required this.weatherJson,
  });
}