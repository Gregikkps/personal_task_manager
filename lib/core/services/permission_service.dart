import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final Logger _logger = Logger();

  Future<LocationPermissionStatus> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      default:
        return LocationPermissionStatus.denied;
    }
  }

  Future<LocationPermissionStatus> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      default:
        return LocationPermissionStatus.denied;
    }
  }

  Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<bool> openAppSettings() async {
    try {
      final opened = await Geolocator.openAppSettings();
      _logger.i('App settings opened: $opened');
      return opened;
    } catch (e) {
      _logger.e('Failed to open app settings: $e');
      return false;
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      final opened = await Geolocator.openLocationSettings();
      _logger.i('Location settings opened: $opened');
      return opened;
    } catch (e) {
      _logger.e('Failed to open location settings: $e');
      return false;
    }
  }
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}
