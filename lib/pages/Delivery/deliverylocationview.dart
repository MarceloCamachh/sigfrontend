// vehicle_location_view.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sigfrontend/services/deliveryvehiclesServices.dart';

class VehicleLocationView extends StatefulWidget {
  final String userId;
  final String token;

  const VehicleLocationView({required this.userId, required this.token});

  @override
  State<VehicleLocationView> createState() => _VehicleLocationViewState();
}

class _VehicleLocationViewState extends State<VehicleLocationView> {
  GoogleMapController? mapController;
  LatLng? vehiclePosition;

  @override
  void initState() {
    super.initState();
    loadVehicleLocation();
  }

  Future<void> loadVehicleLocation() async {
    try {
      final vehicle = await DeliveryVehicleService().getVehicleByUserId(
        userId: widget.userId,
        token: widget.token,
      );
      final location = vehicle['location'];
      if (location != null && location['lat'] != null && location['lng'] != null) {
        setState(() {
          vehiclePosition = LatLng(location['lat'], location['lng']);
        });
      }
    } catch (e) {
      print('Error al obtener ubicación del vehículo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación del Repartidor')),
      body: vehiclePosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: vehiclePosition!,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('vehicle'),
                  position: vehiclePosition!,
                  infoWindow: const InfoWindow(title: 'Repartidor'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              },
              onMapCreated: (controller) => mapController = controller,
            ),
    );
  }
}
