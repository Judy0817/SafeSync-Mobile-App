import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';

class AverageSeverityLevels extends StatefulWidget {
  @override
  _AverageSeverityLevelsState createState() => _AverageSeverityLevelsState();
}

class _AverageSeverityLevelsState extends State<AverageSeverityLevels> {
  List<_SeverityData> chartData = [];
  bool isLoading = true;
  String selectedFeature = "temperatures"; // Default feature

  // Define available weather features
  final List<String> features = ["temperatures", "humidities", "visibilities", "wind_speeds"];

  @override
  void initState() {
    super.initState();
    fetchSeverityData();
  }

  Future<void> fetchSeverityData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/weather/average_weather_severity'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final severities = data['severities'];
        final featureValues = data[selectedFeature];

        if (featureValues is List && severities is List) {
          setState(() {
            chartData = List.generate(severities.length, (index) {
              return _SeverityData('Severity ${severities[index]}', featureValues[index]);
            });
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching severity data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching severity data: $e")),
      );
    }
  }

  Widget buildChart(List<_SeverityData> data) {
    if (data.isEmpty) {
      return Center(child: Text("No data available."));
    }

    return Container(
      height: 300,
      child: SfCircularChart(
        backgroundColor: Colors.transparent,
        title: ChartTitle(
          text: 'Average $selectedFeature Values for each severity ',
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        legend: Legend(isVisible: true),
        series: <PieSeries<_SeverityData, String>>[
          PieSeries<_SeverityData, String>(
            dataSource: data,
            xValueMapper: (_SeverityData severityData, _) => severityData.severity,
            yValueMapper: (_SeverityData severityData, _) => severityData.value,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              labelIntersectAction: LabelIntersectAction.none,  // Prevent overlapping labels
              labelPosition: ChartDataLabelPosition.outside,   // Set label position
            ),
            // Use dataLabelMapper to round the value and format the label
            dataLabelMapper: (_SeverityData severityData, _) =>
                severityData.value.toStringAsFixed(1), // Round the value to one decimal
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Average Weather Values"),
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
              // Dropdown to select weather feature
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedFeature,
                  icon: Icon(Icons.arrow_downward, color: Colors.white),
                  dropdownColor: Colors.teal,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  underline: Container(
                    height: 2,
                    color: Colors.white,
                  ),
                  items: features.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newFeature) {
                    if (newFeature != null) {
                      setState(() {
                        selectedFeature = newFeature;
                        fetchSeverityData(); // Fetch data for selected feature
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

class _SeverityData {
  _SeverityData(this.severity, this.value);

  final String severity;
  final double value;
}
