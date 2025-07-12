import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/OrderCard.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/services/orderServices.dart';

class OrderList extends StatefulWidget {
  final bool ordersExpanded;
  final VoidCallback toggleExpanded;

  const OrderList({
    super.key,
    required this.ordersExpanded,
    required this.toggleExpanded,
  });

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<dynamic> _ordenes = [];
  bool _cargandoOrdenes = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final token = Provider.of<UserProvider>(context, listen: false).accessToken;
      if (token == null) {
        print('Token no disponible');
        return;
      }
      final orders = await OrderServices().getAllOrders(token: token);
      setState(() {
        _ordenes = orders;
        _cargandoOrdenes = false;
      });
    } catch (e) {
      print('Error al obtener órdenes: $e');
      setState(() => _cargandoOrdenes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userRole = userProvider.role;
    final userId = userProvider.id;

    if (!widget.ordersExpanded) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.toggleExpanded,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: _cargandoOrdenes
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : _ordenes.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No hay órdenes disponibles',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: ListView.builder(
                          itemCount: _ordenes.length,
                          itemBuilder: (context, index) {
                            final order = _ordenes[index];
                            final deliveryOrder = order['deliveryOrder'];
                            final assignedUserId = deliveryOrder?['deliveryVehicle']?['user']?['id'];

                            final isVisible = userRole == 'ADMINISTRADOR' ||
                                (userRole == 'REPARTIDOR' && assignedUserId == userId);

                            return isVisible
                                ? OrderCard(order: order)
                                : const SizedBox.shrink();
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
