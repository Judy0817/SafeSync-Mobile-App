import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';

class WeatherChart extends StatefulWidget {
  const WeatherChart({Key? key}) : super(key: key);

  @override
  State<WeatherChart> createState() => _WeatherChartState();
}

class _WeatherChartState extends State<WeatherChart> {
  String selectedFeature = "Wind_Direction";
  List<int> data = [];
  List<String> labels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData(selectedFeature);
  }

  Future<void> fetchData(String feature) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/weather/weather_conditions_count?weather_feature=$feature");
    final response = await http.get(url);
    isLoading = true;
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        data = List<int>.from(jsonData["data"]);
        labels = List<String>.from(jsonData["labels"]);
        isLoading = false;
      });
    } else {
      print("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
      appBar: AppBar(
        title: const Text("Weather Conditions Chart"),
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
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Dropdown for weather feature selection
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: selectedFeature,
                        items: <String>[
                          'Temperature(F)',
                          'Wind_Chill(F)',
                          'Humidity(%)',
                          'Pressure(in)',
                          'Visibility(mi)',
                          'Wind_Direction',
                          'Wind_Speed(mph)',
                          'Precipitation(in)',
                          'Weather_Condition'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedFeature = value;
                            });
                            fetchData(selectedFeature);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Displaying the bar chart
                    SizedBox(
                      height: 500, // Set the desired height for the chart
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
                          title: AxisTitle(text: selectedFeature),
                        ),
                        primaryYAxis: NumericAxis(
                          majorGridLines: MajorGridLines(width: 0),
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          title: AxisTitle(text: 'Count'),
                        ),
                        title: ChartTitle(
                          text: 'Weather Conditions by $selectedFeature',
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<ChartData, String>>[
                          BarSeries<ChartData, String>(
                            dataSource: List.generate(labels.length,
                                    (index) => ChartData(labels[index], data[index])),
                            xValueMapper: (ChartData data, _) => data.label,
                            yValueMapper: (ChartData data, _) => data.value,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            color: Color.fromRGBO(21, 72, 103, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// Data model for chart
class ChartData {
  final String label;
  final int value;
  ChartData(this.label, this.value);
}
