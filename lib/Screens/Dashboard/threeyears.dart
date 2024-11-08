import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';

class ThreeYearsAccidents extends StatefulWidget {
  @override
  _ThreeYearsAccidentsState createState() => _ThreeYearsAccidentsState();
}

class _ThreeYearsAccidentsState extends State<ThreeYearsAccidents> {
  List<_AccidentData> chartData = [];
  bool isLoading = true;
  int selectedYear = 2019;

  @override
  void initState() {
    super.initState();
    fetchData(selectedYear);
  }

  Future<void> fetchData(int year) async {
    setState(() {
      isLoading = true;
      chartData = []; // Clear previous data
    });

    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/accidents_$year'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['data'] is List && data['labels'] is List) {
        final accidents = List<int>.from(data['data']);
        final months = List<String>.from(data['labels']);

        setState(() {
          chartData = List.generate(months.length, (index) {
            return _AccidentData(months[index], accidents[index]);
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

  Widget buildChart(String title, List<_AccidentData> data) {
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
          text: title,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        legend: Legend(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries<_AccidentData, String>>[
          AreaSeries<_AccidentData, String>(
            dataSource: data,
            xValueMapper: (_AccidentData data, _) => data.month,
            yValueMapper: (_AccidentData data, _) => data.accidents,
            dataLabelSettings: DataLabelSettings(
              isVisible: false,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Color.fromRGBO(21, 72, 103, 1.0),
            borderColor: Colors.black,
            borderWidth: 2,
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(21, 72, 103, 0.6),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            markerSettings: MarkerSettings(
              isVisible: true,
              color: Colors.black,
              borderWidth: 2,
              borderColor: Colors.black,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
      appBar: AppBar(
        title: Text("Accidents Data"),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<int>(
                  value: selectedYear,
                  dropdownColor: Colors.teal,
                  style: TextStyle(color: Colors.white),
                  items: [2019, 2020, 2021, 2022, 2023]
                      .map((year) => DropdownMenuItem<int>(
                    value: year,
                    child: Text(
                      '$year',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (int? newYear) {
                    if (newYear != null) {
                      setState(() {
                        selectedYear = newYear;
                      });
                      fetchData(selectedYear);
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: buildChart('Accidents in $selectedYear', chartData),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccidentData {
  _AccidentData(this.month, this.accidents);

  final String month;
  final int accidents;
}
