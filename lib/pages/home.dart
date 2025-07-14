import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/OrderCard.dart';
import 'package:sigfrontend/components/Sidebar.dart';
import 'package:sigfrontend/pages/map_widget.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/pages/Delivery/orderlist.dart';
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
  List<Map<String, dynamic>> _ordenesAsignadas = []; // Lista actual de pedidos
  Map<String, dynamic>? _pedidoActual; // Pedido que está siendo entregado
  bool _panelMostrado = false;
  final PaymentServices _paymentServices = PaymentServices();

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
      ); // *100 porque Stripe usa centavos

      await _paymentServices.presentPaymentSheet(clientSecret);

      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(content: Text("Pago realizado con éxito")),
      );

      _marcarPedidoComoCompletado();
    } catch (e) {
      print('Error al procesar el pago: $e');
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
          showDialog(
            context: context,
            builder:
                (_) => const AlertDialog(
                  content: Text("El pago fue cancelado por el usuario."),
                ),
          );
        } else {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  content: Text(
                    "Error en el pago: ${e.error.localizedMessage}",
                  ),
                ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text("Error en el pago: $e")),
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

    // Verificar si hay pedido actual y no se ha mostrado panel aún
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
        _pedidoActual = order;
        _panelMostrado = false; // Reinicia para permitir que se muestre
      });
    }
  }

  void _mostrarPanelEntrega(Map<String, dynamic> pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final monto = pedido['total_payable']?.toStringAsFixed(2) ?? '0.00';
        final id = pedido['id'] ?? 'N/A';

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pedido #$id'),
              Text('Monto: Bs. $monto'),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _procesarPagoYCompletar(context, pedido);
                },
                icon: const Icon(Icons.payment),
                label: const Text('Completar y Pagar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _marcarPedidoComoCompletado() {
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
                        child: const Icon(Icons.bolt),
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
