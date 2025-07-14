import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigfrontend/utils/constants.dart';

class DeliveryOrderService {
  final String _baseUrl = '${Constantes.urlRender}/delivery-orders';

  /// Crea una nueva orden de entrega y asigna un repartidor
  Future<Map<String, dynamic>> assignDeliveryVehicleToOrder({
    required String orderId,
    required String deliveryVehicleId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'orderId': orderId,
          'deliveryVehicleId': deliveryVehicleId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al asignar vehículo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Actualiza el estado de una orden de entrega (ej. IN_TRANSIT, DELIVERED)
  Future<Map<String, dynamic>> updateDeliveryOrderState({
    required String id,
    required String deliveryState,
    required String token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$id/state'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'delivery_state': deliveryState}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar estado: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene todas las órdenes de entrega registradas
  Future<List<dynamic>> getAllDeliveryOrders({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Error al obtener órdenes de entrega: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene una orden de entrega específica por su ID
  Future<Map<String, dynamic>> getDeliveryOrderById({
    required String id,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener orden de entrega: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> cancelDeliveryOrder({
    required String id,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al cancelar orden de entrega: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
