import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoadFeatures extends StatefulWidget {
  @override
  _RoadFeaturesState createState() => _RoadFeaturesState();
}

class _RoadFeaturesState extends State<RoadFeatures> {
  List<_FeaturesData> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://192.168.7.221:8080/road_features'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['data'] is List && data['labels'] is List) {
        final List<dynamic> accidentsList = data['data'];
        final List<String> featuresList = List<String>.from(data['labels']);

        setState(() {
          chartData = List.generate(featuresList.length, (index) {
            // Convert and truncate the double to int
            int accidents = accidentsList[index].toDouble().truncate(); // Truncate decimal part
            return _FeaturesData(featuresList[index], accidents);
          });
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: Unexpected response format');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
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
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 500, // Set the desired height for the chart
                  child: SfCartesianChart(
                    backgroundColor: Colors.transparent, // Remove black background color
                    plotAreaBackgroundColor: Colors.transparent, // Remove plot area background color
                    margin: EdgeInsets.symmetric(vertical: 20), // Add margin for additional space
                    primaryXAxis: CategoryAxis(
                      majorGridLines: MajorGridLines(width: 0), // Remove vertical grid lines
                      labelStyle: TextStyle(
                        color: Colors.white, // Set the x-axis labels to white
                        fontWeight: FontWeight.bold, // Set the x-axis labels to bold
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      majorGridLines: MajorGridLines(width: 0), // Remove horizontal grid lines
                      labelStyle: TextStyle(
                        color: Colors.white, // Set the y-axis labels to white
                        fontWeight: FontWeight.bold, // Set the y-axis labels to bold
                      ),
                    ),
                    title: ChartTitle(
                      text: 'Features',
                      textStyle: TextStyle(
                        color: Colors.white, // Set the title to white
                        fontWeight: FontWeight.bold, // Set the title to bold
                      ),
                    ),
                    legend: Legend(isVisible: false),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<_FeaturesData, String>>[
                      BarSeries<_FeaturesData, String>(
                        dataSource: chartData,
                        xValueMapper: (_FeaturesData data, _) => data.feature,
                        yValueMapper: (_FeaturesData data, _) => data.accidents,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            color: Colors.white, // Set the data labels to white
                            fontWeight: FontWeight.bold, // Set the data labels to bold
                          ),
                        ),
                          color: Color.fromRGBO(21, 72, 103, 1.0) // Set the bar color to dark blue
                      )
                    ],
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

class _FeaturesData {
  _FeaturesData(this.feature, this.accidents);

  final String feature;
  final int accidents;
}
