import 'package:flutter/material.dart';

class SoftBackground extends StatelessWidget {
  const SoftBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 12),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9F3E7), Color(0xFFE9F0E8), Color(0xFFF5EDE4)],
        ),
      ),
      child: SafeArea(
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
