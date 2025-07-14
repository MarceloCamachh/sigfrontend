import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sigfrontend/components/BottonLoading.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/models/registerData.dart';
import 'package:sigfrontend/services/auth.services.dart';
import 'package:sigfrontend/pages/home.dart'; // Cambia a tu página de destino real
import 'package:sigfrontend/components/FadeThroughPageRoute.dart';
import 'package:sigfrontend/services/deliveryvehiclesServices.dart';

class RegistroPasoFinalPage extends StatefulWidget {
  final RegisterData data;

  const RegistroPasoFinalPage({super.key, required this.data});

  @override
  State<RegistroPasoFinalPage> createState() => _RegistroPasoFinalPageState();
}

class _RegistroPasoFinalPageState extends State<RegistroPasoFinalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Iniciando proceso de registro...'); // Debug 1

      widget.data.email = _emailController.text;
      widget.data.password = _passController.text;
      widget.data.phoneNumber = int.parse(_telefonoController.text);

      print('Datos preparados para registro de usuario...'); // Debug 2

      // 👤 Registrar usuario
      final user = await AutenticacionServices().registerUsuario(
        email: widget.data.email,
        password: widget.data.password,
        name: '${widget.data.name} ${widget.data.lastName}',
        phoneNumber: widget.data.phoneNumber,
      );

      print('Usuario registrado: ${jsonEncode(user)}'); // Debug 3

      final userId = user?['id'] ?? user?['user']?['id'];
      if (userId == null)
        throw Exception("No se pudo obtener el ID del usuario");

      print('ID de usuario obtenido: $userId'); // Debug 4

      // 🔐 Login automático
      print('Iniciando proceso de login...'); // Debug 5
      final loginResponse = await AutenticacionServices().loginUsuario(
        email: widget.data.email,
        password: widget.data.password,
      );

      print(
        'Respuesta de login completa: ${jsonEncode(loginResponse)}',
      ); // Debug 6

      // 🔐 Obtener token desde access_token (corregido)
      final token = loginResponse?['access_token'];
      if (token == null) {
        print('ERROR: Login response completo: ${jsonEncode(loginResponse)}');
        throw Exception("Login exitoso pero no se encontró access_token");
      }

      print('Token obtenido con éxito: $token'); // Debug 7

      // 🚗 Registrar vehículo si no es bici
      if (widget.data.transport != VehicleType.bike) {
        print('Preparando registro de vehículo...'); // Debug 8
        await DeliveryVehicleService().registerVehicle(
          licensePlate: widget.data.licensePlate!,
          typeVehicle: widget.data.transport!.name,
          capacity: widget.data.capacity!,
          userId: userId,
          token: token,
        );
        print('Vehículo registrado con éxito'); // Debug 9
      }

      // ✅ Redirigir a Home si todo sale bien
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          FadeThroughPageRoute(page: const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('ERROR CAPTURADO: $e'); // Debug 10
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrarse: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Registro Paso Final',
        title2: '',
        color: Colors.blueAccent,
        icon: Icons.app_registration_rounded,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Crea tu cuenta",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (!value.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (value) {
                  if (value == null || value.length < 6)
                    return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Número inválido';
                  return null;
                },
              ),
              const Spacer(),
              BottonLoading(
                width: width * 0.9,
                height: 55,
                fontSize: 20,
                colorBack: Colors.black,
                colorFont: Colors.white,
                colorBackLoading: Colors.grey,
                textTitle: 'Registrar',
                textLoading: 'Registrando...',
                isLoading: _isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registrar();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
