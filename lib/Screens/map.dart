import 'package:flutter/material.dart';

import 'Dashboard/route.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();

  String? _startPoint;
  String? _endPoint;

  void _onSubmit() {
    String startPoint = _startController.text;
    String endPoint = _endController.text;

    // Navigate to the ResultPage and pass the start and end points
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(startPoint: startPoint, endPoint: endPoint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Start and End Points'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _startController,
              decoration: InputDecoration(
                labelText: 'Start Point',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _endController,
              decoration: InputDecoration(
                labelText: 'End Point',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSubmit,
              child: Text('Enter'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: MapPage(),
  ));
}
