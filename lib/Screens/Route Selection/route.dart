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
          title: Text('${city.cityName} Weather Information', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Temperature: ${city.temperature}°F'),
              Text('Pressure: ${city.pressure} hPa'),
              Text('Wind Direction: ${city.windDirection}'),
              Text('Condition: ${city.weatherCondition}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
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
        title: Text('Route Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Point: ${widget.startPoint}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 16),

            Text(
              'Route:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: routeCities.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.location_city, color: Colors.blueAccent),
                      title: Text(
                        routeCities[index],
                        style: TextStyle(fontSize: 16),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),

            SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
