import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';

class StreetAlertSearch extends StatefulWidget {
  @override
  _StreetAlertSearchState createState() => _StreetAlertSearchState();
}

class _StreetAlertSearchState extends State<StreetAlertSearch> {
  String streetName = ''; // Street name entered by the user
  Map<String, dynamic>? weatherData; // Weather data for the selected street
  double? severity; // Predicted severity
  String errorMessage = ''; // Error message if something goes wrong
  bool isLoading = false; // Loading state

  // Function to fetch the geolocation based on the street name
  Future<void> fetchGeolocation(String streetName) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/weather/geolocation?street_name=$streetName'));
      final data = json.decode(response.body);
      print(response.body);

      // Ensure the latitude and longitude are parsed as doubles
      if (data['latitude'] != null && data['longitude'] != null) {
        double latitude = double.parse(data['latitude']);
        double longitude = double.parse(data['longitude']);
        fetchWeatherData(latitude, longitude);
      } else {
        setState(() {
          errorMessage = 'No geolocation data found for this street.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching geolocation data.';
        isLoading = false;
      });
    }
  }

  // Function to fetch weather data based on latitude and longitude
  Future<void> fetchWeatherData(double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/weather/weather_data?latitude=$latitude&longitude=$longitude'));
      final data = json.decode(response.body);

      setState(() {
        weatherData = {
          'condition': data['weather'] ?? 'N/A',
          'temperature': data['temperature(F)'] ?? 0.0,
          'humidity': data['humidity(%)'] ?? 0.0,
          'windChill': data['wind_chill(F)'] ?? 0.0,
          'pressure': data['pressure(in)'] ?? 0.0,
          'visibility': data['visibility(mi)'] ?? 0.0,
          'windDirection': data['wind_direction'] ?? 'N/A',
          'windSpeed': data['wind_speed(mph)'] ?? 0.0,
          'precipitation': data['precipitation(in)'] ?? 0.0,
        };

        // Simulate severity prediction for testing
        severity = 3.5; // Example severity prediction
        errorMessage = ''; // Reset error message
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching weather data.';
        isLoading = false;
      });
    }
  }

  // Function to get severity color
  Color getSeverityColor(double? severity) {
    if (severity == null) return Colors.black; // Default color if severity is null
    return severity > 3.0 ? Colors.red : Colors.green;
  }

  // Submit handler
  void handleSearchSubmit() {
    if (streetName.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please enter a street name.';
      });
    } else {
      fetchGeolocation(streetName); // Fetch the geolocation based on street name
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Street Alert Search'),
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
              // Row to place TextField and Button inline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Street Name Input
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter street name',
                        labelStyle: TextStyle(color: Colors.grey[700]),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          streetName = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10), // Space between TextField and Button

                  // Submit Button
                  ElevatedButton(
                    onPressed: handleSearchSubmit,
                    child: Text('Get Weather Data'),
                    style: ElevatedButton.styleFrom(primary: Colors.teal),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Error message if any
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: TextStyle(color: Colors.red)),

              // Loading indicator
              if (isLoading) Center(child: CircularProgressIndicator()),

              // Display weather data
              if (weatherData != null)
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
                            buildWeatherRow("Weather Condition", weatherData!['condition']),
                            buildWeatherRow("Temperature", "${weatherData!['temperature']}°F"),
                            buildWeatherRow("Humidity", "${weatherData!['humidity']}%"),
                            buildWeatherRow("Wind Chill", "${weatherData!['windChill']}°F"),
                            buildWeatherRow("Pressure", "${weatherData!['pressure']} in"),
                            buildWeatherRow("Visibility", "${weatherData!['visibility']} mi"),
                            buildWeatherRow("Wind Direction", weatherData!['windDirection']),
                            buildWeatherRow("Wind Speed", "${weatherData!['windSpeed']} mph"),
                            buildWeatherRow("Precipitation", "${weatherData!['precipitation']} in"),

                            // Display severity prediction
                            if (severity != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  children: [
                                    Icon(FontAwesomeIcons.exclamationTriangle, color: getSeverityColor(severity)),
                                    SizedBox(width: 20),
                                    Text(
                                      "Predicted Severity: ${severity!.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: getSeverityColor(severity)),
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
}
