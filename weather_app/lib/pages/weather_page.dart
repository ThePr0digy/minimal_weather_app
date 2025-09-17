import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key
final _weatherService = WeatherService('e74a62494fe83cc9e2f3c42533c1a890');
Weather? _weather;
String? _error;

  // fetch weather
  _fetchWeather() async {
    print('Fetching current city...');
    String cityName = await _weatherService.getCurrentCity();
    print('Current city: $cityName');
    try {
      final weather = await _weatherService.getWeather(cityName);
      print('Weather loaded: city=${weather.cityName}, temp=${weather.temperature}, cond=${weather.mainCondition}');
      setState(() {
        _weather = weather;
        _error = null;
      });
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        _error = 'Failed to load weather data. Please check your internet, location permissions, and API key.';
      });
    }
}

  // Helper to select animation based on weather condition
  //weather animations
  String getWeatherAnimation(String? maincondition) {
   if (maincondition == null) return 'assets/sunny.json';//defaults to sunny
   switch (maincondition.toLowerCase()){
    case 'clouds ':
    case 'mist':
    case 'smoke':
    case 'haze':
    case 'fog':
    case 'dust':
      return 'assets/cloud.json';
    case 'rain':
    case 'drizzle':
    case 'shower rain':
      return 'assets/rain.json';
    case 'thunderstorm':
      return 'assets/thunderstorm.json';
    case 'clear':
      return 'assets/sunny.json';
    default:
      return 'assets/sunny.json';
    
   }
  }
  
  // init state
  @override
  void initState() {
    super.initState();

    // fetch weather on startup
    _fetchWeather();
}

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 100),
                  SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchWeather,
                    child: Text('Retry'),
                  ),
                ],
              )
            : _weather == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_weather!.cityName, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Lottie.asset(
                          getWeatherAnimation(_weather!.mainCondition),
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 100),
                                SizedBox(height: 8),
                                Text('Asset failed to load', style: TextStyle(color: Colors.red)),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('${_weather!.temperature.round()}°C', style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(_weather!.mainCondition, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
      ),
    );
  }
}