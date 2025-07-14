import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/ContainerIcon.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/utils/constants.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedState;
  String? _selectedRoleId;
  final Map<String, String> _roleMap = {
    '2cced261-681b-469f-a01c-1e0d53392fec': 'ADMINISTRADOR',
    '3fcd9711-fd2d-47c1-8cc1-92e6ed11a229': 'REPARTIDOR',
  };

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.name ?? '');
    _emailController = TextEditingController(text: userProvider.email ?? '');
    _phoneController = TextEditingController(
      text: userProvider.phoneNumber?.toString() ?? '',
    );
    _selectedState = userProvider.state;
    _selectedRoleId =
        _roleMap.entries
            .firstWhere(
              (entry) => entry.value == userProvider.role,
              orElse: () => _roleMap.entries.first,
            )
            .key;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(UserProvider userProvider) async {
    if (_formKey.currentState!.validate()) {
      final updates = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone_number': int.tryParse(_phoneController.text) ?? 0,
        'state': _selectedState,
        'roleId': _selectedRoleId,
      };
      try {
        await userProvider.updateUser(userProvider.id!, updates);
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Perfil actualizado con éxito')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final email = userProvider.email ?? 'Correo no disponible';
    final role = userProvider.role ?? 'Rol no disponible';
    final state = userProvider.state ?? 'Estado no disponible';
    final phone = userProvider.phoneNumber?.toString() ?? 'Sin teléfono';
    final name = userProvider.name ?? 'Nombre no disponible';

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
        backgroundColor: Constantes.colorPurple,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges(userProvider);
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Constantes.colorPurple,
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
              child:
                  _isEditing
                      ? Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildEditField(
                              'Nombre',
                              _nameController,
                              Icons.person,
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Ingrese un nombre'
                                          : null,
                            ),
                            _buildEditField(
                              'Correo electrónico',
                              _emailController,
                              Icons.email,
                              validator: (value) {
                                if (value!.isEmpty) return 'Ingrese un correo';
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Correo inválido';
                                }
                                return null;
                              },
                            ),
                            _buildEditField(
                              'Teléfono',
                              _phoneController,
                              Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Ingrese un teléfono';
                                if (int.tryParse(value) == null) {
                                  return 'Teléfono inválido';
                                }
                                return null;
                              },
                            ),
                            _buildDropdownField(
                              'Estado',
                              _selectedState,
                              ['available', 'unavailable'],
                              (value) {
                                setState(() {
                                  _selectedState = value;
                                });
                              },
                              Icons.check_circle_outline,
                            ),
                            if (role == 'ADMINISTRADOR')
                              _buildDropdownField(
                                'Rol',
                                _selectedRoleId,
                                _roleMap.keys.toList(),
                                (value) {
                                  setState(() {
                                    _selectedRoleId = value;
                                  });
                                },
                                Icons.badge,
                                displayValue: (id) => _roleMap[id] ?? id,
                              ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          _buildInfoTile('Nombre', name, Icons.person),
                          _buildInfoTile(
                            'Correo electrónico',
                            email,
                            Icons.email,
                          ),
                          _buildInfoTile('Rol de usuario', role, Icons.badge),
                          _buildInfoTile(
                            'Estado',
                            state,
                            Icons.check_circle_outline,
                          ),
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
          iconColor: Constantes.colorPurpleLight,
          containerColor: const Color.fromARGB(18, 0, 0, 0),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: ContainerIcon(
          icon: icon,
          iconColor: Constantes.colorPurpleLight,
          containerColor: const Color.fromARGB(18, 0, 0, 0),
        ),
        title: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
    IconData icon, {
    String Function(String)? displayValue,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: ContainerIcon(
          icon: icon,
          iconColor: Constantes.colorPurpleLight,
          containerColor: const Color.fromARGB(18, 0, 0, 0),
        ),
        title: DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          items:
              options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    displayValue != null ? displayValue(option) : option,
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Seleccione una opción' : null,
        ),
      ),
    );
  }
}
