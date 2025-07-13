import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/Sidebar.dart';
import 'package:sigfrontend/pages/map_widget.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/pages/Delivery/orderlist.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? pedidoInicial;

  const HomePage({super.key, this.pedidoInicial});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  LatLng? _ubicacionInicial;
  bool _ordersExpanded = true;
  LatLng? _selectedOrderLocation;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();

    // Mostrar pedido si viene desde DeliveryManagement
    if (widget.pedidoInicial != null) {
      final location = widget.pedidoInicial!["location"];
      if (location != null &&
          location["latitude"] != null &&
          location["longitude"] != null) {
        _selectedOrderLocation = LatLng(
          location["latitude"],
          location["longitude"],
        );
        _ordersExpanded = false; // Oculta el OrderList
      }
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

    setState(() {
      _ubicacionInicial = LatLng(position.latitude, position.longitude);
    });
  }

  void _verUbicacionPedido(Map<String, dynamic> order) {
    final location = order["location"];
    if (location != null &&
        location["latitude"] != null &&
        location["longitude"] != null) {
      setState(() {
        _selectedOrderLocation = LatLng(
          location["latitude"],
          location["longitude"],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserProvider>(context).role;

    return Scaffold(
      drawer: AppDrawer(),
      body: SafeArea(
        child: Builder(
          builder:
              (context) => Stack(
                children: [
                  MapWidget(
                    ubicacionInicial: _ubicacionInicial,
                    ordersExpanded: _ordersExpanded,
                    selectedOrderLocation: _selectedOrderLocation,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: FloatingActionButton(
                      heroTag: 'menu_btn',
                      mini: true,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(Icons.menu, color: Colors.black),
                    ),
                  ),
                  if (userRole == 'ADMINISTRADOR' || userRole == 'REPARTIDOR')
                    OrderList(
                      ordersExpanded: _ordersExpanded,
                      toggleExpanded: () {
                        setState(() => _ordersExpanded = !_ordersExpanded);
                      },
                      onVerEnMapa: _verUbicacionPedido,
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
