import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/WabeClipper.dart';
import 'package:sigfrontend/pages/home.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/pages/User/UserManagementPage .dart';

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
    final isAdmin = userProvider.role == 'admin';
    return Drawer(
      child: SafeArea(
        child: Stack(
          children: [
            ClipPath(
              clipper: WaveClipper(),
              child: Container(height: 140, color: Colors.red),
            ),

            ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 40),
                _listTile(
                  'Home',
                  Icons.home_outlined,
                  context,
                  const HomePage(),
                ),
                _listTile(
                  'Configuracion',
                  Icons.settings_outlined,
                  context,
                  const HomePage(),
                ),
                _listTile(
                  'Administrar usuarios',
                  Icons.supervisor_account_outlined,
                  context,
                  const UserManagementPage(), // 👈 tu vista de administración
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTile(
    String title,
    IconData icon,
    BuildContext context,
    Widget destinationScreen,
  ) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      leading: Icon(icon),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
    );
  }
}
