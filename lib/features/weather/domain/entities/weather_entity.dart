class WeatherEntity {
  final double temperatureC;
  final String conditionText;
  final String conditionIconUrl;
  final String locationName;

  WeatherEntity({
    required this.temperatureC,
    required this.conditionText,
    required this.conditionIconUrl,
    required this.locationName,
  });

  factory WeatherEntity.fromJson(Map<String, Object?> json) {
    final current = json['current'] as Map<String, Object?>;
    final location = json['location'] as Map<String, Object?>;
    return WeatherEntity(
      temperatureC: (current['temp_c'] as num?)?.toDouble() ?? 0.0,
      conditionText:
          (current['condition'] as Map<String, Object?>)['text'] as String? ??
          'Unknown',
      conditionIconUrl:
          'https:${(current['condition'] as Map<String, Object?>)['icon'] as String? ?? ''}',
      locationName: location['name'] as String? ?? 'Unknown Location',
    );
  }
}
