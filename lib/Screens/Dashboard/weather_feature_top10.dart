import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class WeatherChart extends StatefulWidget {
  const WeatherChart({Key? key}) : super(key: key);

  @override
  State<WeatherChart> createState() => _WeatherChartState();
}

class _WeatherChartState extends State<WeatherChart> {
  String selectedFeature = "Wind_Direction";
  List<int> data = [];
  List<String> labels = [];

  @override
  void initState() {
    super.initState();
    fetchData(selectedFeature);
  }

  Future<void> fetchData(String feature) async {
    final url = Uri.parse("http://192.168.187.221:8080/weather_conditions_count?weather_feature=$feature");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        data = List<int>.from(jsonData["data"]);
        labels = List<String>.from(jsonData["labels"]);
      });
    } else {
      print("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Conditions Chart")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Dropdown for weather feature selection
            DropdownButton<String>(
              value: selectedFeature,
              items: <String>['Temperature(F)',
                'Wind_Chill(F)',
                'Humidity(%)',
                'Pressure(in)',
                'Visibility(mi)',
                'Wind_Direction',
                'Wind_Speed(mph)',
                'Precipitation(in)',
                'Weather_Condition'] // Add other features if available
                  .map<DropdownMenuItem<String>>((String value) {
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
            const SizedBox(height: 20),

            // Displaying the bar chart
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(title: AxisTitle(text: selectedFeature)),
                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Count')),
                series: <ChartSeries>[
                  BarSeries<ChartData, String>(
                    dataSource: List.generate(labels.length, (index) => ChartData(labels[index], data[index])),
                    xValueMapper: (ChartData data, _) => data.label,
                    yValueMapper: (ChartData data, _) => data.value,
                    color: Colors.blue,
                  ),
                ],
                title: ChartTitle(text: 'Weather Conditions by $selectedFeature'),
                tooltipBehavior: TooltipBehavior(enable: true),
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
