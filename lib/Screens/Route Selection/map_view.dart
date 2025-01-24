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
    _fetchRouteDataFromLocalServer();
  }

  Future<void> _fetchRouteDataFromLocalServer() async {
    final url =
        '${ApiConfig.baseUrl}/json/route?origin=${widget.startPoint}&destination=${widget.endPoint}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> routePoints = data['route_points'];
      List<LatLng> decodedPoints = routePoints
          .map((point) => LatLng(point['lat'], point['lng']))
          .toList();

      setState(() {
        latLngPoints = decodedPoints;

        // Add polyline to display the route
        _polyline.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: latLngPoints,
            color: Colors.blue,
            width: 5,
          ),
        );

        // Add markers for start and end locations
        _markers.add(
          Marker(
            markerId: MarkerId('start'),
            position: LatLng(data['start_lat_lng']['lat'], data['start_lat_lng']['lng']),
            infoWindow: InfoWindow(title: 'Start Location', snippet: data['start_location']),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );

        _markers.add(
          Marker(
            markerId: MarkerId('end'),
            position: LatLng(data['end_lat_lng']['lat'], data['end_lat_lng']['lng']),
            infoWindow: InfoWindow(title: 'Destination', snippet: data['destination']),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );

        // Add markers for each point along the route
        for (int i = 1; i < latLngPoints.length -1; i++) {
          _markers.add(
            Marker(
              markerId: MarkerId(i.toString()),
              position: latLngPoints[i],
              infoWindow: InfoWindow(
                title: 'Point $i',
                snippet: 'Lat: ${latLngPoints[i].latitude}, Lng: ${latLngPoints[i].longitude}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        }

        _adjustCameraPosition();
      });
    } else {
      throw Exception('Failed to load route data from local server');
    }
  }


  Future<void> _fetchRouteData() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.startPoint}&destination=${widget.endPoint}&key=';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        List<LatLng> decodedPoints = _decodePolyline(data['routes'][0]['overview_polyline']['points']);

        setState(() {
          latLngPoints = decodedPoints;

          _polyline.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: latLngPoints,
              color: Colors.blue,
              width: 5,
            ),
          );

          _adjustCameraPosition();
        });
      } else {
        print("Error fetching route: ${data['status']}");
      }
    } else {
      throw Exception('Failed to load route data');
    }
  }

// Function to decode Google Polyline to LatLng points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
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