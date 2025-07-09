import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigfrontend/utils/constants.dart';

class DeliveryVehicleService {
  final String _baseUrl = '${Constantes.urlRender}/delivery-vehicles';

  // Registrar un nuevo vehículo
  Future<Map<String, dynamic>> registerVehicle({
    required String licensePlate,
    required String typeVehicle,
    required int capacity,
    required String userId,
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
          'license_plate': licensePlate,
          'type_vehicle': typeVehicle,
          'capacity': capacity,
          'userId': userId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al registrar vehículo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener vehículo por ID de usuario
  Future<Map<String, dynamic>> getVehicleByUserId({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is List) {
          return responseData.isNotEmpty ? responseData.first : {};
        }
        return responseData;
      } else {
        throw Exception('Error al obtener vehículo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Establecer vehículo como operacional
  Future<Map<String, dynamic>> setVehicleOperational({
    required String userId,
    required String vehicleId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/set-operational/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'vehicleId': vehicleId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al establecer vehículo como operacional: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar DeliveryOrderService para incluir vehicleId del usuario
  Future<Map<String, dynamic>> acceptOrderWithUserVehicle({
    required String orderId,
    required String userId,
    required String token,
  }) async {
    try {
      // 1. Obtener el vehículo del usuario
      final vehicle = await getVehicleByUserId(userId: userId, token: token);
      
      if (vehicle.isEmpty || vehicle['id'] == null) {
        throw Exception('El usuario no tiene un vehículo registrado');
      }

      final vehicleId = vehicle['id'] as String;

      // 2. Crear la orden de entrega
      final deliveryOrder = await http.post(
        Uri.parse('${Constantes.urlRender}/delivery-orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'orderId': orderId,
          'deliveryVehicleId': vehicleId,
        }),
      );

      if (deliveryOrder.statusCode == 201 || deliveryOrder.statusCode == 200) {
        return jsonDecode(deliveryOrder.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al aceptar orden: ${deliveryOrder.statusCode} - ${deliveryOrder.body}');
      }
    } catch (e) {
      throw Exception('Error al aceptar orden: $e');
    }
  }
}

enum VehicleType {
  bike('BIKE'),
  motorcycle('MOTORCYCLE'),
  car('CAR'),
  truck('TRUCK');

  final String value;
  const VehicleType(this.value);

  factory VehicleType.fromString(String value) {
    switch (value.toUpperCase()) {
      case 'BIKE':
        return VehicleType.bike;
      case 'MOTORCYCLE':
        return VehicleType.motorcycle;
      case 'CAR':
        return VehicleType.car;
      case 'TRUCK':
        return VehicleType.truck;
      default:
        throw ArgumentError('Tipo de vehículo no válido: $value');
    }
  }

  @override
  String toString() => value;
}

enum VehicleState {
  operational('OPERATIONAL'),
  maintenance('MAINTENANCE'),
  unavailable('UNAVAILABLE');

  final String value;
  const VehicleState(this.value);

  factory VehicleState.fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OPERATIONAL':
        return VehicleState.operational;
      case 'MAINTENANCE':
        return VehicleState.maintenance;
      case 'UNAVAILABLE':
        return VehicleState.unavailable;
      default:
        throw ArgumentError('Estado de vehículo no válido: $value');
    }
  }

  @override
  String toString() => value;
}