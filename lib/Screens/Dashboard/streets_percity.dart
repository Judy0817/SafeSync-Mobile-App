import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TopStreetsPerCity extends StatefulWidget {
  @override
  _TopStreetsPerCityState createState() => _TopStreetsPerCityState();
}

class _TopStreetsPerCityState extends State<TopStreetsPerCity> {
  List<String> cities = [];
  List<_StreetAccidentData> chartData = [];
  bool isLoadingCities = true;
  bool isLoadingStreets = true;
  String selectedCity = 'Abbeville';
  String enteredCity = '';

  @override
  void initState() {
    super.initState();
    fetchCities();
    fetchStreetsData(selectedCity); // Load default data for 'Abbeville'
  }

  Future<void> fetchCities() async {
    setState(() {
      isLoadingCities = true;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.194.221:8080/get_cities'));

      if (response.statusCode == 200) {
        print("Response body: ${response.body}"); // Log the response body
        final Map<String, dynamic> cityData = json.decode(response.body);

        // Check if 'cities' is a key in the map and extract it
        if (cityData.containsKey('cities') && cityData['cities'] is List) {
          setState(() {
            cities = List<String>.from(cityData['cities']);
            isLoadingCities = false;
          });
        } else {
          throw Exception('Failed to load cities: Unexpected response format');
        }
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingCities = false;
      });
      print("Error fetching cities: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching cities: $e")),
      );
    }
  }


  Future<void> fetchStreetsData(String city) async {
    setState(() {
      isLoadingStreets = true;
      chartData = [];
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.194.221:8080/top_10_streets_per_city?city=$city'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Response data: $data"); // Debugging line

        if (data['data'] is List && data['labels'] is List) {
          final accidents = List<int>.from(data['data']);
          final streets = List<String>.from(data['labels']);

          setState(() {
            chartData = List.generate(streets.length, (index) {
              return _StreetAccidentData(streets[index], accidents[index]);
            });
            isLoadingStreets = false;
          });
        } else {
          throw Exception('Failed to load data: Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingStreets = false;
      });
      print("Error fetching streets data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching streets data: $e"))
      );
    }
  }

  void onSearchSubmit() {
    // Trim the entered city to remove leading/trailing spaces
    final normalizedEnteredCity = enteredCity.trim().toLowerCase();

    // Find the matched city in a case-insensitive manner
    final matchedCity = cities.firstWhere(
          (city) => city.toLowerCase() == normalizedEnteredCity,
      orElse: () => '',
    );

    if (matchedCity.isNotEmpty) {
      setState(() {
        selectedCity = matchedCity;
      });
      fetchStreetsData(matchedCity); // Fetch data for the selected city
    } else {
      setState(() {
        chartData = []; // Clear the chart data if the city is not found
      });
      print("City not found in the list.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("City not found in the list.")),
      );
    }
  }


  Widget buildChart(String city, List<_StreetAccidentData> data) {
    if (data.isEmpty) {
      return Center(child: Text("No data available for $city."));
    }

    return Container(
      height: 300,
      child: SfCartesianChart(
        backgroundColor: Colors.transparent,
        plotAreaBackgroundColor: Colors.transparent,
        margin: EdgeInsets.symmetric(vertical: 20),
        primaryXAxis: CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
          labelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(width: 0),
          labelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        title: ChartTitle(
          text: 'Top 10 Streets for Accidents in $city',
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        legend: Legend(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries<_StreetAccidentData, String>>[
          BarSeries<_StreetAccidentData, String>(
            dataSource: data,
            xValueMapper: (_StreetAccidentData data, _) => data.street,
            yValueMapper: (_StreetAccidentData data, _) => data.accidents,
            color: Color.fromRGBO(21, 72, 103, 1.0),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Top Streets per City"),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              isLoadingCities
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search City",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          enteredCity = value;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: onSearchSubmit,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              isLoadingStreets
                  ? Center(child: CircularProgressIndicator())
                  : buildChart(selectedCity, chartData),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreetAccidentData {
  _StreetAccidentData(this.street, this.accidents);

  final String street;
  final int accidents;
}
