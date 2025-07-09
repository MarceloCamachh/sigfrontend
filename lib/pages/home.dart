import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/OrderCard.dart';
import 'package:sigfrontend/components/Sidebar.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/services/orderServices.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(-16.5000, -68.1500);
  final Set<Marker> _markers = {};
  List<dynamic> _ordenes = [];
  bool _cargandoOrdenes = true;
  bool _ordersExpanded = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final token = Provider.of<UserProvider>(context, listen: false).accessToken;
      if (token == null) {
        // ignore: avoid_print
        print('Token no disponible');
        return;
      } else {
        // ignore: avoid_print
        print('Token obtenido: $token');
      }
      final orders = await OrderServices().getAllOrders(token: token);
      setState(() {
        _ordenes = orders;
        _cargandoOrdenes = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener órdenes: $e');
      setState(() => _cargandoOrdenes = false);
    }
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
      drawer: AppDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(
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

              // Botón centrar ubicación
              Positioned(
                bottom: _ordersExpanded 
                    ? MediaQuery.of(context).size.height * 0.5 + 80
                    : 30,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'location_btn',
                  mini: true,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () async {
                    final position = await Geolocator.getCurrentPosition(
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
              // Sección de órdenes
             // Reemplaza el Positioned de la sección de órdenes con este código:
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Botón para expandir/contraer (ahora con fondo semitransparente)
                  GestureDetector(
                    onTap: () => setState(() => _ordersExpanded = !_ordersExpanded),
                    child: Container(
                      color: Colors.black.withOpacity(0.3), // Fondo semitransparente
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _ordersExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  
                  // Contenedor de órdenes con fondo transparente
                  if (_ordersExpanded)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.0), // Fondo muy transparente
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: _cargandoOrdenes
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const CircularProgressIndicator(),
                              ),
                            )
                          : _ordenes.isEmpty
                              ? Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'No hay órdenes disponibles',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: ListView.builder(
                                    itemCount: _ordenes.length,
                                    itemBuilder: (context, index) {
                                      return OrderCard(order: _ordenes[index]);
                                    },
                                  ),
                                ),
                    ),
                ],
              ),
            ), ],
          ),
        ),
      ),
    );
  }
}