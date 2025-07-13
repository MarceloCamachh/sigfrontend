import 'package:flutter/material.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/pages/home.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});

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
    final location = order['location'] ?? {};
    final deliveryOrders = order['deliveryOrders'] ?? [];
    final payments = order['payments'] ?? [];
    final isAssigned =
        deliveryOrders.isNotEmpty &&
        deliveryOrders.any((d) => d['delivery_state'] == 'assigned');

    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Detalles del Pedido',
        title2: '#$id',
        color: Colors.deepPurpleAccent,
        icon: Icons.manage_search_rounded,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información General',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('ID del Pedido', id),
                    _buildInfoRow('Estado', _getStatusText(state, isAssigned)),
                    _buildInfoRow(
                      'Monto Total',
                      'Bs. ${totalPayable.toStringAsFixed(2)}',
                    ),
                    _buildInfoRow('Volumen', '$volume m³'),
                    if (isAssigned)
                      _buildInfoRow(
                        'Estado de Entrega',
                        'Asignado a repartidor',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubicación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Coordenadas',
                      location.isNotEmpty
                          ? '(${location['latitude']}, ${location['longitude']})'
                          : 'No disponible',
                    ),
                    _buildInfoRow(
                      'Capturado en',
                      location['capture_time'] != null
                          ? _formatDate(location['capture_time'])
                          : 'No disponible',
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed:
                            location['latitude'] != null &&
                                    location['longitude'] != null
                                ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => HomePage(pedidoInicial: order),
                                    ),
                                  );
                                }
                                : null,
                        icon: const Icon(Icons.map),
                        label: const Text('Ver en Mapa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (payments.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pagos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...payments
                              .map(
                                (payment) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                      'ID de Pago',
                                      payment['id'] ?? 'N/A',
                                    ),
                                    _buildInfoRow(
                                      'Tipo',
                                      payment['type']?.toUpperCase() ?? 'N/A',
                                    ),
                                    _buildInfoRow(
                                      'Monto',
                                      'Bs. ${payment['amount']?.toStringAsFixed(2) ?? '0.00'}',
                                    ),
                                    _buildInfoRow(
                                      'Creado',
                                      _formatDate(payment['created_at'] ?? ''),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'No disponible';
    }
  }
}
