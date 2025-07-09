import 'package:flutter/material.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/models/registerData.dart';
import 'package:sigfrontend/pages/registerPages/register3.dart';

class RegistroPaso2Page extends StatelessWidget {
  final RegisterData data;

  const RegistroPaso2Page({super.key, required this.data});

  void _continuar(BuildContext context, bool esMayorEdad) {
    if (!esMayorEdad) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Debes ser mayor de edad para registrarte como rider',
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    data.isAdult = true;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegistroPaso3Page(data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Registro - Paso 2',
        title2: '',
        icon: Icons.arrow_back_ios_rounded,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Eres mayor de edad?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Debes ser mayor de 18 años para registrarte como rider.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 24),
              label: const Text('Sí, soy mayor de edad'),
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
              onPressed: () => _continuar(context, true),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel, size: 24),
              label: const Text('No, soy menor de edad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.grey[800],
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
              onPressed: () => _continuar(context, false),
            ),
          ],
        ),
      ),
    );
  }
}
