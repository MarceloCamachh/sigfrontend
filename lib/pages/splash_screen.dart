import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4), // Amarillo claro
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_bike,
                size: 100,
                color: Colors.black87,
              ),
              const SizedBox(height: 24),
              Text(
                'Bienvenido a SIG Rider',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              Text('Ingresar Como: ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
                
                ),
              const SizedBox(height: 40),
              _buildLoginButton(context, 'Administrador', Icons.admin_panel_settings, Colors.black),
              const SizedBox(height: 16),
              _buildLoginButton(context, 'Cliente', Icons.person, Colors.black),
              const SizedBox(height: 16),
              _buildLoginButton(context, 'Repartidor', Icons.delivery_dining, Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, String label, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Aquí puedes redirigir según el rol
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navegar como: $label')),
          );
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
