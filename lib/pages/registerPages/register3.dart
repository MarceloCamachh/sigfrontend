import 'package:flutter/material.dart';
import 'package:sigfrontend/models/registerData.dart';
import 'package:sigfrontend/pages/registerPages/register4.dart';
import 'package:sigfrontend/pages/registerPages/registerVehicle.dart';
import 'package:sigfrontend/services/deliveryvehiclesServices.dart';


class RegistroPaso3Page extends StatelessWidget {
  final RegisterData data;

  const RegistroPaso3Page({super.key, required this.data});

  void _seleccionarTransporte(BuildContext context, VehicleType tipo) {
      data.transport = tipo;

      if (tipo == VehicleType.bike) {
        // Si es bicicleta, no requiere datos de vehículo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegistroPaso4Page(data: data),
          ),
        );
      } else {
        // Si es moto, auto o camión → pedir datos del vehículo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegistroVehiculoPage(data: data),
          ),
        );
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro - Paso 3")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "¿Con qué vas a repartir?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_bike),
              label: const Text("Bicicleta"),
              onPressed: () => _seleccionarTransporte(context, VehicleType.bike),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.motorcycle),
              label: const Text("Motocicleta"),
              onPressed: () => _seleccionarTransporte(context, VehicleType.motorcycle),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: const Text("Auto"),
              onPressed: () => _seleccionarTransporte(context, VehicleType.car),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.local_shipping),
              label: const Text("Camión"),
              onPressed: () => _seleccionarTransporte(context, VehicleType.truck),
            ),
          ],
        ),
      ),
    );
  }
}
