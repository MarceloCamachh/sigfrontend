// order_location_view.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sigfrontend/services/orderServices.dart';

class OrderLocationView extends StatefulWidget {
  final String orderId;
  final String token;

  const OrderLocationView({required this.orderId, required this.token});

  @override
  State<OrderLocationView> createState() => _OrderLocationViewState();
}

class _OrderLocationViewState extends State<OrderLocationView> {
  GoogleMapController? mapController;
  LatLng? orderLocation;

  @override
  void initState() {
    super.initState();
    loadOrderLocation();
  }

  Future<void> loadOrderLocation() async {
    try {
      final order = await OrderServices().getOrderById(widget.orderId, token: widget.token);
      final location = order['location'];
      if (location != null && location['lat'] != null && location['lng'] != null) {
        setState(() {
          orderLocation = LatLng(location['lat'], location['lng']);
        });
      }
    } catch (e) {
      print('Error al obtener ubicación del pedido: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación del Pedido')),
      body: orderLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: orderLocation!,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('order'),
                  position: orderLocation!,
                  infoWindow: const InfoWindow(title: 'Destino del Pedido'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
              },
              onMapCreated: (controller) => mapController = controller,
            ),
    );
  }
}