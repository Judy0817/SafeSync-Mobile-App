import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';

class AverageWindSpeed extends StatefulWidget {
  @override
  _AverageWindSpeedState createState() => _AverageWindSpeedState();
}

class _AverageWindSpeedState extends State<AverageWindSpeed> {
  List<_WindSpeedData> chartData = [];
  bool isLoading = true;
  String selectedTimeOfDay = "afternoon"; // Default time of day

  // Define available times of day
  final List<String> timesOfDay = ["morning", "afternoon", "evening", "night"];

  @override
  void initState() {
    super.initState();
    fetchWindSpeedData();
  }

  Future<void> fetchWindSpeedData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/weather/average_wind_speed'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final averageWindSpeeds = data['average_wind_speeds'] as List;

        // Filter data for selected time of day and prepare chart data
        setState(() {
          chartData = averageWindSpeeds
              .where((item) => item['time_of_day'] == selectedTimeOfDay)
              .map((item) => _WindSpeedData(
            'Severity ${item['severity']}',
            item['average_wind_speed'].toDouble(),
          ))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching wind speed data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching wind speed data: $e")),
      );
    }
  }

  Widget buildChart(List<_WindSpeedData> data) {
    if (data.isEmpty) {
      return Center(child: Text("No data available."));
    }

    return Container(
      height: 300,
      child: SfCircularChart(
        backgroundColor: Colors.transparent,
        title: ChartTitle(
          text: 'Average Wind Speed for $selectedTimeOfDay',
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        legend: Legend(isVisible: true),
        series: <PieSeries<_WindSpeedData, String>>[
          PieSeries<_WindSpeedData, String>(
            dataSource: data,
            xValueMapper: (_WindSpeedData windSpeedData, _) => windSpeedData.severity,
            yValueMapper: (_WindSpeedData windSpeedData, _) => windSpeedData.value,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            dataLabelMapper: (_WindSpeedData severityData, _) =>
                severityData.value.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Average Wind Speed by Time of Day"),
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
              // Dropdown for selecting time of day
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedTimeOfDay,
                  icon: Icon(Icons.arrow_downward, color: Colors.white),
                  dropdownColor: Colors.teal,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  underline: Container(
                    height: 2,
                    color: Colors.white,
                  ),
                  items: timesOfDay.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newTimeOfDay) {
                    if (newTimeOfDay != null) {
                      setState(() {
                        selectedTimeOfDay = newTimeOfDay;
                        fetchWindSpeedData(); // Fetch data for selected time of day
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : buildChart(chartData),
            ],
          ),
        ),
      ),
    );
  }
}

class _WindSpeedData {
  _WindSpeedData(this.severity, this.value);

  final String severity;
  final double value;
}
