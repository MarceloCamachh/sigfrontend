import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapWidget extends StatefulWidget {
  final LatLng? ubicacionInicial;
  final bool ordersExpanded;
  final LatLng? selectedOrderLocation;
  final List<Map<String, dynamic>>? ordenes;
  final Map<String, dynamic>? ordenActual;
  final List<Map<String, dynamic>>? ordenesParaRutaOptima;

  const MapWidget({
    super.key,
    required this.ubicacionInicial,
    required this.ordersExpanded,
    this.selectedOrderLocation,
    this.ordenes,
    this.ordenActual,
    this.ordenesParaRutaOptima,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _lastCenteredOrder;
  LatLng? puntoEncuentro;

  final String _apiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImNmNDU1MDYwZjcyZDRiYzI5NTc4ZWYxN2YyNTE2YTc3IiwiaCI6Im11cm11cjY0In0=';

  @override
  void initState() {
    super.initState();
    _agregarMarcadores();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // NUEVA LÓGICA: Decide qué ruta dibujar
    if (widget.ordenesParaRutaOptima != null &&
        widget.ordenesParaRutaOptima != oldWidget.ordenesParaRutaOptima) {
      // Si hay una lista para optimizar, dibuja la ruta optimizada
      _dibujarRutaOptimizada();
    } else if (widget.ordenActual != oldWidget.ordenActual) {
      // Si cambia el pedido individual, dibuja la ruta simple
      _polylines.clear(); // Limpia rutas anteriores
      _agregarMarcadores();
      _centrarEnPedidoSeleccionado();
    } else if (widget.ordenActual == null && oldWidget.ordenActual != null) {
      // Si se deselecciona un pedido, limpia el mapa
      _polylines.clear();
      _agregarMarcadores();
      _centrarEnUbicacionActual();
    }
  }

  void _agregarMarcadores() {
    _markers.clear();

    // Agrega ubicación actual
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

    // Prioridad 1: mostrar solo ordenActual si está definido
    if (widget.ordenActual != null) {
      final loc = widget.ordenActual!['location'];
      if (loc != null && loc['latitude'] != null && loc['longitude'] != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(widget.ordenActual!['id'].toString()),
            position: LatLng(loc['latitude'], loc['longitude']),
            infoWindow: const InfoWindow(title: 'Pedido asignado'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );
      }
    }
    // Prioridad 2: si no hay ordenActual, mostrar selectedOrderLocation
    else if (widget.selectedOrderLocation != null) {
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

    // Punto de encuentro si existe
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
    if (widget.ordenActual != null) {
      final loc = widget.ordenActual!['location'];
      if (loc != null &&
          loc['latitude'] != null &&
          loc['longitude'] != null &&
          LatLng(loc['latitude'], loc['longitude']) != _lastCenteredOrder) {
        final destino = LatLng(loc['latitude'], loc['longitude']);
        final origen = widget.ubicacionInicial ?? destino;

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

        puntoEncuentro = puntos.last;
        _agregarMarcadores();

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: PolylineId(
                'ruta_${DateTime.now().millisecondsSinceEpoch}',
              ),
              color: Colors.blue,
              width: 5,
              points: puntos,
            ),
          );
        });
      } else {
        final LatLng puntoCercano = LatLng(
          destino.latitude - 0.0015,
          destino.longitude - 0.0015,
        );
        await _dibujarRuta(inicio, puntoCercano);
      }
    } catch (e) {
      print('Error al obtener ruta ORS: $e');
    }
  }

  // NUEVA FUNCIÓN: Ordena los pedidos por el algoritmo del "vecino más cercano"
  List<Map<String, dynamic>> _ordenarPedidosPorProximidad(
    LatLng puntoPartida,
    List<Map<String, dynamic>> pedidosSinOrdenar,
  ) {
    List<Map<String, dynamic>> pedidosRestantes = List.from(pedidosSinOrdenar);
    List<Map<String, dynamic>> pedidosOrdenados = [];
    LatLng ubicacionActual = puntoPartida;

    while (pedidosRestantes.isNotEmpty) {
      Map<String, dynamic>? pedidoMasCercano;
      double distanciaMinima = double.infinity;

      for (var pedido in pedidosRestantes) {
        final loc = pedido['location'];
        final LatLng puntoPedido = LatLng(loc['latitude'], loc['longitude']);

        // Usamos Geolocator para calcular la distancia. Asegúrate de tener el paquete.
        // Si no lo tienes: pub add geolocator
        // O puedes usar una fórmula de distancia simple si prefieres.
        final double distancia = Geolocator.distanceBetween(
          ubicacionActual.latitude,
          ubicacionActual.longitude,
          puntoPedido.latitude,
          puntoPedido.longitude,
        );

        if (distancia < distanciaMinima) {
          distanciaMinima = distancia;
          pedidoMasCercano = pedido;
        }
      }

      if (pedidoMasCercano != null) {
        pedidosOrdenados.add(pedidoMasCercano);
        pedidosRestantes.remove(pedidoMasCercano);
        final loc = pedidoMasCercano['location'];
        ubicacionActual = LatLng(loc['latitude'], loc['longitude']);
      }
    }

    return pedidosOrdenados;
  }

  // MODIFICADA: Ahora usa nuestro algoritmo y la API de Directions que sí es gratuita
  Future<void> _dibujarRutaOptimizada() async {
    if (widget.ubicacionInicial == null ||
        widget.ordenesParaRutaOptima == null ||
        widget.ordenesParaRutaOptima!.isEmpty) {
      return;
    }

    // 1. Ordena los pedidos usando nuestro nuevo algoritmo
    final List<Map<String, dynamic>> pedidosOrdenados =
        _ordenarPedidosPorProximidad(
          widget.ubicacionInicial!,
          widget.ordenesParaRutaOptima!,
        );

    // 2. Crea la lista de puntos (waypoints) para la API de Directions
    // El formato es: [inicio, parada1, parada2, ..., paradaN, fin]
    final List<List<double>> coordinates = [
      [widget.ubicacionInicial!.longitude, widget.ubicacionInicial!.latitude],
    ];
    for (var pedido in pedidosOrdenados) {
      final loc = pedido['location'];
      coordinates.add([loc['longitude'], loc['latitude']]);
    }

    // 3. Llama a la API de Directions (la que sí tienes acceso gratuito)
    // Esta API soporta múltiples waypoints.
    try {
      final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car/geojson',
      );
      final body = jsonEncode({'coordinates': coordinates});

      final response = await http.post(
        url,
        headers: {'Authorization': _apiKey, 'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['features'][0]['geometry']['coordinates'] as List;
        final puntos = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('ruta_optima_aproximada'),
              color: Colors.purple,
              width: 5,
              points: puntos,
            ),
          );

          // Dibuja los marcadores numerados
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('inicio'),
              position: widget.ubicacionInicial!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
              infoWindow: const InfoWindow(title: 'Punto de Partida'),
            ),
          );

          for (int i = 0; i < pedidosOrdenados.length; i++) {
            final order = pedidosOrdenados[i];
            final loc = order['location'];
            _markers.add(
              Marker(
                markerId: MarkerId('pedido_${order['id']}'),
                position: LatLng(loc['latitude'], loc['longitude']),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
                infoWindow: InfoWindow(
                  title:
                      'Parada ${i + 1}: Pedido #${order['id'].substring(0, 4)}',
                ),
              ),
            );
          }
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(_boundsFromLatLngList(puntos), 100),
        );
      } else {
        print(
          'Error en la API de Directions con múltiples paradas: ${response.body}',
        );
      }
    } catch (e) {
      print('Error al calcular ruta aproximada: $e');
    }
  }

  List<List<double>> decodePolyline(String encoded) {
    List<List<double>> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add([lat / 1E6, lng / 1E6]);
    }
    return poly;
  }

  // Función auxiliar para crear los límites del mapa
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
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
            bottom:
                widget.ordersExpanded
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
