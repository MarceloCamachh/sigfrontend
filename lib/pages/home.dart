// archivo: homepage.dart
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
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  LatLng? _ubicacionInicial;
  bool _ordersExpanded = true;

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

    setState(() {
      _ubicacionInicial = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserProvider>(context).role;

    return Scaffold(
      drawer: AppDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(
            children: [
              MapWidget(
                ubicacionInicial: _ubicacionInicial,
                ordersExpanded: _ordersExpanded,
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
                OrderList(ordersExpanded: _ordersExpanded, toggleExpanded: () {
                  setState(() => _ordersExpanded = !_ordersExpanded);
                }),
            ],
          ),
        ),
      ),
    );
  }
}
