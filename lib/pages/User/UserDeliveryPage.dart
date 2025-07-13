import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/services/deliveryOrderService.dart';

class UserDeliveryPage extends StatefulWidget {
  const UserDeliveryPage({super.key});

  @override
  State<UserDeliveryPage> createState() => _UserDeliveryPageState();
}

class _UserDeliveryPageState extends State<UserDeliveryPage> {
  final orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    if (token == null) throw Exception("Token no disponible");

    final _orders = await DeliveryOrderService().getAllDeliveryOrders(
      token: token,
    );
    print((_orders));
    setState(() {
      orders.addAll([
        {'id': 1, 'status': 'En camino'},
        {'id': 2, 'status': 'Entregado'},
      ]);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Mis Entregas',
        title2: '',
        color: Colors.deepPurpleAccent,
        icon: Icons.motorcycle_sharp,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
              ? const Center(child: Text('No tienes entregas pendientes'))
              : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text('Pedido #${order['id']}'),
                    subtitle: Text('Estado: ${order['status']}'),
                    leading: Icon(Icons.motorcycle),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Acción al seleccionar un pedido
                    },
                  );
                },
              ),
    );
  }
}
