import 'package:flutter/material.dart';
import 'package:sigfrontend/components/ContainerIcon.dart';
import 'package:sigfrontend/components/WabeClipper.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title1;
  final String title2;
  final IconData icon;
  final VoidCallback onIconPressed;
  final Color color;

  const CustomAppBar({
    super.key,
    required this.title1,
    required this.title2,
    required this.icon,
    required this.onIconPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: ClipPath(
        clipper: WaveClipper(),
        child: Container(height: double.infinity, color: color),
      ),
      toolbarHeight: 110,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: ContainerIcon(
              icon: Icons.arrow_back_ios_rounded,
              iconColor: Colors.white,
              containerColor: Colors.white30,
            ),
            onPressed: onIconPressed,
          ),
          const SizedBox(width: 8),
          ContainerIcon(
            icon: icon,
            iconColor: Colors.white,
            containerColor: Colors.white10,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title1,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110);
}
