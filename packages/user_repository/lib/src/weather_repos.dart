import 'package:http/http.dart' as http;
import 'package:user_repository/src/models/weather_model.dart';

class WeatherRepository {
  final String _apiKey = '52bbf4763c8ac755580d01a51096eaf8';
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherResponse> fetchWeather(String cityName) async {
    final Uri uri = Uri.parse('$_baseUrl?q=$cityName&appid=$_apiKey&units=metric');
    print("Fetching weather from: $uri");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final weather = WeatherResponse.fromJsonString(response.body);
        if (weather != null) {
          return weather;
        } else {
          throw Exception('Failed to parse weather data.');
        }
      } else {
        print("Failed to load weather. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to load weather. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching weather: $e");
      throw Exception('Error fetching weather: $e');
    }
  }
}