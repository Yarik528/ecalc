import 'package:flutter/material.dart';

class CalcButton extends StatefulWidget {
  final double width;
  final double height;
  final Gradient gradient;
  final List<BoxShadow> shadows;
  final double borderRadius;
  final VoidCallback onTap;
  final Widget child;

  const CalcButton({
    super.key,
    required this.width,
    required this.height,
    required this.gradient,
    required this.shadows,
    required this.borderRadius,
    required this.onTap,
    required this.child,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.shadows,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}