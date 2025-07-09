import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigfrontend/utils/constants.dart';

class UserService {
  final String token;
  UserService(this.token);

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('${Constantes.urlRender}/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    await http.patch(
      Uri.parse('${Constantes.urlRender}/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updates),
    );
  }

  Future<void> deleteUser(String id) async {
    await http.delete(
      Uri.parse('${Constantes.urlRender}/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> disableUser(String id) async {
    await http.post(
      Uri.parse('${Constantes.urlRender}/users/disable/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> enableUser(String id) async {
    await http.post(
      Uri.parse('${Constantes.urlRender}/users/enable/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
