import 'package:personal_task_manager/features/weather/domain/entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity?> getCurrentWeather();
}
