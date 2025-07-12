import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final LatLng? ubicacionInicial;
  final bool ordersExpanded;

  const MapWidget({
    super.key,
    required this.ubicacionInicial,
    required this.ordersExpanded,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _agregarMarcadorInicial();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _agregarMarcadorInicial();
  }

  void _agregarMarcadorInicial() {
    if (widget.ubicacionInicial != null &&
        !_markers.any((m) => m.markerId.value == 'ubicacion_actual')) {
      final marker = Marker(
        markerId: const MarkerId('ubicacion_actual'),
        position: widget.ubicacionInicial!,
        infoWindow: const InfoWindow(title: 'Estás aquí'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      setState(() => _markers.add(marker));

      // También mover la cámara si ya se creó
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(widget.ubicacionInicial!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.ubicacionInicial ?? const LatLng(-16.5, -68.15),
        zoom: 14,
      ),
      onMapCreated: (controller) => _mapController = controller,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      trafficEnabled: true,
      compassEnabled: true,
      markers: _markers,
      padding: EdgeInsets.only(
        bottom: widget.ordersExpanded ? MediaQuery.of(context).size.height * 0.5 + 80 : 30,
      ),
    );
  }
}
