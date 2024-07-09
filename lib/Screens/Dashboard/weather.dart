import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final response = await http.get(Uri.parse('http://192.168.145.221:8080/weather_conditions'));

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
            children: chartData.map((data) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: SizedBox(
                  height: 300,
                  child: CustomDoughnutChart(
                    data: data,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _WeatherData {
  final String condition;
  final int value;
  final double percentage;

  _WeatherData(this.condition, this.value, this.percentage);
}

class CustomDoughnutChart extends StatelessWidget {
  final _WeatherData data;

  CustomDoughnutChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: ChartTitle(
        text: '${data.condition} Condition',
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
          dataSource: [data],
          xValueMapper: (_WeatherData data, _) => data.condition,
          yValueMapper: (_WeatherData data, _) => data.percentage,
          dataLabelMapper: (_WeatherData data, _) => '${data.percentage.toStringAsFixed(1)}%', // Display percentage as label
          pointColorMapper: (_WeatherData data, _) => _getColor(data.percentage), // Assign color based on percentage
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Color _getColor(double percentage) {
    if (percentage >= 70) {
      return Colors.black; // Use black color for 70% and above
    } else {
      return Colors.green; // Use green color for below 70%
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: WeatherConditions(),
  ));
}
