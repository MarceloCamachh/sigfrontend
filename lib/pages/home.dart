import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(-16.5000, -68.1500); // fallback
  final Set<Marker> _markers = {}; // MARCADORES

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
  }

  Future<void> _checkPermissionAndGetLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de ubicación denegado')),
      );
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _initialPosition = LatLng(position.latitude, position.longitude);
    final Marker currentLocationMarker = Marker(
      markerId: const MarkerId('ubicacion_actual'),
      position: _initialPosition,
      infoWindow: const InfoWindow(
        title: 'Estás aquí',
        snippet: 'Ubicación actual del repartidor',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      _markers.add(currentLocationMarker);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_initialPosition, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(child: Text("Menú de navegación")),
            ListTile(title: Text("Opción 1")),
            ListTile(title: Text("Opción 2")),
          ],
        ),
      ),
      body: SafeArea(
        child: Builder(
          builder:
              (context) => Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    trafficEnabled: true,
                    compassEnabled: true,
                    markers: _markers,
                  ),
                  // Botón hamburguesa
                  Positioned(
                    top: 16,
                    left: 16,
                    child: FloatingActionButton(
                      heroTag: 'menu_btn',
                      mini: true,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: const Icon(Icons.menu, color: Colors.black),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'location_btn',
                      mini: true,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () async {
                        final position = await Geolocator.getCurrentPosition(
                          // ignore: deprecated_member_use
                          desiredAccuracy: LocationAccuracy.high,
                        );
                        final LatLng current = LatLng(
                          position.latitude,
                          position.longitude,
                        );
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(current, 15),
                        );
                      },
                      child: const Icon(Icons.my_location, color: Colors.black),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
