import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../settings/domain/coin_style.dart';
import 'coin_visual.dart';

class CoinTransferOverlay extends StatefulWidget {
  const CoinTransferOverlay({
    super.key,
    required this.trigger,
    required this.reducedMotion,
    required this.coinStyle,
  });

  final int trigger;
  final bool reducedMotion;
  final CoinStyle coinStyle;

  @override
  State<CoinTransferOverlay> createState() => _CoinTransferOverlayState();
}

class _CoinTransferOverlayState extends State<CoinTransferOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.reducedMotion
          ? const Duration(milliseconds: 220)
          : const Duration(milliseconds: 540),
    );
    if (widget.trigger > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant CoinTransferOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) {
      _controller.duration = widget.reducedMotion
          ? const Duration(milliseconds: 220)
          : const Duration(milliseconds: 540);
    }
    if (oldWidget.trigger != widget.trigger && widget.trigger > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isDismissed && widget.trigger == 0) {
            return const SizedBox.shrink();
          }

          final t = Curves.easeInOutCubic.transform(_controller.value);
          final opacity = t < 0.08
              ? t / 0.08
              : t > 0.94
                  ? (1 - t) / 0.06
                  : 1.0;
          final horizontal = lerpDouble(-126, 126, t) ?? 0;
          final lift = widget.reducedMotion ? 10.0 : math.sin(t * math.pi) * 48;
          final drop = widget.reducedMotion ? 0.0 : math.max(0, t - 0.82) * 48;
          final scaleY = widget.reducedMotion
              ? 1.0
              : (t > 0.84 ? 1 - ((t - 0.84) / 0.16) * 0.18 : 1.0);
          final spin = widget.reducedMotion ? 0.0 : t * math.pi * 4;

          return Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity.clamp(0, 1),
              child: Transform.translate(
                offset: Offset(horizontal, -lift + drop + 8),
                  child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0018)
                    ..rotateY(spin)
                    ..scaleByDouble(1.0, scaleY, 1.0, 1.0),
                  child: CoinVisual(
                    style: widget.coinStyle,
                    size: 58,
                    semanticLabel: null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
