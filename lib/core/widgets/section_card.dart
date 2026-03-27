import 'package:flutter/material.dart';

import '../../app/theme.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.ps;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [BoxShadow(blurRadius: 24, offset: const Offset(0, 12), color: colors.cardShadow)],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
