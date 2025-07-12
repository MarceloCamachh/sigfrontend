import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/BottonChange.dart';
import 'package:sigfrontend/components/ContainerIcon.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/components/FadeThroughPageRoute.dart';
import 'package:sigfrontend/pages/registerPages/register.dart';
import 'package:sigfrontend/providers/UserService.dart';
import 'package:sigfrontend/providers/user_provider.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  Future<void> loadUsers(UserService service) async {
    setState(() => _isLoading = true);
    try {
      _users = await service.getAllUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _editUser(UserService service, Map<String, dynamic> user) async {
    final phoneController = TextEditingController(
      text: user['phone_number']?.toString() ?? '',
    );
    final nameController = TextEditingController(
      text: user['user_metadata']?['name'] ?? '',
    );
    final emailController = TextEditingController(text: user['email'] ?? '');

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            title: const Text(
              'Editar usuario',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await service.updateUser(user['id'], {
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone_number': int.tryParse(phoneController.text),
                  });
                  Navigator.pop(context);
                  await loadUsers(service);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Guardar', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    final token =
        Provider.of<UserProvider>(context, listen: false).accessToken!;
    final userService = UserService(token);
    loadUsers(userService);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userService = UserService(userProvider.accessToken!);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Gestión de Usuarios',
        title2: '',
        color: Colors.blueAccent,
        icon: Icons.arrow_back_ios_rounded,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue[700]),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando usuarios...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: BottonChange(
                      colorBack: Colors.black,
                      colorFont: Colors.white,
                      textTile: 'Agregar Usuario',
                      onPressed: () {
                        Navigator.of(context).push(
                          FadeThroughPageRoute(page: const RegistroPaso1Page()),
                        );
                      },
                      width: width * 0.9,
                      height: 50,
                      fontSize: 18,
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: Colors.blue[700],
                      backgroundColor: Colors.white,
                      onRefresh: () => loadUsers(userService),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (_, index) {
                          final user = _users[index];
                          return Card(
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.1),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              title: Text(
                                user['user_metadata']?['name'] ??
                                    user['email'] ??
                                    'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Correo: ${user['email'] ?? "N/A"}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Teléfono: ${user['phone_number'] ?? "N/A"}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            user['state'] == 'available'
                                                ? Colors.green[100]
                                                : Colors.red[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            user['state'] == 'available'
                                                ? Icons.check_circle
                                                : Icons.block,
                                            size: 18,
                                            color:
                                                user['state'] == 'available'
                                                    ? Colors.green[600]
                                                    : Colors.red[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            user['state'] == 'available'
                                                ? 'Activo'
                                                : 'Inactivo',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  user['state'] == 'available'
                                                      ? Colors.green[600]
                                                      : Colors.red[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ContainerIcon(
                                    icon: Icons.person,
                                    iconColor: Colors.white,
                                    containerColor: Color(0xFFf28386),
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.grey[600],
                                    ),
                                    onSelected: (value) async {
                                      switch (value) {
                                        case 'activar':
                                          await userService.enableUser(
                                            user['id'],
                                          );
                                          break;
                                        case 'desactivar':
                                          await userService.disableUser(
                                            user['id'],
                                          );
                                          break;
                                        case 'editar':
                                          _editUser(userService, user);
                                          return;
                                        case 'eliminar':
                                          await userService.deleteUser(
                                            user['id'],
                                          );
                                          break;
                                      }
                                      await loadUsers(userService);
                                    },
                                    itemBuilder:
                                        (_) => [
                                          if (user['state'] == 'available')
                                            PopupMenuItem(
                                              value: 'desactivar',
                                              child: Text(
                                                'Desactivar',
                                                style: TextStyle(
                                                  color: Colors.red[600],
                                                ),
                                              ),
                                            ),
                                          if (user['state'] != 'available')
                                            PopupMenuItem(
                                              value: 'activar',
                                              child: Text(
                                                'Activar',
                                                style: TextStyle(
                                                  color: Colors.green[600],
                                                ),
                                              ),
                                            ),
                                          PopupMenuItem(
                                            value: 'editar',
                                            child: Text(
                                              'Editar',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'eliminar',
                                            child: Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: Colors.red[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
