import 'package:sigfrontend/services/deliveryvehiclesServices.dart';

class RegisterData {
  String name = '';
  String lastName = '';
  bool isAdult = false;
  VehicleType? transport;
  String city = '';
  String email = '';
  String password = '';
  int phoneNumber = 0;

  // Para moto
  String? licensePlate;
  int? capacity;
}
