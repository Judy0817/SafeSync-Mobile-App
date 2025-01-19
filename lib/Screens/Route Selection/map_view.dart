import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';

class MapPage extends StatefulWidget {
  final String startPoint;
  final String endPoint;

  MapPage({required this.startPoint, required this.endPoint});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(40.7126819, -74.006577), // default to start location of New York
    zoom: 14,
  );

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  List<LatLng> latLngPoints = [];

  @override
  void initState() {
    super.initState();
    _fetchRouteData();
  }

  Future<void> _fetchRouteData() async {
    final url =
        '${ApiConfig.baseUrl}/json/route?origin=${widget.startPoint}&destination=${widget.endPoint}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List routePoints = data['route_points'];
      print("Route Points: $routePoints");

      // Remove duplicates from the route points
      Set<LatLng> uniquePoints = Set<LatLng>();
      routePoints.forEach((point) {
        uniquePoints.add(LatLng(point['lat'], point['lng']));
      });

      setState(() {
        latLngPoints = uniquePoints.toList();
        print("Total Unique Route Points: ${latLngPoints.length}");

        // Fetch weather data for each point
        _fetchWeatherForRoutePoints();

        // Adding markers for the route points
        for (int i = 0; i < latLngPoints.length; i++) {
          _markers.add(
            Marker(
              markerId: MarkerId(i.toString()),
              position: latLngPoints[i],
              infoWindow: InfoWindow(
                title: 'Point $i',
                snippet: 'Lat: ${latLngPoints[i].latitude}, Lng: ${latLngPoints[i].longitude}',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        }

        // Adding polyline for the route
        _polyline.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: latLngPoints,
            color: Colors.green,
            width: 5,
          ),
        );

        // Adjust camera position to fit the route bounds
        _adjustCameraPosition();
      });
    } else {
      throw Exception('Failed to load route data');
    }
  }

// Function to fetch weather data for each route point
  Future<void> _fetchWeatherForRoutePoints() async {
    for (var point in latLngPoints) {
      // Replace with actual street name, city name, and county name dynamically
      final streetName = 'Brice Rd';  // You can replace this dynamically
      final cityName = 'Reynoldsburg';  // Replace with actual city name dynamically
      final countyName = 'Franklin';  // Replace with actual county name dynamically

      final url =
          'http://localhost:8080/json/geolocation?street_name=$streetName&city_name=$cityName&county_name=$countyName';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final weatherData = json.decode(response.body);
        double lat = double.parse(weatherData['latitude']);
        double lng = double.parse(weatherData['longitude']);

        print('Weather Data for Point - Lat: $lat, Lng: $lng');
        // You can now use this data for your app, e.g., to display the weather info in a marker or other UI elements
      } else {
        print('Failed to load weather data for $streetName, $cityName');
      }
    }
  }


  // Adjust camera position to fit route
  Future<void> _adjustCameraPosition() async {
    if (latLngPoints.isEmpty) return;

    double minLat = latLngPoints[0].latitude;
    double maxLat = latLngPoints[0].latitude;
    double minLng = latLngPoints[0].longitude;
    double maxLng = latLngPoints[0].longitude;

    for (var point in latLngPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100)); // Increased padding for better view
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0F9D58),
        title: Text("Route Map"),
      ),
      body: Container(
        child: SafeArea(
          child: GoogleMap(
            initialCameraPosition: _kGoogle,
            mapType: MapType.normal,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            polylines: _polyline,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ),
    );
  }
}
