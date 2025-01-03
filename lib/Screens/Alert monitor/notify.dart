import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config.dart';

class StreetAlertSearch extends StatefulWidget {
  @override
  _StreetAlertSearchState createState() => _StreetAlertSearchState();
}

class RoadFeatures {
  final bool crossings;
  final bool giveWay;
  final bool junction;
  final bool noExit;
  final bool railway;
  final bool roundabout;
  final bool speedBumps;
  final bool station;
  final bool stop;

  RoadFeatures({
    required this.crossings,
    required this.giveWay,
    required this.junction,
    required this.noExit,
    required this.railway,
    required this.roundabout,
    required this.speedBumps,
    required this.station,
    required this.stop,
  });

  factory RoadFeatures.fromJson(Map<String, dynamic> json) {
    return RoadFeatures(
      crossings: json['crossings'] ?? false,
      giveWay: json['give_way'] ?? false,
      junction: json['junction'] ?? false,
      noExit: json['no_exit'] ?? false,
      railway: json['railway'] ?? false,
      roundabout: json['roundabout'] ?? false,
      speedBumps: json['speed_bumps'] ?? false,
      station: json['station'] ?? false,
      stop: json['stop'] ?? false,
    );
  }
}

class WeatherDataModel {
  final String condition;
  final double temperature;
  final double humidity;
  final double windChill;
  final double pressure;
  final double visibility;
  final String windDirection;
  final double windSpeed;
  final double precipitation;
  final double severity;
  final RoadFeatures roadFeatures;

  WeatherDataModel({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windChill,
    required this.pressure,
    required this.visibility,
    required this.windDirection,
    required this.windSpeed,
    required this.precipitation,
    required this.severity,
    required this.roadFeatures,
  });

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) {
    var weather = json['weather'] ?? {};
    var roadFeaturesJson = json['road_features'] ?? {};

    return WeatherDataModel(
      condition: weather['weather'] ?? 'N/A',
      temperature: double.tryParse(weather['temperature(F)']?.toString() ?? '0.0') ?? 0.0,
      humidity: double.tryParse(weather['humidity(%)']?.toString() ?? '0.0') ?? 0.0,
      windChill: double.tryParse(weather['wind_chill(F)']?.toString() ?? '0.0') ?? 0.0,
      pressure: double.tryParse(weather['pressure(in)']?.toString() ?? '0.0') ?? 0.0,
      visibility: double.tryParse(weather['visibility(mi)']?.toString() ?? '0.0') ?? 0.0,
      windDirection: weather['wind_direction'] ?? 'N/A',
      windSpeed: double.tryParse(weather['wind_speed(mph)']?.toString() ?? '0.0') ?? 0.0,
      precipitation: double.tryParse(weather['precipitation(in)']?.toString() ?? '0.0') ?? 0.0,
      severity: double.tryParse(weather['severity']?.toString() ?? '0.0') ?? 0.0,
      roadFeatures: RoadFeatures.fromJson(roadFeaturesJson),
    );
  }
}

class _StreetAlertSearchState extends State<StreetAlertSearch> {
  final TextEditingController _streetNameController = TextEditingController();
  List<String> streetNames = [];
  List<String> filteredStreetNames = [];
  String errorMessage = '';
  WeatherDataModel? weatherDataModel;
  double? predictedSeverity;

  @override
  void initState() {
    super.initState();
    fetchStreetNames();
  }

  Future<void> fetchStreetNames() async {
    try {
      final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/json/street_names'));

      // Debug: Log the response for troubleshooting
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          streetNames = List<String>.from(data);
        });
      } else {
        setState(() {
          errorMessage =
          'Failed to fetch street names. Status code: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching street names: $error';
      });
    }
  }

  void handleStreetNameChange(String value) {
    setState(() {
      filteredStreetNames = streetNames
          .where((street) => street.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> fetchWeatherData(String streetName) async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}/weather/geolocation?street_name=$streetName'));

      // Debug: Log the response for troubleshooting
      print('Weather data response status: ${response.statusCode}');
      print('Weather data response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          if (data['latitude'] != null && data['longitude'] != null) {
            final latitude = double.tryParse(data['latitude'].toString());
            final longitude = double.tryParse(data['longitude'].toString());

            if (latitude != null && longitude != null) {
              fetchWeatherInfo(streetName, latitude, longitude);
            } else {
              setState(() {
                errorMessage = 'Invalid latitude or longitude format.';
              });
            }
          } else {
            setState(() {
              errorMessage = 'No geolocation data found for this street.';
            });
          }
        } catch (e) {
          setState(() {
            errorMessage = 'Error parsing geolocation data: $e';
          });
        }
      } else {
        setState(() {
          errorMessage =
          'Failed to fetch geolocation data. Status code: ${response
              .statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching geolocation data: $error';
      });
    }
  }

  Future<void> fetchWeatherInfo(String streetName, double latitude,
      double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConfig
              .baseUrl}/json/road_features_with_weather?street_name=$streetName&latitude=$latitude&longitude=$longitude'));

      // Debug: Log the response for troubleshooting
      print('Weather info response status: ${response.statusCode}');
      print('Weather info response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          weatherDataModel = WeatherDataModel.fromJson(data);
        });
        fetchPredictedSeverity(weatherDataModel!.roadFeatures);
      } else {
        setState(() {
          errorMessage =
          'Failed to fetch weather info. Status code: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching weather info: $error';
      });
    }
  }

  Future<void> fetchPredictedSeverity(RoadFeatures roadFeatures) async {
    try {
      final params = {
        'temperature': weatherDataModel!.temperature.toString(),
        'pressure': weatherDataModel!.pressure.toString(),
        'wind_direction': weatherDataModel!.windDirection,
        'wind_speed': weatherDataModel!.windSpeed.toString(),
        'weather_condition': weatherDataModel!.condition,
        'bumplse': roadFeatures.speedBumps ? 'true' : 'false',
        'junction': roadFeatures.junction ? 'true' : 'false',
        'no_exit': roadFeatures.noExit ? 'true' : 'false',
        'railway': roadFeatures.railway ? 'true' : 'false',
        'roundabout': roadFeatures.roundabout ? 'true' : 'false',
        'station': roadFeatures.station ? 'true' : 'false',
        'stop': roadFeatures.stop ? 'true' : 'false',
        'traffic_calming': roadFeatures.speedBumps ? 'true' : 'false',
        'traffic_signal': 'false',
      };

      final response = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}/json/calculate_severity?' + Uri(queryParameters: params).toString()));

      // Debug: Log the response for troubleshooting
      print('Predicted severity response status: ${response.statusCode}');
      print('Predicted severity response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          predictedSeverity = data['severity'] != null ? (data['severity'] is int ? (data['severity'] as int).toDouble() : data['severity']) : null;
        });

      } else {
        setState(() {
          errorMessage =
          'Failed to fetch predicted severity. Status code: ${response
              .statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching predicted severity: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather and Road Data', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _streetNameController,
              decoration: InputDecoration(
                hintText: 'Enter street name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: handleStreetNameChange,
            ),
            SizedBox(height: 15),
            if (filteredStreetNames.isNotEmpty)
              Container(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredStreetNames.length,
                  itemBuilder: (context, index) {
                    final street = filteredStreetNames[index];
                    return ListTile(
                      title: Text(
                        street,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      tileColor: Colors.blueGrey[50],
                      onTap: () {
                        _streetNameController.clear();
                        fetchWeatherData(street);
                        setState(() {
                          filteredStreetNames = [];
                        });
                      },
                    );
                  },
                ),
              ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            if (weatherDataModel != null) ...[
              // Severity ListTile
              _buildInfoCard('Predicted Severity', predictedSeverity?.toString() ?? 'Loading...'),

              // Weather Data ListTile
              _buildInfoCard('Weather Data', 'Condition: ${weatherDataModel!.condition}, Temp: ${weatherDataModel!.temperature}°F, Wind Chill: ${weatherDataModel!.windChill}°F', onTap: () => _showWeatherDialog(context)),

              // Road Features ListTile
              _buildInfoCard('Road Features',
                  'Crossings: ${weatherDataModel!.roadFeatures.crossings ? 'Yes' : 'No'} | '
                      'Junction: ${weatherDataModel!.roadFeatures.junction ? 'Yes' : 'No'} | '
                      'Railway: ${weatherDataModel!.roadFeatures.railway ? 'Yes' : 'No'}',
                  onTap: () => _showRoadDialog(context)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {VoidCallback? onTap}) {
    // Determine the color based on severity value
    Color severityColor = Colors.green; // Default to normal (green)
    String severityText = value;

    // Check if the value is a number and greater than 3
    double? severityValue = double.tryParse(value);
    if (severityValue != null && severityValue > 3) {
      severityColor = Colors.red; // Risk color
      severityText = '$value'; // Display 'Risk' text
    } else {
      severityText = '$value'; // Display 'Normal' text
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          severityText,
          style: TextStyle(
            fontSize: 14,
            color: severityColor,  // Apply the severity color
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showWeatherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Weather Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Condition: ${weatherDataModel!.condition}'),
                Text('Temperature: ${weatherDataModel!.temperature}°F'),
                Text('Wind Chill: ${weatherDataModel!.windChill}°F'),
                Text('Humidity: ${weatherDataModel!.humidity}%'),
                Text('Pressure: ${weatherDataModel!.pressure} in'),
                Text('Visibility: ${weatherDataModel!.visibility} mi'),
                Text('Wind Direction: ${weatherDataModel!.windDirection}'),
                Text('Wind Speed: ${weatherDataModel!.windSpeed} mph'),
                Text('Precipitation: ${weatherDataModel!.precipitation} in'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRoadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Road Features'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Crossings: ${weatherDataModel!.roadFeatures.crossings ? 'Yes' : 'No'}'),
                Text('Junction: ${weatherDataModel!.roadFeatures.junction ? 'Yes' : 'No'}'),
                Text('Railway: ${weatherDataModel!.roadFeatures.railway ? 'Yes' : 'No'}'),
                Text('Give Way: ${weatherDataModel!.roadFeatures.giveWay ? 'Yes' : 'No'}'),
                Text('No Exit: ${weatherDataModel!.roadFeatures.noExit ? 'Yes' : 'No'}'),
                Text('Roundabout: ${weatherDataModel!.roadFeatures.roundabout ? 'Yes' : 'No'}'),
                Text('Speed Bumps: ${weatherDataModel!.roadFeatures.speedBumps ? 'Yes' : 'No'}'),
                Text('Station: ${weatherDataModel!.roadFeatures.station ? 'Yes' : 'No'}'),
                Text('Stop: ${weatherDataModel!.roadFeatures.stop ? 'Yes' : 'No'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}