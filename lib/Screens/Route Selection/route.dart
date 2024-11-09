// lib/result_page.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'city.dart';

class ResultPage extends StatefulWidget {
  final String startPoint;
  final String endPoint;

  // Constructor
  ResultPage({required this.startPoint, required this.endPoint});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<String> routeCities = [];
  List<City> selectedCities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRouteCities();
  }

  // Function to load route cities and select 3 random cities
  Future<void> _loadRouteCities() async {
    try {
      String jsonString = await rootBundle.loadString('assets/cities.json');
      final jsonResponse = json.decode(jsonString);
      List<dynamic> citiesList = jsonResponse['cities'];
      List<City> allCities = citiesList.map((cityJson) => City.fromJson(cityJson)).toList();

      allCities.removeWhere((city) =>
      city.cityName.toLowerCase() == widget.startPoint.toLowerCase() ||
          city.cityName.toLowerCase() == widget.endPoint.toLowerCase());

      if (allCities.length < 3) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough cities to display route steps.')),
        );
        return;
      }

      allCities.shuffle(Random());
      selectedCities = allCities.take(3).toList();

      setState(() {
        routeCities = selectedCities.map((city) => city.cityName).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading cities.json: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load route steps.')),
      );
    }
  }

  // Function to show weather information in a dialog
  void _showWeatherInfoDialog(City city) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${city.cityName} Weather Information', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Temperature: ${city.temperature}°F', style: TextStyle(color: Colors.black)),
              Text('Pressure: ${city.pressure} hPa', style: TextStyle(color: Colors.black)),
              Text('Wind Direction: ${city.windDirection}', style: TextStyle(color: Colors.black)),
              Text('Condition: ${city.weatherCondition}', style: TextStyle(color: Colors.black)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Details', style: TextStyle(color: Colors.white)),  // Ensure text is visible on the teal background
        centerTitle: true,
        backgroundColor: Colors.teal,  // Match MapPage's background color
      ),
      body: Container(
        color: Colors.teal.shade50,  // Light background to match MapPage's theme
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Point: ${widget.startPoint}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),  // Black text for contrast
            ),
            SizedBox(height: 16),
            Text(
              'Route:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: routeCities.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white,  // White background for cards
                    child: ListTile(
                      leading: Icon(Icons.location_city, color: Colors.teal),  // Match icon color with MapPage
                      title: Text(
                        routeCities[index],
                        style: TextStyle(fontSize: 18, color: Colors.black),  // Dark text for better visibility
                      ),
                      onTap: () {
                        _showWeatherInfoDialog(selectedCities[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'End Point: ${widget.endPoint}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  primary: Colors.teal,  // Match button color with MapPage
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
