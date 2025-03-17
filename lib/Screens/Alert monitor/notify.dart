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
  final bool trafficSignal;
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
    required this.trafficSignal,
    required this.noExit,
    required this.railway,
    required this.roundabout,
    required this.speedBumps,
    required this.station,
    required this.stop,
  });

  factory RoadFeatures.fromJson(Map<String, dynamic> json) {
    return RoadFeatures(
      crossings: json['crossing'] ?? false,
      giveWay: json['give_way'] ?? false,
      trafficSignal: json['traffic_signal'] ?? false,
      junction: json['junction'] ?? false,
      noExit: json['no_exit'] ?? false,
      railway: json['railway'] ?? false,
      roundabout: json['roundabout'] ?? false,
      speedBumps: json['bump'] ?? false,
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
      // Convert input to lowercase for case-insensitive comparison
      final lowerValue = value.toLowerCase();

      // Separate exact matches and partial matches
      final exactMatches = streetNames
          .where((street) => street.toLowerCase() == lowerValue)
          .toList();
      final partialMatches = streetNames
          .where((street) => street.toLowerCase().contains(lowerValue) && street.toLowerCase() != lowerValue)
          .toList();

      // Combine exact matches first, followed by partial matches
      filteredStreetNames = [...exactMatches, ...partialMatches];
    });
  }



  Future<void> fetchWeatherData(String streetName, String cityName, String countyName) async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}/json/geolocation?street_name=$streetName&city_name=$cityName&county_name=$countyName'));

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
              fetchWeatherInfo(streetName, cityName, countyName, latitude, longitude);
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
          errorMessage = 'Failed to fetch geolocation data. Status code: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching geolocation data: $error';
      });
    }
  }

  Future<void> fetchWeatherInfo(String streetName, String cityName, String countyName, double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}/json/road_features_with_weather?street_name=$streetName&city_name=$cityName&county_name=$countyName&latitude=$latitude&longitude=$longitude'));

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
        'bump': roadFeatures.speedBumps ? 'true' : 'false',
        'crossing': roadFeatures.crossings ? 'true' : 'false',
        'junction': roadFeatures.junction ? 'true' : 'false',
        'no_exit': roadFeatures.noExit ? 'true' : 'false',
        'traffic_signal': roadFeatures.trafficSignal ? 'true' : 'false',
        'railway': roadFeatures.railway ? 'true' : 'false',
        'roundabout': roadFeatures.roundabout ? 'true' : 'false',
        'station': roadFeatures.station ? 'true' : 'false',
        'stop': roadFeatures.stop ? 'true' : 'false',
        'traffic_calming': roadFeatures.speedBumps ? 'true' : 'false',
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
        backgroundColor: Colors.teal,
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
                prefixIcon: Icon(Icons.search), // Existing search icon
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_forward), // Arrow icon
                  onPressed: () {
                    // Action when the arrow button is pressed
                    handleStreetNameChange(_streetNameController.text); // You can add a custom action here
                    FocusScope.of(context).unfocus(); // This dismisses the keyboard after the button is pressed
                  },
                ),
              ),
              onChanged: handleStreetNameChange,

            ),

            SizedBox(height: 15),
            if (filteredStreetNames.isNotEmpty)

              Container(
                height: 200,
                child:ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredStreetNames.length,
                  itemBuilder: (context, index) {
                    final streetData = filteredStreetNames[index];

                    // Split the streetData into parts by comma
                    final parts = streetData.split(',');

                    // Ensure there are exactly three parts: street name, city, and county
                    final street = parts.isNotEmpty ? parts[0].trim() : '';
                    final city = parts.length > 1 ? parts[1].trim() : '';
                    final county = parts.length > 2 ? parts[2].trim() : '';

                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            '$street, $city, $county',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          tileColor: Colors.blueGrey[50],
                          onTap: () {
                            _streetNameController.clear();
                            fetchWeatherData(street.toUpperCase(), city.toUpperCase(), county.toUpperCase());
                            setState(() {
                              filteredStreetNames = [];
                            });

                          },
                        ),
                      ],
                    );
                  },
                )

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

              // Text(
              //   'Weather and Road data for ${filteredStreetNames.isNotEmpty ? filteredStreetNames.join(', ') : 'N/A'}',
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              // ),
              // Severity ListTile
              _buildInfoCard('Predicted Severity', predictedSeverity?.toStringAsFixed(3)  ?? 'Loading...'),

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
                // Wrap the weather data rows in the same layout style
                _buildWeatherInfoRow('Condition', weatherDataModel!.condition ?? 'N/A', Icons.cloud),
                _buildWeatherInfoRow('Temperature', '${weatherDataModel!.temperature}°F', Icons.thermostat),
                _buildWeatherInfoRow('Wind Chill', '${weatherDataModel!.windChill}°F', Icons.ac_unit),
                _buildWeatherInfoRow('Humidity', '${weatherDataModel!.humidity}%', Icons.water_drop),
                _buildWeatherInfoRow('Pressure', '${weatherDataModel!.pressure} in', Icons.speed),
                _buildWeatherInfoRow('Visibility', '${weatherDataModel!.visibility} mi', Icons.visibility),
                _buildWeatherInfoRow('Wind Direction', weatherDataModel!.windDirection ?? 'N/A', Icons.navigation),
                _buildWeatherInfoRow('Wind Speed', '${weatherDataModel!.windSpeed} mph', Icons.air),
                _buildWeatherInfoRow('Precipitation', '${weatherDataModel!.precipitation} in', Icons.invert_colors),
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

  Widget _buildWeatherInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              overflow: TextOverflow.ellipsis, // In case the value is too long
            ),
          ),
        ],
      ),
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
                // Using Wrap to display the road features in a chip-like layout
                _buildRoadFeatureChip('Crossings', weatherDataModel!.roadFeatures.crossings),
                _buildRoadFeatureChip('Bump', weatherDataModel!.roadFeatures.speedBumps),
                _buildRoadFeatureChip('Junction', weatherDataModel!.roadFeatures.junction),
                _buildRoadFeatureChip('Railway', weatherDataModel!.roadFeatures.railway),
                _buildRoadFeatureChip('Traffic Signal', weatherDataModel!.roadFeatures.trafficSignal),
                _buildRoadFeatureChip('Give Way', weatherDataModel!.roadFeatures.giveWay),
                _buildRoadFeatureChip('No Exit', weatherDataModel!.roadFeatures.noExit),
                _buildRoadFeatureChip('Roundabout', weatherDataModel!.roadFeatures.roundabout),
                _buildRoadFeatureChip('Station', weatherDataModel!.roadFeatures.station),
                _buildRoadFeatureChip('Stop', weatherDataModel!.roadFeatures.stop),
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

  Widget _buildRoadFeatureChip(String feature, bool value) {
    // Format the feature name (e.g., "Give Way" instead of "give_way")
    String formattedFeature = feature
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Chip(
      avatar: Icon(
        value ? Icons.check_circle : Icons.cancel,
        color: value ? Colors.green : Colors.red,
        size: 20,
      ),
      label: Text(
        formattedFeature,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }


}