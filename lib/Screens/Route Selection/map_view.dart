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
  List<int> _severityList = []; // List to store severity values


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
        for (int i = 1; i < latLngPoints.length - 1; i++) {
          _addWeatherAndRoadDataToMarker(latLngPoints[i], i);
          print('test');
        }

        _adjustCameraPosition();
      });
    } else {
      throw Exception('Failed to load route data from local server');
    }
  }

  Future<void> _addWeatherAndRoadDataToMarker(LatLng point, int markerId) async {
    // Fetch nearby road info (street name, city, county)
    final nearbyRoadInfoUrl =
        '${ApiConfig.baseUrl}/json/nearby_road_info?latitude=${point.latitude}&longitude=${point.longitude}&radius=1';

    final nearbyRoadResponse = await http.get(Uri.parse(nearbyRoadInfoUrl));

    if (nearbyRoadResponse.statusCode == 200) {
      final roadData = json.decode(nearbyRoadResponse.body);

      // Check if valid data is received
      if (roadData['street_name'] != null && roadData['city'] != null && roadData['county'] != null) {
        final capitalizedStreetName = roadData['street_name'].toUpperCase();
        final capitalizedCityName = roadData['city'].toUpperCase();
        final capitalizedCountyName = roadData['county'].toUpperCase();

        // Fetch weather and road features data using street, city, county, and point lat/lon
        final weatherAndRoadUrl =
            '${ApiConfig.baseUrl}/json/road_features_with_weather?street_name=$capitalizedStreetName&city_name=$capitalizedCityName&county_name=$capitalizedCountyName&latitude=${point.latitude}&longitude=${point.longitude}';

        final weatherAndRoadResponse = await http.get(Uri.parse(weatherAndRoadUrl));

        if (weatherAndRoadResponse.statusCode == 200) {
          final weatherAndRoadData = json.decode(weatherAndRoadResponse.body);

          // Now calculate severity based on weather and road data
          final severity = await _calculateSeverity(
            weatherAndRoadData['weather'],
            weatherAndRoadData['road_features'],
          );

          // Add marker
          _markers.add(
            Marker(
              markerId: MarkerId(markerId.toString()),
              position: point,
              onTap: () {
                _showWeatherAndRoadInfoDialog(
                  context,
                  capitalizedStreetName,
                  capitalizedCityName,
                  capitalizedCountyName,
                  weatherAndRoadData['weather'],
                  weatherAndRoadData['road_features'],
                  severity,
                );
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        } else {
          print('Failed to fetch weather and road features data');
        }
      }
    } else {
      print('Failed to fetch nearby road info');
    }
  }

  Future<int> _calculateSeverity(dynamic weatherCondition, dynamic roadFeatures) async {
    final severityUrl = '${ApiConfig.baseUrl}/json/calculate_severity?' +
        'temperature=${weatherCondition['temperature(F)']}&' +
        'pressure=${weatherCondition['pressure(in)']}&' +
        'wind_direction=${weatherCondition['wind_direction']}&' +
        'wind_speed=${weatherCondition['wind_speed(mph)']}&' +
        'weather_condition=${weatherCondition['weather']}&' +
        'bump=${roadFeatures['bump']}&' +
        'crossing=${roadFeatures['crossing']}&' +
        'give_way=${roadFeatures['give_way']}&' +
        'junction=${roadFeatures['junction']}&' +
        'no_exit=${roadFeatures['no_exit']}&' +
        'railway=${roadFeatures['railway']}&' +
        'roundabout=${roadFeatures['roundabout']}&' +
        'station=${roadFeatures['station']}&' +
        'stop=${roadFeatures['stop']}&' +
        'traffic_calming=${roadFeatures['traffic_calming']}&' +
        'traffic_signal=${roadFeatures['traffic_signal']}';

    final severityResponse = await http.get(Uri.parse(severityUrl));

    if (severityResponse.statusCode == 200) {
      final severityData = json.decode(severityResponse.body);
      return severityData['severity'] ?? 0;
    } else {
      print('Failed to calculate severity');
      return 0; // Default severity value in case of failure
    }
  }

  void _showWeatherAndRoadInfoDialog(
      BuildContext context,
      String streetName,
      String cityName,
      String countyName,
      dynamic weatherCondition,  // Changed to dynamic
      dynamic roadFeatures,      // Changed to dynamic
      int severity,             // Added severity parameter
      ) {
    // Convert weatherCondition and roadFeatures to strings
    String weatherConditionStr = _convertWeatherToString(weatherCondition);
    String roadFeaturesStr = _convertRoadFeaturesToString(roadFeatures);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Road Info for $streetName'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildInfoRow('Street', streetName),
                _buildInfoRow('City', cityName),
                _buildInfoRow('County', countyName),
                SizedBox(height: 16),
                Text(
                  'Calculated Severity: $severity',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                ),
                SizedBox(height: 16),
                Text(
                  'Weather Condition:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildWeatherInfo(weatherCondition),
                SizedBox(height: 16),
                Text(
                  'Road Features:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildRoadFeatures(roadFeatures),
                SizedBox(height: 16),

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildWeatherInfo(dynamic weatherCondition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildInfoRow('Weather', weatherCondition['weather'] ?? 'N/A'),
        _buildInfoRow('Temperature (°F)', weatherCondition['temperature(F)'] ?? 'N/A'),
        _buildInfoRow('Humidity (%)', weatherCondition['humidity(%)'] ?? 'N/A'),
        _buildInfoRow('Precipitation (in)', weatherCondition['precipitation(in)'] ?? 'N/A'),
        _buildInfoRow('Pressure (in)', weatherCondition['pressure(in)'] ?? 'N/A'),
        _buildInfoRow('Wind Chill (°F)', weatherCondition['wind_chill(F)'] ?? 'N/A'),
        _buildInfoRow('Wind Speed (mph)', weatherCondition['wind_speed(mph)'] ?? 'N/A'),
        _buildInfoRow('Visibility (mi)', weatherCondition['visibility(mi)'] ?? 'N/A'),
        _buildInfoRow('Wind Direction', weatherCondition['wind_direction'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildRoadFeatures(dynamic roadFeatures) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildInfoRow('Bump', roadFeatures['bump'] ? 'Yes' : 'No'),
        _buildInfoRow('Crossing', roadFeatures['crossing'] ? 'Yes' : 'No'),
        _buildInfoRow('Give Way', roadFeatures['give_way'] ? 'Yes' : 'No'),
        _buildInfoRow('Junction', roadFeatures['junction'] ? 'Yes' : 'No'),
        _buildInfoRow('No Exit', roadFeatures['no_exit'] ? 'Yes' : 'No'),
        _buildInfoRow('Railway', roadFeatures['railway'] ? 'Yes' : 'No'),
        _buildInfoRow('Roundabout', roadFeatures['roundabout'] ? 'Yes' : 'No'),
        _buildInfoRow('Station', roadFeatures['station'] ? 'Yes' : 'No'),
        _buildInfoRow('Stop', roadFeatures['stop'] ? 'Yes' : 'No'),
        _buildInfoRow('Traffic Calming', roadFeatures['traffic_calming'] ? 'Yes' : 'No'),
        _buildInfoRow('Traffic Signal', roadFeatures['traffic_signal'] ? 'Yes' : 'No'),
      ],
    );
  }

  String _convertWeatherToString(dynamic weather) {
    // Handle conversion of weather conditions
    return weather != null ? weather.toString() : 'Unknown weather condition';
  }

  String _convertRoadFeaturesToString(dynamic roadFeatures) {
    // Convert the road features map into a readable string
    if (roadFeatures is Map) {
      List<String> featuresList = [];
      roadFeatures.forEach((key, value) {
        featuresList.add('$key: ${value ? 'Yes' : 'No'}');
      });
      return featuresList.join(', ');
    }
    return 'Unknown road features';
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


