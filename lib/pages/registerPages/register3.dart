import 'package:flutter/material.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RegistroPaso4Page(data: data)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RegistroVehiculoPage(data: data)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Registro - Paso 3',
        title2: '',
        color: Colors.blueAccent,
        icon: Icons.app_registration_rounded,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Con qué vas a repartir?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona el tipo de vehículo que usarás para las entregas.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_bike, size: 24),
              label: const Text('Bicicleta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(width * 0.9, 50),
                elevation: 2,
              ),
              onPressed:
                  () => _seleccionarTransporte(context, VehicleType.bike),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.motorcycle, size: 24),
              label: const Text('Motocicleta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(width * 0.9, 50),
                elevation: 2,
              ),
              onPressed:
                  () => _seleccionarTransporte(context, VehicleType.motorcycle),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car, size: 24),
              label: const Text('Auto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(width * 0.9, 50),
                elevation: 2,
              ),
              onPressed: () => _seleccionarTransporte(context, VehicleType.car),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.local_shipping, size: 24),
              label: const Text('Camión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(width * 0.9, 50),
                elevation: 2,
              ),
              onPressed:
                  () => _seleccionarTransporte(context, VehicleType.truck),
            ),
          ],
        ),
      ),
    );
  }
}
