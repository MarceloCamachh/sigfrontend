import 'package:flutter/material.dart';
import 'package:sigfrontend/components/BottonChange.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/models/registerData.dart';
import 'package:sigfrontend/pages/registerPages/register2.dart';

class RegistroPaso1Page extends StatefulWidget {
  const RegistroPaso1Page({super.key});

  @override
  State<RegistroPaso1Page> createState() => _RegistroPaso1PageState();
}

class _RegistroPaso1PageState extends State<RegistroPaso1Page> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Registro Paso 1',
        title2: '',
        color: Colors.blueAccent,
        icon: Icons.app_registration_outlined,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "¿Cómo te llamas?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              buildTextField(
                'Nombre',
                'Ingresa tu nombre',
                _nombreController,
                false,
              ),
              const SizedBox(height: 20),
              buildTextField(
                'Apellido',
                'Ingresa tu apellido',
                _apellidoController,
                false,
              ),
              const Spacer(),
              BottonChange(
                colorBack: Colors.black,
                colorFont: Colors.white,
                textTile: 'siguiente',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final data = RegisterData();
                    data.name = _nombreController.text;
                    data.lastName = _apellidoController.text;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegistroPaso2Page(data: data),
                      ),
                    );
                  }
                },
                width: width * 0.8,
                height: 50,
                fontSize: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }
}

Widget buildTextField(
  String label,
  String hint,
  TextEditingController controller,
  bool isPassword,
) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color.fromARGB(255, 174, 191, 200)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromARGB(255, 174, 191, 200)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    ),
    obscureText: isPassword,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Este campo no puede estar vacío';
      }
      return null;
    },
  );
}
