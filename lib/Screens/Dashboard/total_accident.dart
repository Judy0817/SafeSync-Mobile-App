import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';

class TotalAccidentsPerYear extends StatefulWidget {
  @override
  _TotalAccidentsPerYearState createState() => _TotalAccidentsPerYearState();
}

class _TotalAccidentsPerYearState extends State<TotalAccidentsPerYear> {
  List<_AccidentData> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTotalAccidents();
  }

  Future<void> fetchTotalAccidents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/location/total_accidents'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Ensure the data contains 'data' and 'labels' fields
        if (data['data'] is List && data['labels'] is List) {
          final List<int> accidents = List<int>.from(data['data']);
          final List<String> years = List<String>.from(data['labels']);

          // Prepare chart data
          setState(() {
            chartData = List.generate(years.length, (index) {
              return _AccidentData(years[index], accidents[index]);
            });
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load data: Unexpected response format');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching total accidents: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching total accidents: $e")),
      );
    }
  }

  Widget buildChart(List<_AccidentData> data) {
    if (data.isEmpty) {
      return Center(child: Text("No data available."));
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
          text: 'Total Accidents per Year',
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        legend: Legend(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries<_AccidentData, String>>[
          BarSeries<_AccidentData, String>(
            dataSource: data,
            xValueMapper: (_AccidentData accidentData, _) => accidentData.year,
            yValueMapper: (_AccidentData accidentData, _) => accidentData.accidents,
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
        title: Text("Total Accidents per Year"),
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

class _AccidentData {
  _AccidentData(this.year, this.accidents);

  final String year;
  final int accidents;
}
