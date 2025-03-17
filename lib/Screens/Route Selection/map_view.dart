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
  double _averageSeverity = 0;


  @override
  void initState() {
    super.initState();
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
        }

        _adjustCameraPosition();
      });
    } else {
      throw Exception('Failed to load route data from local server');
    }
  }


  double _sumSeverity = 0.0; // To store the sum of all severity values
  int _totalPoints = 0;      // To count the total number of points

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

        // Fetch weather and road features data
        final weatherAndRoadUrl =
            '${ApiConfig.baseUrl}/json/road_features_with_weather?street_name=$capitalizedStreetName&city_name=$capitalizedCityName&county_name=$capitalizedCountyName&latitude=${point.latitude}&longitude=${point.longitude}';

        final weatherAndRoadResponse = await http.get(Uri.parse(weatherAndRoadUrl));

        if (weatherAndRoadResponse.statusCode == 200) {
          final weatherAndRoadData = json.decode(weatherAndRoadResponse.body);

          // Calculate severity for this point
          final double severity = await _calculateSeverity(
            weatherAndRoadData['weather'],
            weatherAndRoadData['road_features'],
          );

          // Update sumSeverity and totalPoints
          _sumSeverity += severity;
          _totalPoints++;
          print('severity sum = $_sumSeverity');
          print('total points = $_totalPoints');

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



  Future<double> _calculateSeverity(dynamic weatherCondition, dynamic roadFeatures) async {
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
      return (severityData['severity'] as num?)?.toDouble() ?? 0.0;
    } else {
      print('Failed to calculate severity');
      return 0.0; // Default severity value in case of failure
    }
  }


  void _showWeatherAndRoadInfoDialog(
      BuildContext context,
      String streetName,
      String cityName,
      String countyName,
      dynamic weatherCondition,  // Changed to dynamic
      dynamic roadFeatures,      // Changed to dynamic
      double severity,             // Added severity parameter
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
                Text(
                  'Calculated Severity: $severity',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                ),

                _buildWeatherInfo(weatherCondition),

                _buildRoadFeatures(roadFeatures),


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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        color: Colors.lightBlue[50], // Light background color
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Weather Condition Title
              Text(
                'Weather Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const Divider(color: Colors.grey),

              // Display weather details with icons and more styled rows
              _buildWeatherInfoRow('Weather', weatherCondition['weather'] ?? 'N/A', Icons.cloud),
              _buildWeatherInfoRow('Temperature (°F)', weatherCondition['temperature(F)'] ?? 'N/A', Icons.thermostat),
              _buildWeatherInfoRow('Humidity (%)', weatherCondition['humidity(%)'] ?? 'N/A', Icons.water_drop),
              _buildWeatherInfoRow('Precipitation (in)', weatherCondition['precipitation(in)'] ?? 'N/A', Icons.invert_colors),
              _buildWeatherInfoRow('Pressure (in)', weatherCondition['pressure(in)'] ?? 'N/A', Icons.speed),
              _buildWeatherInfoRow('Wind Chill (°F)', weatherCondition['wind_chill(F)'] ?? 'N/A', Icons.ac_unit),
              _buildWeatherInfoRow('Wind Speed (mph)', weatherCondition['wind_speed(mph)'] ?? 'N/A', Icons.air),
              _buildWeatherInfoRow('Visibility (mi)', weatherCondition['visibility(mi)'] ?? 'N/A', Icons.visibility),
              _buildWeatherInfoRow('Wind Direction', weatherCondition['wind_direction'] ?? 'N/A', Icons.navigation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              overflow: TextOverflow.ellipsis, // In case the value is too long
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRoadFeatures(dynamic roadFeatures) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header for the section
            Text(
              'Road Features',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(color: Colors.grey),
            // Features list
            Wrap(
              spacing: 16,
              runSpacing: 1,
              children: roadFeatures.entries.map<Widget>((entry) {
                return _buildFeatureChip(entry.key, entry.value);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String feature, bool value) {
    // Format the feature name (e.g., "Give Way" instead of "give_way")
    String formattedFeature = feature
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Chip(
      avatar: Icon(
        value ? Icons.check_circle : Icons.cancel,
        color: value ? Colors.green : Colors.red,
        size: 20,
      ),
      label: Text(
        formattedFeature,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 30)); // Increased padding for better view
  }


  void _updateAverageSeverity() {
    if (_totalPoints > 0) {
      setState(() {
        _averageSeverity = _sumSeverity / _totalPoints;
        print("Average : $_averageSeverity");
      });
    } else {
      print(_totalPoints);
      print(" judy 2");
      setState(() {
        _averageSeverity = 0; // No points processed
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Route Map"),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
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

          // Average Severity Display (Overlayed on Map)
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: (_averageSeverity != null && _averageSeverity! > 2)
                        ? Colors.red // Warning color
                        : Colors.green, // Normal color
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _averageSeverity != 0
                        ? "Average Severity : ${_averageSeverity!.toStringAsFixed(6)}"
                        : "Average Severity : Loading...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (_averageSeverity != null && _averageSeverity! > 2)
                          ? Colors.red // Warning color
                          : Colors.green, // Normal color
                    ),
                  ),
                ],

              ),
            ),
          ),
        ],
      ),

      // Floating Action Button to Recalculate Average Severity
      floatingActionButton: FloatingActionButton(
        onPressed: _updateAverageSeverity,
        backgroundColor: const Color(0xFF0F9D58),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}