import 'package:flutter/material.dart';

class DeliveryPerson {
  final String id;
  final String name;

  DeliveryPerson({required this.id, required this.name});
}

class CustomDeliveryDropdown extends StatelessWidget {
  final String? selectedValue;
  final List<DeliveryPerson> repartidores;
  final String labelText;
  final String hintText;
  final ValueChanged<String?> onChanged;

  const CustomDeliveryDropdown({
    super.key,
    required this.selectedValue,
    required this.repartidores,
    this.labelText = 'Asignar repartidor',
    this.hintText = 'Selecciona un repartidor',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        prefixIcon: const Icon(Icons.delivery_dining, color: Colors.blueGrey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      value: selectedValue,
      items:
          repartidores.map<DropdownMenuItem<String>>((repartidor) {
            return DropdownMenuItem(
              value: repartidor.id,
              child: Row(
                // Usamos un Row para colocar un icono y el texto
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Colors.blueGrey,
                    size: 20,
                  ), // Icono de persona
                  const SizedBox(
                    width: 10,
                  ), // Espacio entre el icono y el texto
                  Expanded(
                    // Envuelve el texto en Expanded para manejar el desbordamiento
                    child: Text(
                      repartidor.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Para manejar nombres largos
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blueGrey),
    );
  }
}
