import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/components/CustomDeliveryDropdown.dart';
import 'package:sigfrontend/components/OrderCard.dart';
import 'package:sigfrontend/pages/home.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/services/orderServices.dart';
import 'package:sigfrontend/services/deliveryvehiclesServices.dart';

class DeliveryManagement extends StatefulWidget {
  const DeliveryManagement({super.key});

  @override
  State<DeliveryManagement> createState() => _DeliveryManagementState();
}

class _DeliveryManagementState extends State<DeliveryManagement> {
  List<dynamic> _orders = [];
  List<DeliveryPerson> _repartidores = [];
  bool _loading = true;

  // Mapea orderId a vehicleId seleccionado
  final Map<String, String> _selectedVehiclePerOrder = {};

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _loading = true);
    try {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
      if (token == null) throw Exception("Token no disponible");

      final orders = await OrderServices().getAllOrders(token: token);
      final rawRepartidores = await DeliveryVehicleService().getAllVehicles(
        token,
      );

      setState(() {
        _orders = orders;
        _repartidores =
            // ignore: unnecessary_cast
            rawRepartidores
                    .where(
                      (r) =>
                          r['user'] != null &&
                          r['id'] != null &&
                          r['user']['name'] != null,
                    )
                    .map<DeliveryPerson>((repartidor) {
                      return DeliveryPerson(
                        id: repartidor['id'] as String,
                        name: repartidor['user']['name'] as String,
                      );
                    })
                    .toList()
                as List<DeliveryPerson>;
        _loading = false;
      });
    } catch (e) {
      print("Error al obtener datos: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar datos: $e")));
      setState(() => _loading = false);
    }
  }

  Future<void> _assignOrderToVehicle(String orderId) async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final selectedVehicleId = _selectedVehiclePerOrder[orderId];

    final order = _orders.firstWhere(
      (o) => o['id'] == orderId,
      orElse: () => null,
    );
    final isAssigned =
        order != null &&
        (order['deliveryOrders'] ?? []).isNotEmpty &&
        (order['deliveryOrders'] as List).any(
          (d) => d['delivery_state'] == 'assigned',
        );

    if (isAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este pedido ya está asignado a un repartidor."),
        ),
      );
      return;
    }

    if (selectedVehicleId == null || selectedVehicleId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un repartidor primero.")),
      );
      return;
    }

    try {
      await DeliveryVehicleService().assignOrderToVehicle(
        orderId: orderId,
        vehicleId: selectedVehicleId,
        token: token!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Orden asignada correctamente.")),
      );

      await _fetchInitialData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al asignar: $e")));
    }
  }

  String? _getAssignedDeliveryPersonName(Map<String, dynamic> order) {
    print(order);
    final deliveryOrders = order['deliveryOrders'] ?? [];
    if (deliveryOrders.isNotEmpty) {
      final deliveryOrder = deliveryOrders[0];
      final vehicleId = deliveryOrder['deliveryVehicle']?['id'];
      if (vehicleId != null) {
        final deliveryPerson = _repartidores.firstWhere(
          (r) => r.id == vehicleId,
          orElse: () => DeliveryPerson(id: '', name: 'Desconocido'),
        );
        return deliveryPerson.name;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Gestión de Entregas',
        title2: '',
        color: const Color.fromARGB(255, 223, 122, 27),
        icon: Icons.local_shipping_rounded,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? const Center(child: Text("No hay órdenes disponibles"))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final orderId = order['id'];
                  final isAssigned =
                      (order['deliveryOrders'] ?? []).isNotEmpty &&
                      (order['deliveryOrders'] as List).any(
                        (d) => d['delivery_state'] == 'assigned',
                      );
                  final assignedDeliveryPersonName =
                      _getAssignedDeliveryPersonName(order);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrderCard(
                        order: order,
                        onVerEnMapa: (orden) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HomePage(pedidoInicial: orden),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      isAssigned
                          ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'Asignado a: ${assignedDeliveryPersonName ?? "Repartidor desconocido"}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                          : CustomDeliveryDropdown(
                            selectedValue: _selectedVehiclePerOrder[orderId],
                            repartidores: _repartidores,
                            onChanged: (value) {
                              setState(() {
                                if (value == null || value.isEmpty) {
                                  _selectedVehiclePerOrder.remove(orderId);
                                } else {
                                  print(
                                    "Selected vehicle: $value for order: $orderId",
                                  );
                                  _selectedVehiclePerOrder[orderId] = value;
                                }
                              });
                            },
                          ),
                      const SizedBox(height: 6),
                      isAssigned
                          ? const SizedBox.shrink()
                          : ElevatedButton.icon(
                            onPressed: () => _assignOrderToVehicle(orderId),
                            icon: const Icon(Icons.send),
                            label: const Text("Asignar Repartidor"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      const Divider(height: 30),
                    ],
                  );
                },
              ),
    );
  }
}
