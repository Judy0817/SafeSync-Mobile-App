// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/directions.dart';
//
// class RoutePage extends StatefulWidget {
//   @override
//   _RoutePageState createState() => _RoutePageState();
// }
//
// class _RoutePageState extends State<RoutePage> {
//   GoogleMapController? _mapController;
//   LatLng _startLocation = LatLng(37.7749, -122.4194); // Example: San Francisco
//   LatLng _endLocation = LatLng(34.0522, -118.2437); // Example: Los Angeles
//   Set<Polyline> _polylines = Set<Polyline>();
//
//   GoogleMapsDirections directionsApi = GoogleMapsDirections(apiKey: 'YOUR_GOOGLE_MAPS_API_KEY');
//
//   @override
//   void initState() {
//     super.initState();
//     _getDirections();
//   }
//
//   Future<void> _getDirections() async {
//     DirectionsResponse response = await directionsApi.directions(
//       Location(_startLocation.latitude, _startLocation.longitude),
//       Location(_endLocation.latitude, _endLocation.longitude),
//       travelMode: TravelMode.driving,
//     );
//
//     if (response.status == 'OK') {
//       final polylinePoints = _convertToLatLng(response.routes![0].overviewPolyline!.points);
//       setState(() {
//         _polylines.add(
//           Polyline(
//             polylineId: PolylineId('route'),
//             points: polylinePoints,
//             color: Colors.blue,
//             width: 5,
//           ),
//         );
//       });
//     }
//   }
//
//   List<LatLng> _convertToLatLng(String encodedPoly) {
//     List<LatLng> points = [];
//     int index = 0;
//     int len = encodedPoly.length;
//     int lat = 0;
//     int lng = 0;
//
//     while (index < len) {
//       int shift = 0;
//       int result = 0;
//       int byte;
//       do {
//         byte = encodedPoly.codeUnitAt(index++) - 63;
//         result |= (byte & 0x1f) << shift;
//         shift += 5;
//       } while (byte >= 0x20);
//       int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         byte = encodedPoly.codeUnitAt(index++) - 63;
//         result |= (byte & 0x1f) << shift;
//         shift += 5;
//       } while (byte >= 0x20);
//       int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lng += dlng;
//
//       points.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//
//     return points;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Route Map'),
//       ),
//       body: GoogleMap(
//         onMapCreated: (controller) {
//           _mapController = controller;
//         },
//         initialCameraPosition: CameraPosition(
//           target: _startLocation,
//           zoom: 7.0,
//         ),
//         polylines: _polylines,
//       ),
//     );
//   }
// }
