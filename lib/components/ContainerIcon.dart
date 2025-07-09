import 'package:flutter/material.dart';

class ContainerIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color containerColor;

  const ContainerIcon({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: containerColor,
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}
