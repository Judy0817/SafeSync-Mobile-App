import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  Marker? _startMarker;
  Marker? _endMarker;
  LatLng? _startLatLng;
  LatLng? _endLatLng;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _onTap(LatLng latLng) {
    setState(() {
      if (_startLatLng == null) {
        _startLatLng = latLng;
        _startMarker = Marker(
          markerId: MarkerId('start'),
          position: _startLatLng!,
          infoWindow: InfoWindow(title: 'Start Point'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
      } else if (_endLatLng == null) {
        _endLatLng = latLng;
        _endMarker = Marker(
          markerId: MarkerId('end'),
          position: _endLatLng!,
          infoWindow: InfoWindow(title: 'End Point'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      } else {
        // Reset markers
        _startLatLng = latLng;
        _endLatLng = null;
        _startMarker = Marker(
          markerId: MarkerId('start'),
          position: _startLatLng!,
          infoWindow: InfoWindow(title: 'Start Point'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
        _endMarker = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Start and Destination'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.77483, -122.41942), // Initial position (San Francisco)
          zoom: 12,
        ),
        markers: _createMarkers(),
        onTap: _onTap,
      ),
    );
  }

  Set<Marker> _createMarkers() {
    final markers = <Marker>{};
    if (_startMarker != null) markers.add(_startMarker!);
    if (_endMarker != null) markers.add(_endMarker!);
    return markers;
  }
}

void main() {
  runApp(MaterialApp(
    home: MapPage(),
  ));
}
