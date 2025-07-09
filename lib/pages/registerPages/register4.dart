import 'package:flutter/material.dart';
import 'package:sigfrontend/components/CustomAppBar.dart';
import 'package:sigfrontend/models/registerData.dart';
import 'package:sigfrontend/pages/registerPages/register5.dart';

class RegistroPaso4Page extends StatefulWidget {
  final RegisterData data;

  const RegistroPaso4Page({super.key, required this.data});

  @override
  State<RegistroPaso4Page> createState() => _RegistroPaso4PageState();
}

class _RegistroPaso4PageState extends State<RegistroPaso4Page> {
  final _formKey = GlobalKey<FormState>();
  String? _ciudadSeleccionada;

  final List<String> _ciudades = [
    'Santa Cruz',
    'La Paz',
    'Cochabamba',
    'Oruro',
    'Tarija',
    'Potosí',
    'Chuquisaca',
    'Beni',
    'Pando',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title1: 'Registro Biciclicleta',
        title2: '',
        icon: Icons.arrow_back_ios_rounded,
        onIconPressed: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "¿En qué ciudad vas a repartir?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ciudad'),
                items:
                    _ciudades.map((ciudad) {
                      return DropdownMenuItem(
                        value: ciudad,
                        child: Text(ciudad),
                      );
                    }).toList(),
                value: _ciudadSeleccionada,
                onChanged: (value) {
                  setState(() {
                    _ciudadSeleccionada = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona una ciudad';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.data.city = _ciudadSeleccionada!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => RegistroPasoFinalPage(data: widget.data),
                      ),
                    );
                  }
                },
                child: const Text('Siguiente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
