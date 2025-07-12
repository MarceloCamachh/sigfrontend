import 'package:flutter/material.dart';

class BottonLoading extends StatelessWidget {
  final Color colorBack;
  final Color colorBackLoading;
  final Color colorFont;
  final String textTitle;
  final String textLoading;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double fontSize;
  final bool isLoading;

  const BottonLoading({
    super.key,
    required this.colorBack,
    required this.colorFont,
    required this.textTitle,
    this.onPressed,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.colorBackLoading,
    required this.textLoading,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width * 0.9,
        height: height,
        decoration: BoxDecoration(
          color: isLoading ? colorBackLoading : colorBack,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child:
              isLoading
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colorFont),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        textLoading,
                        style: TextStyle(
                          color: colorFont,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    textTitle,
                    style: TextStyle(
                      color: colorFont,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
        ),
      ),
    );
  }
}
