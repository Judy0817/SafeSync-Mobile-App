import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StreetAlertSearch extends StatefulWidget {
  @override
  _StreetAlertSearchState createState() => _StreetAlertSearchState();
}

class _StreetAlertSearchState extends State<StreetAlertSearch> {
  Map<String, dynamic>? alertInfo;
  Map<String, dynamic> streetData = {};
  List<String> matchingStreets = [];
  String query = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    setState(() {
      isLoading = true;
    });

    // Load JSON file from assets
    final String response = await rootBundle.loadString('assets/average_street_weather.json');
    final data = json.decode(response) as Map<String, dynamic>;

    setState(() {
      streetData = data;
      isLoading = false;
    });
  }

  void searchMatchingStreets(String searchTerm) {
    setState(() {
      query = searchTerm;
      matchingStreets = streetData.keys
          .where((street) => street.toLowerCase().startsWith(searchTerm.toLowerCase()))
          .toList();
      alertInfo = null; // Clear previous alert info
    });
  }

  void selectStreet(String streetName) {
    setState(() {
      query = streetName;
      alertInfo = streetData[streetName];
      matchingStreets = []; // Clear suggestions after selection
    });
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
              // Search field
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search street name...',
                  labelStyle: TextStyle(color: Colors.grey[700]), // Adjust label color
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  searchMatchingStreets(value);
                },
              ),
              SizedBox(height: 10),

              // Matching streets list
              if (matchingStreets.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: matchingStreets.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(matchingStreets[index]),
                        onTap: () {
                          selectStreet(matchingStreets[index]);
                        },
                      );
                    },
                  ),
                ),
              SizedBox(height: 20),

              // Display alert info or loading indicator
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : alertInfo != null
                  ? Expanded(
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
                              SizedBox(width: 10),
                              Text(
                                "Alert Information for ${query}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          buildAlertRow(
                            "Severity",
                            "${alertInfo!['Severity']}",
                            icon: FontAwesomeIcons.exclamationTriangle,
                            color: alertInfo!['Severity'] >= 4 ? Colors.red : Colors.green,
                          ),
                          buildAlertRow("Weather", "${alertInfo!['Weather_Condition']}", icon: FontAwesomeIcons.cloud),
                          buildAlertRow("Temperature", "${alertInfo!['Temperature(F)']}°F", icon: FontAwesomeIcons.thermometerHalf),
                          buildAlertRow("Humidity", "${alertInfo!['Humidity(%)']}%", icon: FontAwesomeIcons.tint),
                          buildAlertRow("Wind Chill", "${alertInfo!['Wind_Chill(F)']}°F", icon: FontAwesomeIcons.wind),
                          buildAlertRow("Pressure", "${alertInfo!['Pressure(in)']} in", icon: FontAwesomeIcons.compressArrowsAlt),
                          buildAlertRow("Visibility", "${alertInfo!['Visibility(mi)']} mi", icon: FontAwesomeIcons.eye),
                          buildAlertRow("Wind Direction", "${alertInfo!['Wind_Direction']}", icon: FontAwesomeIcons.compass),
                          buildAlertRow("Wind Speed", "${alertInfo!['Wind_Speed(mph)']} mph", icon: FontAwesomeIcons.wind),
                          buildAlertRow("Precipitation", "${alertInfo!['Precipitation(in)']} in", icon: FontAwesomeIcons.cloudRain),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  : query.isNotEmpty
                  ? Text("No match found", style: TextStyle(color: Colors.red))
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAlertRow(String label, String value, {required IconData icon, Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              "$label: ",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
