import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Reusable/reusable.dart';
import '../../config.dart';

class CityAccidentsChart extends StatefulWidget {
  @override
  _CityAccidentsChartState createState() => _CityAccidentsChartState();
}

class _CityAccidentsChartState extends State<CityAccidentsChart> {
  List<_CityAccidentsData> chartData = [];
  bool isLoading = true;
  String selectedOption = 'City'; // Default selection

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch initial data
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final uri = selectedOption == 'City'
        ? Uri.parse('${ApiConfig.baseUrl}/top_city')
        : Uri.parse('${ApiConfig.baseUrl}/top_street');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['data'] is List && data['labels'] is List) {
        final accidents = List<int>.from(data['data']);
        final labels = List<String>.from(data['labels']);

        setState(() {
          chartData = List.generate(labels.length, (index) {
            return _CityAccidentsData(labels[index], accidents[index]);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Top 20 Accident Chart'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
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
              padding: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<String>(
                      value: selectedOption,
                      items: ['City', 'Street'].map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedOption = newValue!;
                          fetchData(); // Fetch data based on selection
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SizedBox(
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
                          ),
                          primaryYAxis: NumericAxis(
                            majorGridLines: MajorGridLines(width: 0),
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          title: ChartTitle(
                            text: selectedOption == 'City'
                                ? 'Top 20 Cities'
                                : 'Top 20 Streets',
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          legend: Legend(isVisible: false),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries<_CityAccidentsData, String>>[
                            BarSeries<_CityAccidentsData, String>(
                              dataSource: chartData,
                              xValueMapper: (_CityAccidentsData data, _) => data.city,
                              yValueMapper: (_CityAccidentsData data, _) => data.accidents,
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityAccidentsData {
  _CityAccidentsData(this.city, this.accidents);

  final String city;
  final int accidents;
}
