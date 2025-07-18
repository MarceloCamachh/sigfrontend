import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/OrderCard.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/services/orderServices.dart';

class OrderList extends StatefulWidget {
  final bool ordersExpanded;
  final VoidCallback toggleExpanded;
  final void Function(Map<String, dynamic>, List<Map<String, dynamic>>)
  onVerEnMapa;

  final void Function(List<dynamic>) onOptimizarRutaCompleta;

  const OrderList({
    super.key,
    required this.ordersExpanded,
    required this.toggleExpanded,
    required this.onVerEnMapa,
    required this.onOptimizarRutaCompleta,
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
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
      if (token == null) {
        print('Token no disponible');
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      List<dynamic> orders = [];

      if (userProvider.role == 'ADMINISTRADOR') {
        final allOrders = await OrderServices().getAllOrders(token: token);
        orders =
            allOrders.where((order) => order['state'] != 'delivered').toList();
      } else if (userProvider.role == 'REPARTIDOR') {
        orders = await OrderServices().getOrderAllByUserState(
          userProvider.id!,
          'pending',
          token: token,
        );
      }

      setState(() {
        _ordenes = orders;
        _cargandoOrdenes = false;
      });
    } catch (e) {
      print('Error al obtener órdenes: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar órdenes: $e')));
      }
      setState(() => _cargandoOrdenes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _ordenes;

    final double carouselHeight = 200;
    final double titleBarHeight = 50;
    final double totalHeight = carouselHeight + titleBarHeight;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: widget.ordersExpanded ? 0 : -(totalHeight - titleBarHeight),
      left: 0,
      right: 0,
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.toggleExpanded,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.ordersExpanded ? 'Órdenes Asignadas' : 'Ver Órdenes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.ordersExpanded && _ordenes.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.route_outlined,
                        color: Colors.white,
                      ),
                      tooltip: 'Optimizar ruta de entrega',
                      onPressed: () {
                        // Llama al nuevo callback con la lista de órdenes
                        widget.onOptimizarRutaCompleta(_ordenes);
                      },
                    ),
                  Icon(
                    widget.ordersExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: carouselHeight,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
            clipBehavior: Clip.hardEdge,
            child:
                _cargandoOrdenes
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
                    : filteredOrders.isEmpty
                    ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'No hay órdenes disponibles',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 10.0,
                      ),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width:
                                MediaQuery.of(context).size.width *
                                (filteredOrders.length == 1 ? 0.91 : 0.8),
                            child: OrderCard(
                              order: order,
                              onVerEnMapa: (_) {
                                widget.onVerEnMapa(
                                  order,
                                  filteredOrders.cast<Map<String, dynamic>>(),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
