import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _id;
  String? _email;
  int? _phoneNumber;
  String? _state;
  String? _role;
  String? _accessToken;
  String? _refreshToken;

  String? get id => _id;
  String? get email => _email;
  int? get phoneNumber => _phoneNumber;
  String? get state => _state;
  String? get role => _role;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Error: Token JWT inválido');
        return null;
      }

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);

      // Convierte el string JSON a un mapa.
      final decodedMap = jsonDecode(decodedString) as Map<String, dynamic>;
      return decodedMap;
    } catch (e) {
      print('Error al decodificar el JWT: $e');
      return null;
    }
  }

  Future<void> setUserData(Map<String, dynamic> data) async {
    try {
      final user = data['user'];
      _id = user['id'] as String?;
      _email = user['email'] as String?;
      _phoneNumber = user['phone_number'] as int?;
      _state = user['state'] as String?;
      _role = user['role']?['name'] as String?;
      _accessToken = data['access_token'] as String?;
      _refreshToken = data['refresh_token'] as String?;

      await _storage.write(key: 'id', value: _id);
      await _storage.write(key: 'email', value: _email);
      // Convertir int a String para guardarlo
      await _storage.write(key: 'phoneNumber', value: _phoneNumber?.toString());
      await _storage.write(key: 'state', value: _state);
      await _storage.write(key: 'role', value: _role);
      // Guardar los tokens de acceso y actualización
      if (_accessToken != null) {
        await _storage.write(key: 'access_token', value: _accessToken);
        await _storage.write(
          key: 'login_timestamp',
          value: DateTime.now().toIso8601String(),
        );
      }
      if (_refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: _refreshToken);
      }

      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('Error al establecer los datos del usuario: \$e');
    }
  }

  Future<void> loadUserFromStorage() async {
    try {
      _accessToken = await _storage.read(key: 'access_token');
      _refreshToken = await _storage.read(key: 'refresh_token');
      // Cargar los demás datos del usuario desde el almacenamiento
      _id = await _storage.read(key: 'id');
      _email = await _storage.read(key: 'email');
      final phoneNumberStr = await _storage.read(key: 'phoneNumber');
      _phoneNumber =
          phoneNumberStr != null ? int.tryParse(phoneNumberStr) : null;
      _state = await _storage.read(key: 'state');
      _role = await _storage.read(key: 'role');

      if (_accessToken != null) {
        final decodedToken = _decodeJwt(_accessToken!);
        if (decodedToken != null) {
          // ignore: avoid_print
          print(JsonEncoder.withIndent('  ').convert(decodedToken));
        }
      }

      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print(
        'Error al cargar los datos del usuario desde el almacenamiento: $e',
      );
    }
  }

  Future<bool> isSessionValid() async {
    final accessToken = await _storage.read(key: 'access_token');
    final loginTimestamp = await _storage.read(key: 'login_timestamp');

    if (accessToken != null && loginTimestamp != null) {
      final loginDate = DateTime.parse(loginTimestamp);
      final now = DateTime.now();
      final difference = now.difference(loginDate);

      if (difference.inDays < 7) {
        await loadUserFromStorage();
        return true;
      }
    }
    await clearUser();
    return false;
  }

  Future<void> clearUser() async {
    try {
      await _storage.deleteAll();
      _id = null;
      _email = null;
      _phoneNumber = null;
      _state = null;
      _role = null;
      _accessToken = null;
      _refreshToken = null;
      notifyListeners();
    } catch (e) {
      print('Error al limpiar los datos del usuario: $e');
    }
  }
}
