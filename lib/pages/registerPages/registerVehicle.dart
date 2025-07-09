import 'package:flutter/material.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/models/registerData.dart';
import 'package:sigfrontend/pages/registerPages/register4.dart';
import 'package:sigfrontend/services/deliveryvehiclesServices.dart';

class RegistroVehiculoPage extends StatefulWidget {
  final RegisterData data;

  const RegistroVehiculoPage({super.key, required this.data});

  @override
  State<RegistroVehiculoPage> createState() => _RegistroVehiculoPageState();
}

class _RegistroVehiculoPageState extends State<RegistroVehiculoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();

  String get nombreVehiculo {
    switch (widget.data.transport) {
      case VehicleType.motorcycle:
        return 'motocicleta';
      case VehicleType.car:
        return 'auto';
      case VehicleType.truck:
        return 'camión';
      default:
        return 'vehículo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Registro $nombreVehiculo',
        title2: '',
        icon: Icons.arrow_back_ios_rounded,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Ingresa los datos de tu $nombreVehiculo",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la placa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _capacidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacidad (kg)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la capacidad';
                  }
                  final capacidad = int.tryParse(value);
                  if (capacidad == null || capacidad <= 0) {
                    return 'Ingresa un número válido mayor a 0';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.data.licensePlate = _placaController.text;
                    widget.data.capacity = int.parse(_capacidadController.text);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegistroPaso4Page(data: widget.data),
                      ),
                    );
                  }
                },
                child: const Text('Siguiente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _placaController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }
}
