import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/pages/Delivery/OrderDetailPage.dart';
import 'package:sigfrontend/pages/home.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/services/orderServices.dart';

class UserDeliveryPage extends StatefulWidget {
  const UserDeliveryPage({super.key});

  @override
  State<UserDeliveryPage> createState() => _UserDeliveryPageState();
}

class _UserDeliveryPageState extends State<UserDeliveryPage> {
  List<dynamic> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => loading = true);
    try {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
      final userId = Provider.of<UserProvider>(context, listen: false).id;
      if (token == null || userId == null) {
        throw Exception("Token o ID de usuario no disponible");
      }

      final fetchedOrders = await OrderServices().getOrderByUser(
        userId,
        token: token,
      );

      setState(() {
        orders = fetchedOrders;
        loading = false;
      });

      if (fetchedOrders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes entregas realizadas')),
        );
      }
    } catch (e) {
      print("Error al obtener pedidos: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar pedidos: $e")));
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Mis Entregas',
        title2: '',
        color: Colors.deepPurpleAccent,
        icon: Icons.motorcycle_sharp,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                ? const Center(
                  child: Text(
                    'No tienes entregas pendientes',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Column(
                      children: [
                        UserOrderCard(
                          order: order,
                          onViewDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailPage(order: order),
                              ),
                            );
                          },
                          onViewMap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomePage(pedidoInicial: order),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 30),
                      ],
                    );
                  },
                ),
      ),
    );
  }
}

class UserOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onViewDetails;
  final VoidCallback onViewMap;

  const UserOrderCard({
    super.key,
    required this.order,
    required this.onViewDetails,
    required this.onViewMap,
  });

  Color _getStatusColor(String state, bool isAssigned) {
    if (isAssigned) return Colors.orange;
    switch (state.toUpperCase()) {
      case 'PENDING':
        return Colors.grey;
      case 'IN_TRANSIT':
        return Colors.blue;
      case 'DELIVERED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String state, bool isAssigned) {
    if (isAssigned) return 'Asignado';
    switch (state.toUpperCase()) {
      case 'PENDING':
        return 'Pendiente';
      case 'IN_TRANSIT':
        return 'En tránsito';
      case 'DELIVERED':
        return 'Entregado';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = order['id'] ?? 'N/A';
    final state = order['state'] ?? 'PENDING';
    final totalPayable = order['total_payable']?.toDouble() ?? 0.0;
    final volume = order['volume']?.toDouble() ?? 0.0;
    final deliveryOrders = order['deliveryOrders'] ?? [];
    final isAssigned =
        deliveryOrders.isNotEmpty &&
        deliveryOrders.any((d) => d['delivery_state'] == 'assigned');

    final statusText = _getStatusText(state, isAssigned);
    final statusColor = _getStatusColor(state, isAssigned);

    return GestureDetector(
      onTap: onViewDetails,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isAssigned
                    ? Colors.orange.shade100
                    : Colors.deepPurple.shade100,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Pedido #$id',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bs. ${totalPayable.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '$volume m³',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_pin,
                      color: Colors.black54,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order['location'] != null
                            ? '(${order['location']['latitude']}, ${order['location']['longitude']})'
                            : 'Ubicación no disponible',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.map, color: Colors.deepPurple),
                      onPressed: onViewMap,
                    ),
                  ],
                ),
                if (isAssigned)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Asignado a repartidor',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
