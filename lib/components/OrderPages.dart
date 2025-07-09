import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/OrderCard.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/services/orderServices.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
  
}
class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> _ordenes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    try {
      final token = Provider.of<UserProvider>(context, listen: false).accessToken;
      if (token == null) {
        print('Token no disponible');
        return;
      }
      final ordenes = await OrderServices().getAllOrders(token: token);
      setState(() {
        _ordenes = ordenes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar órdenes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // AQUÍ VA la función que me preguntaste
  Widget buildOrderList(List<dynamic> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No hay órdenes disponibles por ahora.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(order: order); // Este widget lo defines aparte
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildOrderList(_ordenes),
    );
  }
}
