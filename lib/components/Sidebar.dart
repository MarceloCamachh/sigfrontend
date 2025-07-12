import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/WabeClipper.dart';
import 'package:sigfrontend/pages/Delivery/delivery_management.dart';
import 'package:sigfrontend/pages/home.dart';
import 'package:sigfrontend/pages/splash_screen.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/pages/User/UserManagementPage .dart';
import 'package:sigfrontend/pages/User/UserProfilePage.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  String obtenerSaludo() {
    final horaActual = DateTime.now().hour;
    if (horaActual >= 6 && horaActual < 12) {
      return 'Buenos días';
    } else if (horaActual >= 12 && horaActual < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final saludo = obtenerSaludo();

    return Drawer(
      child: SafeArea(
        child: Stack(
          children: [
            ClipPath(
              clipper: WaveClipper(),
              child: Container(height: 140, color: Color(0xFFf40008)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          saludo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          userProvider.email ?? 'Usuario no autenticado',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  /// Lista de opciones
                  Expanded(
                    child: ListView(
                      children: [
                        _alingedText('Home', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        }, Icons.home),
                        const Divider(indent: 0, endIndent: 0),
                        _alingedText('Mi Perfil', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserProfilePage(),
                            ),
                          );
                        }, Icons.person),

                        if (userProvider.role == 'ADMINISTRADOR') ...[
                          const Divider(indent: 0, endIndent: 0),
                          _alingedText(
                            'Gestionar usuarios',
                            () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const UserManagementPage(),
                                ),
                              );
                            },
                            Icons.supervisor_account_outlined,
                          ),
                          _alingedText('Gestionar Entregas', () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const DeliveryManagement(),
                              ),
                            );
                          }, Icons.local_shipping_outlined),
                        ],
                        const Divider(indent: 0, endIndent: 0),
                        _alingedText('Configuración', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        }, Icons.settings_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Cerrar sesión al fondo
                  const Divider(indent: 0, endIndent: 0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      leading: const Icon(
                        Icons.logout_outlined,
                        color: Color(0xFFf28386),
                      ),
                      onTap: () {
                        userProvider.clearUser();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SplashScreen(),
                          ),
                        );
                      },
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

  Widget _alingedText(String text, VoidCallback onTap, IconData icon) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        leading: Icon(icon, color: Color(0xFFf28386)),
        onTap: onTap,
      ),
    );
  }
}
