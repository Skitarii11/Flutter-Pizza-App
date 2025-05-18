import 'dart:convert';

T? _safeGet<T>(Map<String, dynamic> json, String key, T? Function(dynamic) converter) {
  if (json.containsKey(key) && json[key] != null) {
    return converter(json[key]);
  }
  return null;
}

double? _toDouble(dynamic value) => (value as num?)?.toDouble();
int? _toInt(dynamic value) => (value as num?)?.toInt();

class WeatherResponse {
  final Coord? coord;
  final List<WeatherCondition>? weather;
  final MainWeather? main;
  final Wind? wind;
  final Clouds? clouds;
  final int? dt;
  final Sys? sys;
  final int? timezone;
  final int? id;
  final String? name;
  final int? cod;

  WeatherResponse({
    this.coord,
    this.weather,
    this.main,
    this.wind,
    this.clouds,
    this.dt,
    this.sys,
    this.timezone,
    this.id,
    this.name,
    this.cod,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      coord: _safeGet(json, 'coord', (data) => Coord.fromJson(data as Map<String, dynamic>)),
      weather: _safeGet(json, 'weather', (data) => (data as List<dynamic>)
          .map((item) => WeatherCondition.fromJson(item as Map<String, dynamic>))
          .toList()),
      main: _safeGet(json, 'main', (data) => MainWeather.fromJson(data as Map<String, dynamic>)),
      wind: _safeGet(json, 'wind', (data) => Wind.fromJson(data as Map<String, dynamic>)),
      clouds: _safeGet(json, 'clouds', (data) => Clouds.fromJson(data as Map<String, dynamic>)),
      dt: _toInt(json['dt']),
      sys: _safeGet(json, 'sys', (data) => Sys.fromJson(data as Map<String, dynamic>)),
      timezone: _toInt(json['timezone']),
      id: _toInt(json['id']),
      name: json['name'] as String?,
      cod: _toInt(json['cod']),
    );
  }

  static WeatherResponse? fromJsonString(String jsonString) {
    try {
      return WeatherResponse.fromJson(json.decode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      print("Error parsing weather JSON: $e");
      return null;
    }
  }

  String? get weatherIconUrl {
    if (weather != null && weather!.isNotEmpty && weather![0].icon != null) {
      return "https://openweathermap.org/img/wn/${weather![0].icon}@2x.png";
    }
    return null;
  }

  String? get weatherDescription {
     if (weather != null && weather!.isNotEmpty && weather![0].description != null) {
      return weather![0].description;
    }
    return null;
  }
}

class Coord {
  final double? lon;
  final double? lat;

  Coord({this.lon, this.lat});

  factory Coord.fromJson(Map<String, dynamic> json) {
    return Coord(
      lon: _toDouble(json['lon']),
      lat: _toDouble(json['lat']),
    );
  }
}

class WeatherCondition {
  final int? id;
  final String? main;
  final String? description;
  final String? icon;

  WeatherCondition({this.id, this.main, this.description, this.icon});

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      id: _toInt(json['id']),
      main: json['main'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }
}

class MainWeather {
  final double? temp;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final int? pressure;
  final int? humidity;

  MainWeather({
    this.temp,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.pressure,
    this.humidity,
  });

  factory MainWeather.fromJson(Map<String, dynamic> json) {
    return MainWeather(
      temp: _toDouble(json['temp']),
      feelsLike: _toDouble(json['feels_like']),
      tempMin: _toDouble(json['temp_min']),
      tempMax: _toDouble(json['temp_max']),
      pressure: _toInt(json['pressure']),
      humidity: _toInt(json['humidity']),
    );
  }
}

class Wind {
  final double? speed;
  final int? deg;

  Wind({this.speed, this.deg});

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: _toDouble(json['speed']),
      deg: _toInt(json['deg']),
    );
  }
}

class Clouds {
  final int? all;

  Clouds({this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(
      all: _toInt(json['all']),
    );
  }
}

class Sys {
  final String? country;
  final int? sunrise;
  final int? sunset;

  Sys({this.country, this.sunrise, this.sunset});

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(
      country: json['country'] as String?,
      sunrise: _toInt(json['sunrise']),
      sunset: _toInt(json['sunset']),
    );
  }
}