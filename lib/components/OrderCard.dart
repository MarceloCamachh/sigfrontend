import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final location = order['location'] ?? {};
    final volume = order['volume'];
    final totalPayable = order['total_payable'];
    final state = order['state'];
    final latitude = location['latitude'];
    final longitude = location['longitude'];
    final captureTime = location['capture_time'];

    final formattedDate = captureTime != null
        ? DateFormat.yMMMMd('es_ES').add_Hm().format(DateTime.parse(captureTime))
        : 'Sin fecha';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.local_shipping, color: Colors.red, size: 32),
        title: Text('Orden: \$${totalPayable.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Volumen: ${volume.toString()} m³'),
            Text('Estado: ${state.toString().toUpperCase()}'),
            const SizedBox(height: 4),
            Text('Ubicación: $latitude, $longitude'),
            Text('Fecha de captura: $formattedDate'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: () {
          // Aquí puedes navegar al detalle
        },
      ),
    );
  }
}
