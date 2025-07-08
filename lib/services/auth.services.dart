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
}
