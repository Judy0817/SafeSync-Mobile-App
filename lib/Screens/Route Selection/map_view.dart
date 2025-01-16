import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';

class MapPage extends StatefulWidget {
  final String startPoint;
  final String endPoint;

  MapPage({required this.startPoint, required this.endPoint});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late Set<Marker> _markers;
  late Set<Polyline> _polylines;

  // Initial camera position to center the map
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default to San Francisco
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _markers = {};
    _polylines = {};
    _fetchRouteData();
  }

  // Fetch route data from the API
  Future<void> _fetchRouteData() async {
    final start = widget.startPoint.replaceAll(' ', '+');
    final end = widget.endPoint.replaceAll(' ', '+');
    final url = '${ApiConfig.baseUrl}/json/route?origin=$start&destination=$end';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> routeData = json.decode(response.body);
      List<dynamic> routePoints = routeData['route_points'];

      // Create markers for start and end points
      final startLatLng = LatLng(routeData['start_lat_lng']['lat'], routeData['start_lat_lng']['lng']);
      final endLatLng = LatLng(routeData['end_lat_lng']['lat'], routeData['end_lat_lng']['lng']);

      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('start'),
          position: startLatLng,
          infoWindow: InfoWindow(title: widget.startPoint),
        ));

        _markers.add(Marker(
          markerId: MarkerId('end'),
          position: endLatLng,
          infoWindow: InfoWindow(title: widget.endPoint),
        ));

        // Create polyline for the route
        List<LatLng> polylinePoints = routePoints.map((point) {
          return LatLng(point['lat'], point['lng']);
        }).toList();

        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ));
      });

      // Move the camera to fit the route
      mapController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            routeData['start_lat_lng']['lat'],
            routeData['start_lat_lng']['lng'],
          ),
          northeast: LatLng(
            routeData['end_lat_lng']['lat'],
            routeData['end_lat_lng']['lng'],
          ),
        ),
        50.0,
      ));

      print('Fetching route data...');
      print('Route data loaded');
      print('Animating camera...');

    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load route data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map View"),
        backgroundColor: Colors.teal,
      ),
      body: GoogleMap(
        initialCameraPosition: _kInitialPosition,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}
