import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:personal_task_manager/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:personal_task_manager/features/weather/domain/entities/weather_entity.dart';
import 'package:personal_task_manager/features/weather/domain/repositories/weather_repository.dart';
import '../../../../core/services/weather_cache_service.dart';
import 'package:stream_transform/stream_transform.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;
  final WeatherCacheService _cacheService;
  final Logger _logger = Logger();
  Stream<Position>? _positionStream;
  DateTime _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  WeatherRepositoryImpl(this._remoteDataSource, this._cacheService);

  @override
  Future<WeatherEntity?> getCurrentWeather() async {
    try {
      final cached = await _cacheService.getCachedWeather(0.0, 0.0);
      if (cached != null) {
        _logger.i('Using cached weather');
        return WeatherEntity.fromJson(json.decode(cached.weatherJson));
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location services disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.w('Location permissions denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w('Location permissions denied forever');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final weather = await _remoteDataSource.getCurrentWeather(
        position.latitude,
        position.longitude,
      );
      if (weather != null) {
        _lastUpdate = DateTime.now();
      }
      return weather;
    } catch (e) {
      _logger.e('Error getting weather: $e');
      final cached = await _cacheService.getCachedWeather(0.0, 0.0);
      if (cached != null) {
        _logger.i('Using cached weather as fallback');
        return WeatherEntity.fromJson(json.decode(cached.weatherJson));
      }
      return null;
    }
  }

  Stream<WeatherEntity?> watchWeatherUpdates() async* {
    _positionStream ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 500,
        timeLimit: Duration(minutes: 30),
      ),
    ).debounce(const Duration(minutes: 1));

    await for (final position in _positionStream!) {
      if (DateTime.now().difference(_lastUpdate).inMinutes >= 30) {
        final weather = await _remoteDataSource.getCurrentWeather(
          position.latitude,
          position.longitude,
        );
        if (weather != null) {
          _lastUpdate = DateTime.now();
          yield weather;
        } else {
          yield null;
        }
      }
    }
  }
}
