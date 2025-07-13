import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapWidget extends StatefulWidget {
  final LatLng? ubicacionInicial;
  final bool ordersExpanded;
  final LatLng? selectedOrderLocation;

  const MapWidget({
    super.key,
    required this.ubicacionInicial,
    required this.ordersExpanded,
    this.selectedOrderLocation,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _lastCenteredOrder;
  final String _apiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImNmNDU1MDYwZjcyZDRiYzI5NTc4ZWYxN2YyNTE2YTc3IiwiaCI6Im11cm11cjY0In0=';

  // Último punto accesible de la ruta
  LatLng? puntoEncuentro;

  @override
  void initState() {
    super.initState();
    _agregarMarcadores();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _agregarMarcadores();
    _centrarEnPedidoSeleccionado();
  }

  void _agregarMarcadores() {
    _markers.clear();

    if (widget.ubicacionInicial != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('ubicacion_actual'),
          position: widget.ubicacionInicial!,
          infoWindow: const InfoWindow(title: 'Estás aquí'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    if (widget.selectedOrderLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destino_seleccionado'),
          position: widget.selectedOrderLocation!,
          infoWindow: const InfoWindow(title: 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    if (puntoEncuentro != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('punto_encuentro'),
          position: puntoEncuentro!,
          infoWindow: const InfoWindow(title: 'Punto de Encuentro'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    setState(() {});
  }

  void _centrarEnPedidoSeleccionado() async {
    if (widget.selectedOrderLocation != null &&
        widget.selectedOrderLocation != _lastCenteredOrder) {
      final LatLng destino = widget.selectedOrderLocation!;
      final LatLng origen = widget.ubicacionInicial ?? destino;

      final southwest = LatLng(
        (origen.latitude < destino.latitude)
            ? origen.latitude
            : destino.latitude,
        (origen.longitude < destino.longitude)
            ? origen.longitude
            : destino.longitude,
      );
      final northeast = LatLng(
        (origen.latitude > destino.latitude)
            ? origen.latitude
            : destino.latitude,
        (origen.longitude > destino.longitude)
            ? origen.longitude
            : destino.longitude,
      );
      final bounds = LatLngBounds(southwest: southwest, northeast: northeast);

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );

      _lastCenteredOrder = destino;

      if (widget.ubicacionInicial != null) {
        await _dibujarRuta(origen, destino);
      }
    }
  }

  void _centrarEnUbicacionActual() {
    if (widget.ubicacionInicial != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(widget.ubicacionInicial!, 15),
      );
    }
  }

  Future<void> _dibujarRuta(LatLng inicio, LatLng destino) async {
    try {
      final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car/geojson',
      );
      final body = jsonEncode({
        'coordinates': [
          [inicio.longitude, inicio.latitude],
          [destino.longitude, destino.latitude],
        ],
      });

      final response = await http.post(
        url,
        headers: {'Authorization': _apiKey, 'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['features'][0]['geometry']['coordinates'] as List;
        final puntos = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();

        // Establecer último punto como punto de encuentro
        puntoEncuentro = puntos.last;
        _agregarMarcadores();

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: PolylineId(
                  'ruta_${DateTime.now().millisecondsSinceEpoch}'),
              color: Colors.blue,
              width: 5,
              points: puntos,
            ),
          );
        });
      } else {
        print('No se encontró ruta directa, se intenta punto cercano...');

        // Estimar punto accesible cercano manualmente
        final LatLng puntoCercano = LatLng(
          destino.latitude - 0.0015,
          destino.longitude - 0.0015,
        );

        // Llamar de nuevo usando el punto cercano
        await _dibujarRuta(inicio, puntoCercano);
      }
    } catch (e) {
      print('Error al obtener ruta ORS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ubicacionInicial == null) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.blueAccent,
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.ubicacionInicial!,
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
          polylines: _polylines,
          padding: EdgeInsets.only(
            bottom: widget.ordersExpanded
                ? MediaQuery.of(context).size.height * 0.5 + 80
                : 30,
          ),
        ),
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            onPressed: _centrarEnUbicacionActual,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
