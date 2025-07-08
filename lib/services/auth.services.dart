import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigfrontend/utils/constants.dart';

class AutenticacionServices {
  Future<Map<String, dynamic>?> loginUsuario({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return null; // Evita enviar solicitudes con campos vacíos
    }

    try {
      final response = await http.post(
        Uri.parse('${Constantes.urlRender}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  Future<Map<String, dynamic>?> registerUsuario({
    required String email,
    required String password,
    required String name,
    required int phoneNumber,
  }) async {
    try {
      print('Enviando solicitud de registro a ${Constantes.urlRender}/auth/register'); // Debug
      final response = await http.post(
        Uri.parse('${Constantes.urlRender}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone_number': phoneNumber,
        }),
      );

      print('Respuesta del servidor (registro): ${response.statusCode} - ${response.body}'); // Debug

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error al registrarse: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en registerUsuario: $e'); // Debug
      rethrow;
    }
  }


}
