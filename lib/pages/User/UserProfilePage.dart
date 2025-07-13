import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/ContainerIcon.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/utils/constants.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final email = userProvider.email ?? 'Correo no disponible';
    final role = userProvider.role ?? 'Rol no disponible';
    final state = userProvider.state ?? 'Estado no disponible';
    final phone = userProvider.phoneNumber?.toString() ?? 'Sin teléfono';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFFf40008),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFf40008),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildInfoTile('Correo electrónico', email, Icons.email),
                  _buildInfoTile('Rol de usuario', role, Icons.badge),
                  _buildInfoTile('Estado', state, Icons.check_circle_outline),
                  _buildInfoTile('Teléfono', phone, Icons.phone),
                  const SizedBox(height: 40),
                  const Text(
                    'Gracias por formar parte del sistema',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: ContainerIcon(
          icon: icon,
          iconColor: Constantes.colorSecondary,
          containerColor: const Color.fromARGB(18, 0, 0, 0),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
