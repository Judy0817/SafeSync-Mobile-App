import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TopStreetsPerCity extends StatefulWidget {
  @override
  _TopStreetsPerCityState createState() => _TopStreetsPerCityState();
}

class _TopStreetsPerCityState extends State<TopStreetsPerCity> {
  List<String> cities = []; // List to hold city names
  List<String> filteredCities = []; // List for filtered city names based on search
  List<_StreetAccidentData> chartData = [];
  bool isLoadingCities = true;
  bool isLoadingStreets = true;
  String selectedCity = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    setState(() {
      isLoadingCities = true;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.187.221:8080/get_cities')); // Replace with your actual API endpoint for cities

      if (response.statusCode == 200) {
        final List<dynamic> cityData = json.decode(response.body);
        setState(() {
          cities = List<String>.from(cityData);
          filteredCities = List<String>.from(cityData);
          isLoadingCities = false;
        });
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingCities = false;
      });
      print("Error fetching cities: $e");
    }
  }

  Future<void> fetchStreetsData(String city) async {
    setState(() {
      isLoadingStreets = true;
      chartData = []; // Clear previous data
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.187.221:8080/top_10_streets_per_city?city=$city'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Response Data: $data"); // Debugging line

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
    }
  }

  void filterCities(String query) {
    setState(() {
      searchQuery = query;
      filteredCities = cities
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search City",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: filterCities,
                    ),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      hint: Text("Select City"),
                      value: selectedCity.isEmpty ? null : selectedCity,
                      dropdownColor: Colors.teal,
                      style: TextStyle(color: Colors.white),
                      items: filteredCities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            city,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newCity) {
                        if (newCity != null) {
                          setState(() {
                            selectedCity = newCity;
                          });
                          fetchStreetsData(selectedCity); // Fetch street data when a city is selected
                        }
                      },
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
