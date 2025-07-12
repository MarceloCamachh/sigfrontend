import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  final String _baseUrl = 'https://tudominio.com/locations'; // Reemplaza con tu dominio real

  // Crear nueva ubicación
  Future<Map<String, dynamic>> createLocation({
    required double latitude,
    required double longitude,
    required DateTime captureTime,
    required String token, // si usas autenticación
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // O elimina si no es necesario
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'capture_time': captureTime.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear ubicación: ${response.body}');
    }
  }

  // Obtener ubicación por ID
  Future<Map<String, dynamic>> getLocationById(String id, String token) async {
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
      throw Exception('Ubicación no encontrada: ${response.body}');
    }
  }
}
