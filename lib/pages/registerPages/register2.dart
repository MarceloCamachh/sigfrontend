import 'package:flutter/material.dart';
import 'package:sigfrontend/models/registerData.dart';
import 'package:sigfrontend/pages/registerPages/register3.dart';

class RegistroPaso2Page extends StatelessWidget {
  final RegisterData data;

  const RegistroPaso2Page({super.key, required this.data});

  void _continuar(BuildContext context, bool esMayorEdad) {
    if (!esMayorEdad) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes ser mayor de edad para registrarte como rider'),
        ),
      );
      return;
    }

    data.isAdult = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistroPaso3Page(data: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro - Paso 2")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "¿Eres mayor de edad?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Sí, soy mayor de edad"),
              onPressed: () => _continuar(context, true),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text("No, soy menor de edad"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              onPressed: () => _continuar(context, false),
            ),
          ],
        ),
      ),
    );
  }
}
