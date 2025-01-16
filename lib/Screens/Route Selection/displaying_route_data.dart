import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';
import 'map_view.dart';
import 'map_view.dart';  // Import the new MapPage

class ResultPage extends StatefulWidget {
  final String startPoint;
  final String endPoint;

  ResultPage({required this.startPoint, required this.endPoint});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? _distance;
  String? _duration;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRouteData();
  }

  // Fetch route data from the API
  Future<void> _fetchRouteData() async {
    final start = widget.startPoint.replaceAll(' ', '+');
    final end = widget.endPoint.replaceAll(' ', '+');
    final url = '${ApiConfig.baseUrl}/json/route?origin=$start&destination=$end';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> routeData = json.decode(response.body);
      setState(() {
        _distance = routeData['distance'];
        _duration = routeData['duration'];
        _isLoading = false;
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load route data')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget to display each route detail
  Widget _buildRouteDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
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
        title: Text('Route Information'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 10),
            Card(
              color: Colors.white.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route 01 : ',
                      style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildRouteDetail('Start:', widget.startPoint),
                    _buildRouteDetail('End:', widget.endPoint),
                    SizedBox(height: 30),
                    _buildRouteDetail('Distance:', _distance ?? 'Loading...'),
                    _buildRouteDetail('Duration:', _duration ?? 'Loading...'),
                    SizedBox(height: 20),
                    _buildRouteDetail('Seveirity:', _duration ?? 'Loading...'),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the MapPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(
                              startPoint: widget.startPoint,
                              endPoint: widget.endPoint,
                            ),
                          ),
                        );
                      },
                      child: Text("View on Map"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal, // button color
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}
