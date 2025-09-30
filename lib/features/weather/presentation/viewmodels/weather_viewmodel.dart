import 'package:flutter/material.dart';
import 'package:personal_task_manager/core/services/permission_service.dart';
import 'package:personal_task_manager/features/weather/domain/entities/weather_entity.dart';
import 'package:personal_task_manager/features/weather/domain/repositories/weather_repository.dart';
import 'package:get_it/get_it.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _repository = GetIt.instance<WeatherRepository>();
  final PermissionService _permissionService = PermissionService();

  WeatherEntity? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  LocationPermissionStatus? _permissionStatus;

  WeatherEntity? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LocationPermissionStatus? get permissionStatus => _permissionStatus;

  bool get needsPermission =>
      _permissionStatus == LocationPermissionStatus.denied ||
      _permissionStatus == LocationPermissionStatus.deniedForever;

  Future<void> loadWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _permissionStatus = await _permissionService.checkLocationPermission();

      if (_permissionStatus == LocationPermissionStatus.serviceDisabled) {
        _errorMessage = 'Location services are disabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (_permissionStatus == LocationPermissionStatus.denied) {
        _permissionStatus = await _permissionService
            .requestLocationPermission();
      }

      if (_permissionStatus == LocationPermissionStatus.deniedForever ||
          _permissionStatus == LocationPermissionStatus.denied) {
        _errorMessage = 'Location permission required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _weather = await _repository.getCurrentWeather().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Weather request timed out'),
      );

      if (_weather == null) {
        _errorMessage = 'Unable to fetch weather';
      }
    } catch (e) {
      _errorMessage = 'Weather unavailable';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openSettings() async {
    if (_permissionStatus == LocationPermissionStatus.serviceDisabled) {
      await _permissionService.openLocationSettings();
    } else {
      await _permissionService.openAppSettings();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
