import 'package:flutter/material.dart';

PageRouteBuilder createSmoothTransitionRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      const begin = Offset(0.0, 0.1);
      const end = Offset.zero;
      final slide = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeOut));
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
      return SlideTransition(
        position: animation.drive(slide),
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}
