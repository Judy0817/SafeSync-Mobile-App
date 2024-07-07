import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:csv/csv.dart';

class CityAccidents {
  final String city;
  final int accidentCount;

  CityAccidents(this.city, this.accidentCount);

  factory CityAccidents.fromCsv(List<dynamic> csvLine) {
    return CityAccidents(
      csvLine[0].toString(),
      int.parse(csvLine[1].toString()),
    );
  }
}

class CityAccidentsChart extends StatefulWidget {
  @override
  _CityAccidentsChartState createState() => _CityAccidentsChartState();
}

class _CityAccidentsChartState extends State<CityAccidentsChart> {
  late List<CityAccidents> data;

  @override
  void initState() {
    super.initState();
    data = [];
    _loadCSVData();
  }

  Future<void> _loadCSVData() async {
    try {
      final csvData = await rootBundle.loadString('assets/cities_accidents.csv');
      List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

      List<CityAccidents> parsedData = csvTable.skip(1).map((row) => CityAccidents.fromCsv(row)).toList();

      setState(() {
        data = parsedData;
      });
    } catch (e) {
      print('Error loading CSV data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top 20 Cities by Accident Count'),
      ),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: charts.BarChart(
          [
            charts.Series<CityAccidents, String>(
              id: 'Accidents',
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (CityAccidents cityAccidents, _) => cityAccidents.city,
              measureFn: (CityAccidents cityAccidents, _) => cityAccidents.accidentCount,
              data: data,
            )
          ],
          animate: true,
        ),
      ),
    );
  }
}
