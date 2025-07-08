import 'package:flutter/material.dart';

class BottonChange extends StatelessWidget {
  final Color colorBack;
  final Color colorFont;
  final String textTile;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double fontSize;

  const BottonChange({
    super.key,
    required this.colorBack,
    required this.colorFont,
    required this.textTile,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorBack,
          side: BorderSide.none,
          shape: const StadiumBorder(),
        ),
        child: Text(
          textTile,
          style: TextStyle(
            fontSize: fontSize,
            color: colorFont,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
