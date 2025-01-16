import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';
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
  List<String> _streetNames = [];
  List<String> _filteredStartStreetNames = [];
  List<String> _filteredEndStreetNames = [];

  @override
  void initState() {
    super.initState();
    _fetchStreetNames();
  }

  // Fetch street names from the API
  Future<void> _fetchStreetNames() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/json/street_names'));

    if (response.statusCode == 200) {
      List<dynamic> streetNamesData = json.decode(response.body);
      setState(() {
        _streetNames = List<String>.from(streetNamesData);
        _filteredStartStreetNames = List.from(_streetNames);
        _filteredEndStreetNames = List.from(_streetNames);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load street names')),
      );
    }
  }

  // Filter street names based on user input (for start or end point)
  void _filterStreetNames(String query, bool isStartPoint) {
    setState(() {
      if (isStartPoint) {
        _filteredStartStreetNames = _streetNames
            .where((street) => street.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _filteredEndStreetNames = _streetNames
            .where((street) => street.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onSubmit() {
    String startPoint = _startController.text.trim();
    String endPoint = _endController.text.trim();

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
      body: SingleChildScrollView(
        child: Container(
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
              _buildTextField(_startController, 'Start Point', true),  // true for start point
              SizedBox(height: 16),
              _buildTextField(_endController, 'End Point', false),    // false for end point
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isStartPoint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: (value) => _filterStreetNames(value, isStartPoint),
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
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
        ),
        if ((isStartPoint ? _filteredStartStreetNames : _filteredEndStreetNames).isNotEmpty &&
            controller.text.isNotEmpty)
        // Overlay the dialog box on top without affecting the text field position
          Stack(
            children: [
              Container(), // Empty container to create space, don't affect layout
              Container(
                margin: EdgeInsets.only(top: 5), // Space between text field and dialog
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                height: 150,  // Limit the height of the list
                child: ListView.builder(
                  itemCount: isStartPoint
                      ? _filteredStartStreetNames.length
                      : _filteredEndStreetNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        isStartPoint
                            ? _filteredStartStreetNames[index]
                            : _filteredEndStreetNames[index],
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // Set the selected street name in the text field
                        controller.text = isStartPoint
                            ? _filteredStartStreetNames[index]
                            : _filteredEndStreetNames[index];

                        // Hide the dialog box by clearing the appropriate filtered list
                        setState(() {
                          if (isStartPoint) {
                            _filteredStartStreetNames.clear();  // Hide the start point dialog
                          } else {
                            _filteredEndStreetNames.clear();  // Hide the end point dialog
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
      ],
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
