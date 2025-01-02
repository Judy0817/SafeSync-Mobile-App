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

  Future<Map<String, dynamic>> _fetchRouteData() async {
    final String starting = widget.startPoint.replaceAll(' ', '%20');
    final String destination = widget.endPoint.replaceAll(' ', '%20');

    final url =
        '${ApiConfig.baseUrl}/json/getStartingDestinationData?starting=$starting&destination=$destination';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load route data');
    }
  }

  @override
  void initState() {
    super.initState();
    _routeData = _fetchRouteData();
  }

  // Function to display feature row (check or cancel)
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

  // Function to show detailed data in a dialog when clicking a street
  void _showDetailsDialog(BuildContext context, String street, Map<String, dynamic> data) {
    final roadFeatures = data['road_features'] as Map<String, dynamic>;
    final weather = data['weather'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(street.replaceAll('%20', ' ')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Road Features:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...roadFeatures.entries.map((entry) => _buildFeatureRow(entry.key, entry.value)),
                Divider(height: 20, thickness: 1, color: Colors.grey.shade300),
                Text('Weather:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Temperature: ${weather['temperature(F)']}°F', style: TextStyle(fontSize: 16)),
                Text('Pressure: ${weather['pressure(in)']} inHg', style: TextStyle(fontSize: 16)),
                Text('Wind Direction: ${weather['wind_direction']}', style: TextStyle(fontSize: 16)),
                Text('Wind Speed: ${weather['wind_speed(mph)']} mph', style: TextStyle(fontSize: 16)),
                Text('Weather Condition: ${weather['weather']}', style: TextStyle(fontSize: 16)),
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
  }

  // Function to build each street entry as a clickable list tile
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
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: data.entries.map((entry) => _buildStreetEntry(entry.key, entry.value)).toList(),
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}
