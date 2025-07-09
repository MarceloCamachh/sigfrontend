import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar usuarios: $e')));
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
            title: const Text('Editar usuario'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await service.updateUser(user['id'], {
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone_number': int.tryParse(phoneController.text),
                  });
                  Navigator.pop(context);
                  await loadUsers(service);
                },
                child: const Text('Guardar'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de usuarios'),
        backgroundColor: const Color.fromARGB(255, 248, 2, 15),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () => loadUsers(userService),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _users.length,
                  itemBuilder: (_, index) {
                    final user = _users[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              user['state'] == 'available'
                                  ? Colors.green
                                  : Colors.grey,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user['email'] ?? 'Sin email',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Teléfono: ${user['phone_number'] ?? "N/A"}'),
                            Text(
                              'Estado: ${user['state']}',
                              style: TextStyle(
                                color:
                                    user['state'] == 'available'
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'activar':
                                await userService.enableUser(user['id']);
                                break;
                              case 'desactivar':
                                await userService.disableUser(user['id']);
                                break;
                              case 'editar':
                                _editUser(userService, user);
                                return;
                              case 'eliminar':
                                await userService.deleteUser(user['id']);
                                break;
                            }
                            await loadUsers(userService);
                          },
                          itemBuilder:
                              (_) => [
                                if (user['state'] == 'available')
                                  const PopupMenuItem(
                                    value: 'desactivar',
                                    child: Text('Desactivar'),
                                  ),
                                if (user['state'] != 'available')
                                  const PopupMenuItem(
                                    value: 'activar',
                                    child: Text('Activar'),
                                  ),
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Text('Editar Usuario'),
                                ),
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Text('Eliminar'),
                                ),
                              ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
