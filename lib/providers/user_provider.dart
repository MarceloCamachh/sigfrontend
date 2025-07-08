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

  Future<void> setUserData(Map<String, dynamic> data) async {
    final user = data['user'];
    _id = user['id'];
    _email = user['email'];
    _phoneNumber = user['phone_number'];
    _state = user['state'];
    _role = user['role']?['name'];
    _accessToken = data['access_token'];
    _refreshToken = data['refresh_token'];

    await _storage.write(key: 'access_token', value: _accessToken);
    await _storage.write(key: 'refresh_token', value: _refreshToken);

    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
    // Aquí podrías decodificar el token para extraer los datos del usuario si lo necesitas
    notifyListeners();
  }

  Future<void> clearUser() async {
    await _storage.deleteAll();
    _id = null;
    _email = null;
    _phoneNumber = null;
    _state = null;
    _role = null;
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }
}
