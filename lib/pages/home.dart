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
  LatLng _initialPosition = const LatLng(-16.5000, -68.1500); // fallback
  final Set<Marker> _markers = {}; // MARCADORES

  List<dynamic> _ordenes = [];
  bool _cargandoOrdenes = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
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

                  // Botón centrar ubicación
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

                  // Lista de órdenes
                  if (!_cargandoOrdenes)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 160,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child:
                            _ordenes.isEmpty
                                ? const Center(
                                  child: Text('No hay órdenes disponibles'),
                                )
                                : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: _ordenes.length,
                                  itemBuilder: (context, index) {
                                    final order = _ordenes[index];
                                    return SizedBox(
                                      width: 260,
                                      child: OrderCard(order: order),
                                    );
                                  },
                                ),
                      ),
                    ),

                  if (_cargandoOrdenes)
                    const Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
