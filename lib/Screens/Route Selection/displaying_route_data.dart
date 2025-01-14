import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';

class ResultPage extends StatefulWidget {
  final String startPoint;
  final String endPoint;

  ResultPage({required this.startPoint, required this.endPoint});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Future<Map<String, dynamic>> _routeData;
  late Future<Map<String, double>> _averageSeverities;

  Future<Map<String, dynamic>> _fetchRouteData() async {
    final String starting = widget.startPoint.replaceAll(' ', '+');
    final String destination = widget.endPoint.replaceAll(' ', '+');

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$starting&destination=$destination&key=example-key';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Parse the relevant route data from the response
      final routes = data['routes'] as List;
      if (routes.isNotEmpty) {
        final route = routes[0]; // Assuming the first route is the desired one
        final legs = route['legs'] as List;
        if (legs.isNotEmpty) {
          final leg = legs[0]; // First leg of the route
          final steps = leg['steps'] as List;

          // Extract street names from the steps
          Map<String, dynamic> streetData = {};
          for (var step in steps) {
            final streetName = step['html_instructions'] ?? 'Unknown';
            streetData[streetName] = step;
          }
          return streetData;
        }
      }
      throw Exception('No valid route found');
    } else {
      throw Exception('Failed to load route data');
    }
  }

  Future<double> _fetchSeverity(Map<String, dynamic> streetData) async {
    final weather = streetData['weather'] as Map<String, dynamic>;
    final roadFeatures = streetData['road_features'] as Map<String, dynamic>;

    // Map weather data
    final queryParams = {
      'temperature': weather['temperature(F)']?.toString() ?? '0',
      'pressure': weather['pressure(in)']?.toString() ?? '0',
      'wind_direction': weather['wind_direction'] ?? 'Unknown',
      'wind_speed': weather['wind_speed(mph)']?.toString() ?? '0',
      'weather_condition': weather['weather'] ?? 'Unknown',
      // Convert road features to query parameters
      ...roadFeatures.map((key, value) => MapEntry(key, value.toString())),
    };

    // Build the URI
    final url = Uri(
      scheme: 'http',
      host: '192.168.54.99',
      port: 8080,
      path: '/json/calculate_severity',
      queryParameters: queryParams,
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['severity'].toDouble();
    } else {
      throw Exception('Failed to calculate severity: ${response.body}');
    }
  }

  Future<Map<String, double>> _calculateAverageSeverities(Map<String, dynamic> routeData) async {
    final Map<String, double> averageSeverities = {};

    for (final street in routeData.keys) {
      final streetData = routeData[street] as Map<String, dynamic>;
      final severities = <double>[];

      // Assuming multiple weather conditions exist per street (update if needed)
      severities.add(await _fetchSeverity(streetData));

      final avgSeverity = severities.reduce((a, b) => a + b) / severities.length;
      averageSeverities[street] = avgSeverity;
    }

    return averageSeverities;
  }

  @override
  void initState() {
    super.initState();
    _routeData = _fetchRouteData();
    _averageSeverities = _routeData.then(_calculateAverageSeverities);
  }

  Widget _buildAverageSeverityRow(String street, double averageSeverity) {
    return ListTile(
      title: Text(
        street.replaceAll('%20', ' '),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Average Severity: ${averageSeverity.toStringAsFixed(2)}',
        style: TextStyle(fontSize: 16),
      ),
      trailing: Icon(Icons.info_outline, color: Colors.teal),
      onTap: () {
        _showDetailsDialog(context, street, {});
      },
    );
  }

  Widget _buildFeatureRow(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Future<void> _showDetailsDialog(BuildContext context, String street, Map<String, dynamic> data) async {
    final roadFeatures = data['road_features'] as Map<String, dynamic>;
    final weather = data['weather'] as Map<String, dynamic>;

    try {
      final severity = await _fetchSeverity(data);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(street.replaceAll('%20', ' ')),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Severity:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(severity.toStringAsFixed(2), style: TextStyle(fontSize: 16, color: Colors.red)),
                  Text('Road Features:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...roadFeatures.entries.map((entry) => _buildFeatureRow(entry.key, entry.value)),
                  Divider(height: 20, thickness: 1, color: Colors.grey.shade300),
                  Text('Weather:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Temperature: ${weather['temperature(F)']}°F', style: TextStyle(fontSize: 16)),
                  Text('Pressure: ${weather['pressure(in)']} inHg', style: TextStyle(fontSize: 16)),
                  Text('Wind Direction: ${weather['wind_direction']}', style: TextStyle(fontSize: 16)),
                  Text('Wind Speed: ${weather['wind_speed(mph)']} mph', style: TextStyle(fontSize: 16)),
                  Text('Weather Condition: ${weather['weather']}', style: TextStyle(fontSize: 16)),
                  Divider(height: 20, thickness: 1, color: Colors.grey.shade300),
                ],
              ),
            ),
            actions: [
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
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to calculate severity: $error'),
            actions: [
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

  Widget _buildStreetEntry(String street, Map<String, dynamic> data) {
    return ListTile(
      title: Text(
        street.replaceAll('%20', ' '),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.info_outline, color: Colors.teal),
      onTap: () {
        _showDetailsDialog(context, street, data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Data'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _routeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return FutureBuilder<Map<String, double>>(
              future: _calculateAverageSeverities(data),
              builder: (context, severitySnapshot) {
                if (severitySnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (severitySnapshot.hasError) {
                  return Center(child: Text('Error: ${severitySnapshot.error}'));
                } else if (severitySnapshot.hasData) {
                  final averageSeverities = severitySnapshot.data!;

                  double overallAverageSeverity = averageSeverities.values.isNotEmpty
                      ? averageSeverities.values.reduce((a, b) => a + b) /
                      averageSeverities.length
                      : 0.0;

                  return ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      ...data.entries.map((entry) {
                        return _buildStreetEntry(entry.key, entry.value);
                      }).toList(),
                      Divider(
                        height: 20,
                        thickness: 2,
                        color: Colors.grey,
                      ),
                      Text(
                        'Overall Average Severity:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          overallAverageSeverity.toStringAsFixed(2),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: Text('No severity data found'));
                }
              },
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}
