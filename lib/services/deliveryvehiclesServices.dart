import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigfrontend/utils/constants.dart';

class Deliveryvehiclesservices {
  Future<Map<String, dynamic>?> registrarVehiculo({
    required String licensePlate,
    required String typeVehicle,
    required int capacity,
    required String userId,
    required String token,
  }) async {
    try {
      print('Preparando registro de vehículo en ${Constantes.urlRender}/delivery-vehicles'); // Debug
      print('Token que se enviará: Bearer $token'); // Debug
      
      final response = await http.post(
        Uri.parse('${Constantes.urlRender}/delivery-vehicles'),
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

      print('Respuesta del servidor (vehículo): ${response.statusCode} - ${response.body}'); // Debug

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al registrar vehículo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en registrarVehiculo: $e'); // Debug
      rethrow;
    }
  }


}

enum VehicleType {
  bike,
  motorcycle,
  car,
  truck,
}

extension VehicleTypeExtension on VehicleType {
  String get asString {
    switch (this) {
      case VehicleType.bike:
        return 'bike';
      case VehicleType.motorcycle:
        return 'motorcycle';
      case VehicleType.car:
        return 'car';
      case VehicleType.truck:
        return 'truck';
    }
  }
}
