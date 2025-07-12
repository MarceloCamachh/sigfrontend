// all_vehicles_map_view.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AllVehiclesMapView extends StatelessWidget {
  final List<dynamic> vehicles;

  const AllVehiclesMapView({required this.vehicles, super.key});

  @override
  Widget build(BuildContext context) {
    final List<Marker> markers = vehicles.where((veh) {
      return veh['location'] != null &&
             veh['location']['lat'] != null &&
             veh['location']['lng'] != null;
    }).map((veh) {
      final LatLng position = LatLng(veh['location']['lat'], veh['location']['lng']);
      final String title = veh['userName'] ?? veh['userPhone'] ?? veh['userEmail'] ?? 'Repartidor';
      return Marker(
        markerId: MarkerId(veh['id'] ?? UniqueKey().toString()),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Repartidores en Mapa')),
      body: markers.isEmpty
          ? const Center(child: Text('No hay ubicaciones disponibles.'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: markers.first.position,
                zoom: 13.0,
              ),
              markers: Set<Marker>.of(markers),
            ),
    );
  }
}
