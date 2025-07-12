import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaInternoPage extends StatefulWidget {
  final double lat;
  final double lng;

  const MapaInternoPage({super.key, required this.lat, required this.lng});

  @override
  State<MapaInternoPage> createState() => _MapaInternoPageState();
}

class _MapaInternoPageState extends State<MapaInternoPage> {
  late GoogleMapController _mapController;
  late LatLng _location;

  @override
  void initState() {
    super.initState();
    _location = LatLng(widget.lat, widget.lng);
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> _markers = {
      Marker(
        markerId: const MarkerId('destino'),
        position: _location,
        infoWindow: const InfoWindow(title: 'Destino'),
      )
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación de la orden'),
        backgroundColor: Colors.indigo,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _location,
          zoom: 16,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () {
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_location, 16),
          );
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
