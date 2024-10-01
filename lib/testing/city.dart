// lib/city.dart
class City {
  final String cityName;
  final int temperature;
  final int pressure;
  final String windDirection;
  final String weatherCondition;

  City({
    required this.cityName,
    required this.temperature,
    required this.pressure,
    required this.windDirection,
    required this.weatherCondition,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      cityName: json['city_name'],
      temperature: json['temperature'],
      pressure: json['pressure'],
      windDirection: json['wind_direction'],
      weatherCondition: json['weather_condition'],
    );
  }
}
