import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../settings/domain/coin_style.dart';
import 'coin_visual.dart';

enum PocketBoardLayout { horizontal, vertical }

class CoinTransferOverlay extends StatefulWidget {
  const CoinTransferOverlay({
    super.key,
    required this.trigger,
    required this.reducedMotion,
    required this.coinStyle,
    required this.layout,
  });

  final int trigger;
  final bool reducedMotion;
  final CoinStyle coinStyle;
  final PocketBoardLayout layout;

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
          : const Duration(milliseconds: 560),
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
          : const Duration(milliseconds: 560);
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

          final t = Curves.easeInOutCubicEmphasized.transform(
            _controller.value,
          );
          final opacity = t < 0.08
              ? t / 0.08
              : t > 0.95
              ? (1 - t) / 0.05
              : 1.0;
          final start = widget.layout == PocketBoardLayout.horizontal
              ? const Alignment(-0.69, -0.12)
              : const Alignment(0, -0.58);
          final end = widget.layout == PocketBoardLayout.horizontal
              ? const Alignment(0.68, -0.02)
              : const Alignment(0, 0.48);
          final position = Alignment.lerp(start, end, t) ?? Alignment.center;
          final arcLift = widget.reducedMotion
              ? 8.0
              : math.sin(t * math.pi) *
                    (widget.layout == PocketBoardLayout.horizontal ? 88 : 56);
          final landingSquash = widget.reducedMotion
              ? 1.0
              : t > 0.84
              ? lerpDouble(1.0, 0.88, (t - 0.84) / 0.16) ?? 1.0
              : 1.0;
          final rebound = widget.reducedMotion
              ? 0.0
              : t > 0.88
              ? math.sin((t - 0.88) / 0.12 * math.pi) * 7
              : 0.0;
          final spin = widget.reducedMotion ? 0.0 : t * math.pi * 5.25;
          final shadowOpacity = t > 0.7 ? (t - 0.7) / 0.3 : 0.18;

          return Stack(
            children: [
              Align(
                alignment: end,
                child: Transform.translate(
                  offset: Offset(0, 92),
                  child: Container(
                    width: 68,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.black.withValues(
                        alpha: shadowOpacity * 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: position,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, -arcLift - rebound + 42),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018)
                        ..rotateY(spin)
                        ..scaleByDouble(1.0, landingSquash, 1.0, 1.0),
                      child: CoinVisual(
                        style: widget.coinStyle,
                        size: widget.layout == PocketBoardLayout.horizontal
                            ? 62
                            : 58,
                        semanticLabel: null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
