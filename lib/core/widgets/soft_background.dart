import 'package:flutter/material.dart';

import '../../app/theme.dart';

class SoftBackground extends StatelessWidget {
  const SoftBackground({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 12)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.ps;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors.softGradientColors,
        ),
      ),
      child: SafeArea(
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
