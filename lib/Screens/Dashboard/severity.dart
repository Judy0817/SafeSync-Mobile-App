import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';

class SeverityDistribution extends StatefulWidget {
  @override
  _SeverityDistributionState createState() => _SeverityDistributionState();
}

class _SeverityDistributionState extends State<SeverityDistribution> {
  List<_SeverityData> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/severity_distribution'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['data'] is List && data['labels'] is List) {
        final List<int> severityList = List<int>.from(data['data']);
        final List<String> severityLabels = List<String>.from(data['labels']);

        setState(() {
          chartData = List.generate(severityLabels.length, (index) {
            return _SeverityData(severityLabels[index], severityList[index]);
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
    // Define the colors from the provided color strings
    Color color4 = Color.fromRGBO(153, 102, 255, 1.0); // 'rgb(153, 102, 255)'
    Color color2 = Color.fromRGBO(21, 72, 103, 1.0); // 'rgba(211, 133, 222, 0.8)'
    Color color1 = Color.fromRGBO(222, 133, 179, 0.8); // 'rgba(222, 133, 179, 0.8)'
    Color color3 = Colors.purple ;// 'aqua'

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
      appBar: AppBar(
        title: Text('Severity Distribution'),
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
                child: SizedBox(
                  height: 500, // Set the desired height for the chart
                  child: SfCircularChart(
                    title: ChartTitle(text: 'Severity Distribution', textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.transparent, // Remove black background color
                    legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap,
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CircularSeries<_SeverityData, String>>[
                      PieSeries<_SeverityData, String>(
                        dataSource: chartData,
                        xValueMapper: (_SeverityData data, _) => data.severityLabel,
                        yValueMapper: (_SeverityData data, _) => data.severity,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Customizing colors for each segment using pointColorMapper
                        pointColorMapper: (_SeverityData data, _) {
                          if (data.severityLabel == '1') {
                            return color1;
                          } else if (data.severityLabel == '2') {
                            return color2;
                          } else if (data.severityLabel == '3') {
                            return color3;
                          } else if (data.severityLabel == '4') {
                            return color4;
                          }
                          return Colors.transparent;
                        },
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

class _SeverityData {
  _SeverityData(this.severityLabel, this.severity);

  final String severityLabel;
  final int severity;
}
