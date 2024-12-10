import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';

class WeatherConditions extends StatefulWidget {
  @override
  _WeatherConditionsState createState() => _WeatherConditionsState();
}

class _WeatherConditionsState extends State<WeatherConditions> {
  List<_WeatherData> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/weather/weather_conditions'));
    // to get this url run the ipconfig in the terminal and then copy ipv4 address

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['data'] is List && data['labels'] is List) {
        final List<int> conditionsList = List<int>.from(data['data']);
        final List<String> conditionLabels = List<String>.from(data['labels']);
        final int totalValue = conditionsList.fold(0, (sum, value) => sum + value);

        setState(() {
          chartData = List.generate(conditionLabels.length, (index) {
            double percentage = (conditionsList[index] / totalValue) * 100;
            return _WeatherData(conditionLabels[index], conditionsList[index], percentage);
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
      appBar: AppBar(
        title: Text('Weather Conditions'),
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
        child: Center(
          child: Container(
            height: 300,
            width: MediaQuery.of(context).size.width * 0.9,
            child: SfCircularChart(
              title: ChartTitle(
                text: 'Weather Conditions',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CircularSeries<_WeatherData, String>>[
                DoughnutSeries<_WeatherData, String>(
                  dataSource: chartData,
                  xValueMapper: (_WeatherData data, _) => data.condition,
                  yValueMapper: (_WeatherData data, _) => data.value,
                  dataLabelMapper: (_WeatherData data, _) => '${data.percentage.toStringAsFixed(1)}%',
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                  pointColorMapper: (_WeatherData data, _) => _getColor(data.condition),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColor(String condition) {
    switch (condition) {
      case 'Fair':
        return Colors.green;
      case 'Mostly Cloudy':
        return Colors.blue;
      case 'Cloudy':
        return Colors.grey;
      case 'Clear':
        return Colors.yellow;
      case 'Partly Cloudy':
        return Colors.orange;
      case 'Overcast':
        return Colors.black;
      default:
        return Colors.purple; // Default color for "Others"
    }
  }
}

class _WeatherData {
  final String condition;
  final int value;
  final double percentage;

  _WeatherData(this.condition, this.value, this.percentage);
}

void main() {
  runApp(MaterialApp(
    home: WeatherConditions(),
  ));
}
