import 'package:flutter/material.dart';

import '../../../settings/domain/coin_style.dart';

class CoinVisual extends StatelessWidget {
  const CoinVisual({
    super.key,
    required this.style,
    this.size = 28,
    this.semanticLabel,
  });

  final CoinStyle style;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: style.gradientColors,
          ),
          border: Border.all(
            color: style.rimColor.withValues(alpha: 0.9),
            width: size * 0.08,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: size * 0.28,
              offset: Offset(0, size * 0.12),
              color: style.gradientColors.last.withValues(alpha: 0.24),
            ),
          ],
        ),
        child: Center(
          child: Text(
            style.shortLabel,
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w900,
              color: style.rimColor.withValues(alpha: 0.95),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
