import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';

class StreetAlertSearch extends StatefulWidget {
  @override
  _StreetAlertSearchState createState() => _StreetAlertSearchState();
}

class _StreetAlertSearchState extends State<StreetAlertSearch> {
  String streetName = ''; // Street name entered by the user
  Map<String, dynamic>? weatherDataModel; // Weather data from model output
  String errorMessage = ''; // Error message
  bool isLoading = false; // Loading state

  // Function to fetch geolocation and weather data
  Future<void> fetchWeatherDetails(String streetName) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/weather/geolocation?street_name=${Uri.encodeComponent(streetName)}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['latitude'] != null && data['longitude'] != null) {
          // Parse latitude and longitude as doubles
          double latitude = double.parse(data['latitude']);
          double longitude = double.parse(data['longitude']);
          fetchWeatherData(latitude, longitude);
          fetchWeatherDataFromModel();
        } else {
          setState(() {
            errorMessage = 'No geolocation data found for this street.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch geolocation data.';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        errorMessage = 'Error fetching geolocation data.';
        isLoading = false;
      });
    }
  }

  // Function to fetch weather data (not displayed)
  Future<void> fetchWeatherData(double latitude, double longitude) async {
    try {
      await http.get(
        Uri.parse('${ApiConfig.baseUrl}/weather/weather_data?latitude=$latitude&longitude=$longitude'),
      );
      // Weather data fetching but ignored for display
    } catch (e) {
      // Log error (optional)
    }
  }

  // Function to fetch weather data from model (displayed)
  Future<void> fetchWeatherDataFromModel() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/weather/model_output'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          weatherDataModel = {
            'condition': data['weather'] ?? 'N/A',
            'temperature': double.tryParse(data['temperature'] ?? '0.0') ?? 0.0,
            'humidity': double.tryParse(data['humidity'] ?? '0.0') ?? 0.0,
            'windChill': double.tryParse(data['wind_chill'] ?? '0.0') ?? 0.0,
            'pressure': double.tryParse(data['pressure'] ?? '0.0') ?? 0.0,
            'visibility': double.tryParse(data['visibility'] ?? '0.0') ?? 0.0,
            'windDirection': data['windDirection'] ?? 'N/A',
            'windSpeed': double.tryParse(data['wind_speed'] ?? '0.0') ?? 0.0,
            'precipitation': double.tryParse(data['precipitation'] ?? '0.0') ?? 0.0,
            'severity': double.tryParse(data['severity'] ?? '0.0') ?? 0.0,
          };
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch weather model data.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching weather model data.';
        isLoading = false;
      });
    }
  }

  // Determine severity color
  Color getSeverityColor(double? severity) {
    if (severity == null) return Colors.black;
    return severity >= 4.0 ? Colors.red : Colors.green;
  }

  // Function to build weather data rows
  Widget buildWeatherRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.cloud, color: Colors.blue),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              "$label: ",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Street Weather Alerts'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0DE4C7), // Light blue-green color
              Color(0xFF5712A7), // Purple color
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Street Name Input with Arrow Icon Button
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Street Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.teal),
                    onPressed: () {
                      if (streetName.isEmpty) {
                        setState(() {
                          errorMessage = 'Please enter a street name.';
                        });
                      } else {
                        fetchWeatherDetails(streetName);
                      }
                    },
                  ),
                ),
                onChanged: (value) {
                  streetName = value;
                },
              ),
              SizedBox(height: 10),
              // Loading Spinner
              if (isLoading) CircularProgressIndicator(),
              // Error Message
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              // Display Weather Data
              if (!isLoading && weatherDataModel != null)
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Weather Information for $streetName",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(),
                            buildWeatherRow("Weather Condition", weatherDataModel!['condition']),
                            buildWeatherRow("Wind Direction", weatherDataModel!['windDirection']),
                            buildWeatherRow("Temperature", "${weatherDataModel!['temperature']}°F"),
                            buildWeatherRow("Humidity", "${weatherDataModel!['humidity']}%"),
                            buildWeatherRow("Wind Chill", "${weatherDataModel!['windChill']}°F"),
                            buildWeatherRow("Pressure", "${weatherDataModel!['pressure']} in"),
                            buildWeatherRow("Visibility", "${weatherDataModel!['visibility']} mi"),
                            buildWeatherRow("Wind Speed", "${weatherDataModel!['windSpeed']} mph"),
                            buildWeatherRow("Precipitation", "${weatherDataModel!['precipitation']} in"),

                            // Display severity prediction
                            if (weatherDataModel!['severity'] != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  children: [
                                    Icon(FontAwesomeIcons.exclamationTriangle, color: getSeverityColor(weatherDataModel!['severity'])),
                                    SizedBox(width: 20),
                                    Text(
                                      "Predicted Severity: ${weatherDataModel!['severity'].toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: getSeverityColor(weatherDataModel!['severity'])),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
