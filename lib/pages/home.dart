// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/DeliveredPanel.dart';
import 'package:sigfrontend/components/OrderCard.dart';
import 'package:sigfrontend/components/Sidebar.dart';
import 'package:sigfrontend/pages/map_widget.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/pages/Delivery/orderlist.dart';
import 'package:sigfrontend/services/orderServices.dart';
import 'package:sigfrontend/services/payment.services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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
  List<Map<String, dynamic>> _ordenesAsignadas = [];
  Map<String, dynamic>? _pedidoActual;
  bool _panelMostrado = false;
  final PaymentServices _paymentServices = PaymentServices();

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();

    if (widget.pedidoInicial != null) {
      final location = widget.pedidoInicial!["location"];
      if (location != null &&
          location["latitude"] != null &&
          location["longitude"] != null) {
        _selectedOrderLocation = LatLng(
          location["latitude"],
          location["longitude"],
        );
        _ordersExpanded = false;
      }
    }
  }

  Future<void> _procesarPagoYCompletar(
    BuildContext context,
    Map<String, dynamic> pedido,
  ) async {
    try {
      final monto = (pedido['total_payable'] as num?)?.toInt() ?? 0;

      final clientSecret = await _paymentServices.createPaymentIntent(
        monto * 100,
        'bob',
      );

      await _paymentServices.presentPaymentSheet(clientSecret);

      if (!mounted) return;
      showDialog(
        context: this.context,
        builder:
            (_) => const AlertDialog(content: Text("Pago realizado con éxito")),
      );

      print('Pago realizado con éxito: $monto Bs');

      _marcarPedidoComoCompletado();
    } catch (e) {
      print('Error al procesar el pago: $e');
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
          if (!mounted) return;
          showDialog(
            context: this.context,
            builder:
                (_) => const AlertDialog(
                  content: Text("El pago fue cancelado por el usuario."),
                ),
          );
        } else {
          showDialog(
            context: this.context,
            builder:
                (_) => AlertDialog(
                  content: Text("Error en el pago: ${e.error.message}"),
                ),
          );
        }
      } else {
        print('Error desconocido: $e');
        if (!mounted) return;
        showDialog(
          context: this.context,
          builder:
              (_) => const AlertDialog(
                content: Text("Error al procesar el pago. Inténtalo de nuevo."),
              ),
        );
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

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _ubicacionInicial = LatLng(position.latitude, position.longitude);
    });

    if (_pedidoActual != null && !_panelMostrado) {
      final destino = _pedidoActual!['location'];
      final distancia = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        destino['latitude'],
        destino['longitude'],
      );
      print('_pedidoActual: $_pedidoActual');

      if (distancia <= 50) {
        _panelMostrado = true;
        _mostrarPanelEntrega(_pedidoActual!);
      }
    }
  }

  void _mostrarPanelEntrega(Map<String, dynamic> pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DeliveryPanel(
            pedido: pedido,
            onClose: () => Navigator.pop(context),
            onComplete: () async {
              Navigator.pop(context);
              await _procesarPagoYCompletar(context, pedido);
            },
            onCancel: _cancelarPedido,
          ),
    );
  }

  Future<void> _marcarPedidoComoCompletado() async {
    if (_pedidoActual == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.accessToken ?? '';

    final ubicacion = _pedidoActual!['location'];
    final volume = _pedidoActual!['volume'];
    final totalPayable = _pedidoActual!['total_payable'];

    final Map<String, dynamic> updatedData = {
      "location": {
        "latitude": ubicacion['latitude'],
        "longitude": ubicacion['longitude'],
        "capture_time": ubicacion['capture_time'],
      },
      "volume": volume,
      "state": "delivered",
      "total_payable": totalPayable,
    };

    final String idPedido = _pedidoActual!['id'];

    try {
      await OrderServices().updateOrder(
        id: idPedido,
        data: updatedData,
        token: token,
      );

      print('Pedido marcado como entregado exitosamente.');

      setState(() {
        _ordenesAsignadas.remove(_pedidoActual);
        if (_ordenesAsignadas.isNotEmpty) {
          _pedidoActual = _ordenesAsignadas.first;
          _selectedOrderLocation = LatLng(
            _pedidoActual!['location']['latitude'],
            _pedidoActual!['location']['longitude'],
          );
          _panelMostrado = false;
        } else {
          _pedidoActual = null;
          _selectedOrderLocation = null;
        }
      });
    } catch (e) {
      print('Error al actualizar el estado del pedido: $e');
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error'),
              content: Text('No se pudo actualizar el estado del pedido:\n$e'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _cancelarPedido() async {
    if (_pedidoActual == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.accessToken ?? '';

    final ubicacion = _pedidoActual!['location'];
    final volume = _pedidoActual!['volume'];
    final totalPayable = _pedidoActual!['total_payable'];

    final Map<String, dynamic> updatedData = {
      "location": {
        "latitude": ubicacion['latitude'],
        "longitude": ubicacion['longitude'],
        "capture_time": ubicacion['capture_time'],
      },
      "volume": volume,
      "state": "canceled",
      "total_payable": totalPayable,
    };

    final String idPedido = _pedidoActual!['id'];

    try {
      await OrderServices().updateOrder(
        id: idPedido,
        data: updatedData,
        token: token,
      );

      print('Pedido cancelado exitosamente.');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrega cancelada con éxito')),
      );

      setState(() {
        _ordenesAsignadas.remove(_pedidoActual);
        if (_ordenesAsignadas.isNotEmpty) {
          _pedidoActual = _ordenesAsignadas.first;
          _selectedOrderLocation = LatLng(
            _pedidoActual!['location']['latitude'],
            _pedidoActual!['location']['longitude'],
          );
          _panelMostrado = false;
        } else {
          _pedidoActual = null;
          _selectedOrderLocation = null;
        }
      });
    } catch (e) {
      print('Error al cancelar el pedido: $e');
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error'),
              content: Text('No se pudo cancelar el pedido:\n$e'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
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
                    ordenActual: _pedidoActual,
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
                    Positioned(
                      bottom: 150,
                      right: 16,
                      child: FloatingActionButton(
                        heroTag: 'test_btn',
                        onPressed: () {
                          if (_pedidoActual != null) {
                            _mostrarPanelEntrega(_pedidoActual!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No hay pedido activo'),
                              ),
                            );
                          }
                        },
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.info, color: Colors.white),
                      ),
                    ),
                  _pedidoActual != null
                      ? Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: OrderCard(
                              order: _pedidoActual!,
                              onVerEnMapa: (_) {},
                            ),
                          ),
                        ),
                      )
                      : OrderList(
                        ordersExpanded: _ordersExpanded,
                        toggleExpanded: () {
                          setState(() => _ordersExpanded = !_ordersExpanded);
                        },
                        onVerEnMapa: (pedidoSeleccionado, listaAsignada) {
                          setState(() {
                            _pedidoActual = pedidoSeleccionado;
                            _ordenesAsignadas = listaAsignada;
                            _selectedOrderLocation = LatLng(
                              pedidoSeleccionado['location']['latitude'],
                              pedidoSeleccionado['location']['longitude'],
                            );
                            _ordersExpanded = false;
                          });
                        },
                      ),
                ],
              ),
        ),
      ),
    );
  }
}
