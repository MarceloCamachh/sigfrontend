import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(Map<String, dynamic>) onVerEnMapa;

  const OrderCard({super.key, required this.order, required this.onVerEnMapa});

  Color _getStateColor(String state, bool isAssigned) {
    if (state.toUpperCase() == 'DELIVERED') {
      return Colors.green;
    }
    if (isAssigned) {
      return Colors.orange;
    }
    switch (state.toUpperCase()) {
      case 'PENDING':
        return Colors.black;
      case 'IN_TRANSIT':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  String _getStateText(String state, bool isAssigned) {
    if (state.toUpperCase() == 'DELIVERED') {
      return 'Entregado';
    }
    if (isAssigned) {
      return 'Asignado';
    }
    switch (state.toUpperCase()) {
      case 'PENDING':
        return 'Pendiente';
      case 'IN_TRANSIT':
        return 'En tránsito';
      default:
        return state;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = order["id"] ?? 'N/A';
    final state = order["state"]?.toUpperCase() ?? "PENDING";
    final volume = order["volume"]?.toDouble() ?? 0.0;
    final totalPayable = order["total_payable"]?.toDouble() ?? 0.0;
    final location = order["location"];
    final deliveryOrders = order["deliveryOrders"] ?? [];
    final isAssigned =
        state != 'DELIVERED' &&
        deliveryOrders.isNotEmpty &&
        deliveryOrders.any((d) => d["delivery_state"] == "assigned");

    final stateText = _getStateText(state, isAssigned);
    final stateColor = _getStateColor(state, isAssigned);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color:
            state == 'DELIVERED'
                ? Colors.green.shade700
                : isAssigned
                ? Colors.orange.shade700
                : Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  state == 'DELIVERED'
                      ? Icons.check_circle
                      : Icons.local_shipping,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Orden #$id',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                    color: stateColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stateText,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bs. ${totalPayable.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$volume m³',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (location != null &&
                location["latitude"] != null &&
                location["longitude"] != null)
              Row(
                children: [
                  const Icon(Icons.location_pin, color: Colors.white),
                  Expanded(
                    child: Text(
                      '(${location["latitude"]}, ${location["longitude"]})',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map_outlined, color: Colors.white),
                    onPressed: () => onVerEnMapa(order),
                  ),
                ],
              ),
            if (isAssigned)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Asignado a repartidor',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (state == 'DELIVERED')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Entregado exitosamente',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
