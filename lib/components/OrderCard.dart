import 'package:flutter/material.dart';
import 'package:sigfrontend/components/mapainternopage.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({
    super.key,
    required this.order,
  });

  Color _getStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'PENDING':
        return Colors.black;
      case 'IN_TRANSIT':
        return Colors.blue;
      case 'DELIVERED':
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  String _getStateText(String state) {
    switch (state.toUpperCase()) {
      case 'PENDING':
        return 'Pendiente';
      case 'IN_TRANSIT':
        return 'En tránsito';
      case 'DELIVERED':
        return 'Entregado';
      default:
        return state;
    }
  }

  void _mostrarMapaInterno(BuildContext context, double lat, double lng) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaInternoPage(lat: lat, lng: lng),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = order["id"];
    final state = order["state"] ?? "PENDING";
    final volume = order["volume"] ?? 0;
    final totalPayable = order["total_payable"] ?? 0;
    final location = order["location"];
    final deliveryOrder = order["deliveryOrder"];

    final stateText = _getStateText(state);
    final stateColor = _getStateColor(state);

    final deliveryVehicle = deliveryOrder != null ? deliveryOrder["deliveryVehicle"] : null;
    final deliveryUser = deliveryVehicle != null ? deliveryVehicle["user"] : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: state == "PENDING" ? Colors.indigo.shade700 : Colors.red.shade700,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Orden #$id',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

            // Info principal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bs. ${totalPayable.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$volume m³',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ubicación
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
                    onPressed: () => _mostrarMapaInterno(
                      context,
                      location["latitude"],
                      location["longitude"],
                    ),
                  ),
                ],
              ),

            if (location != null &&
                (location["address"] != null || location["reference"] != null))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (location["address"] != null)
                    Text('Dirección: ${location["address"]}', style: const TextStyle(color: Colors.white)),
                  if (location["reference"] != null)
                    Text('Referencia: ${location["reference"]}', style: const TextStyle(color: Colors.white70)),
                ],
              ),

            const SizedBox(height: 12),

            // Repartidor asignado
            if (deliveryVehicle != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white54),
                  Text(
                    '🛵 Repartidor asignado:',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  if (deliveryUser != null) ...[
                    Text('Nombre: ${deliveryUser["name"] ?? "(sin nombre)"}', style: const TextStyle(color: Colors.white70)),
                    Text('Correo: ${deliveryUser["email"] ?? "(sin correo)"}', style: const TextStyle(color: Colors.white70)),
                    Text('Teléfono: ${deliveryUser["phone_number"] ?? "(sin teléfono)"}', style: const TextStyle(color: Colors.white70)),
                  ] else ...[
                    Text('Placa: ${deliveryVehicle["license_plate"] ?? "(sin placa)"}', style: const TextStyle(color: Colors.white70)),
                  ],
                  Text('Estado de entrega: ${deliveryOrder["delivery_state"] ?? "N/A"}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
