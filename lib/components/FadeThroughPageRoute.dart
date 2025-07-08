import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeThroughPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      );
}
