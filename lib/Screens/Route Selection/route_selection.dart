import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'displaying_route_data.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();

  String? _startPoint;
  String? _endPoint;

  void _onSubmit() {
    String startPoint = _startController.text.trim();
    String endPoint = _endController.text.trim();

    // Navigate to the ResultPage and pass the start and end points
    if (startPoint.isNotEmpty && endPoint.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(startPoint: startPoint, endPoint: endPoint),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both start and end points')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Planner'),
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
              Color(0xFF0DE4C7),
              Color(0xFF5712A7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30),
            _buildTextField(_startController, 'Start Point'),
            SizedBox(height: 16),
            _buildTextField(_endController, 'End Point'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onSubmit,
              child: Text('Enter'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                primary: Colors.teal.shade700,  // Button color to match app bar
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white), // Text color inside text field
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white), // Label text color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.teal.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.teal.shade200, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MapPage(),
  ));
}
