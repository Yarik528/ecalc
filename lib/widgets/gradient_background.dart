import 'package:flutter/material.dart';
import 'noise_painter.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const GradientBackground({
    super.key,
    required this.child,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isDark
        ? [const Color(0xFF1C1C24), const Color(0xFF0E0E12)]
        : [const Color(0xFFE8E8ED), const Color(0xFFD1D1D6)];

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: NoisePainter())),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}