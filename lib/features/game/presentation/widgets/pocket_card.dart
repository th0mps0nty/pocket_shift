import 'package:flutter/material.dart';

import '../../../settings/domain/coin_style.dart';
import 'coin_visual.dart';

class PocketCard extends StatelessWidget {
  const PocketCard({
    super.key,
    required this.label,
    required this.count,
    required this.helper,
    required this.coinStyle,
    required this.side,
  });

  final String label;
  final int count;
  final String helper;
  final CoinStyle coinStyle;
  final PocketSide side;

  @override
  Widget build(BuildContext context) {
    final isLeft = side == PocketSide.left;

    return Semantics(
      label: '$label has $count ${coinStyle.label.toLowerCase()} coins',
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF436B99),
              Color(0xFF284D78),
              Color(0xFF1A3454),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 34 : 24),
            topRight: Radius.circular(isLeft ? 24 : 34),
            bottomLeft: const Radius.circular(34),
            bottomRight: const Radius.circular(34),
          ),
          border: Border.all(
            color: const Color(0xFF8CB2D6).withValues(alpha: 0.26),
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 20,
              offset: Offset(0, 14),
              color: Color(0x26122A46),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PocketPainter(side: side),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 82,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(
                        count,
                        (index) => CoinVisual(
                          style: coinStyle,
                          size: 18,
                          semanticLabel: null,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  helper,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                        height: 1.28,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum PocketSide { left, right }

class _PocketPainter extends CustomPainter {
  const _PocketPainter({required this.side});

  final PocketSide side;

  @override
  void paint(Canvas canvas, Size size) {
    final weavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (var x = -24.0; x < size.width + 24; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x + 12, size.height), weavePaint);
      canvas.drawLine(Offset(x + 10, 0), Offset(x - 2, size.height), weavePaint);
    }

    final fadePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x22FFFFFF), Color(0x00000000)],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(28)),
      fadePaint,
    );

    final stitchPaint = Paint()
      ..color = const Color(0xFFF3D4A5).withValues(alpha: 0.9)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rimPath = Path()
      ..moveTo(26, 58)
      ..quadraticBezierTo(
        size.width * (side == PocketSide.left ? 0.28 : 0.22),
        28,
        size.width * 0.5,
        40,
      )
      ..quadraticBezierTo(
        size.width * (side == PocketSide.left ? 0.78 : 0.72),
        28,
        size.width - 26,
        58,
      );

    for (final metric in rimPath.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + 10).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), stitchPaint);
        distance += 16;
      }
    }

    final sidePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final leftInset = side == PocketSide.left ? 16.0 : 22.0;
    final rightInset = side == PocketSide.left ? 22.0 : 16.0;
    canvas.drawLine(
      Offset(leftInset, 74),
      Offset(leftInset, size.height - 28),
      sidePaint,
    );
    canvas.drawLine(
      Offset(size.width - rightInset, 74),
      Offset(size.width - rightInset, size.height - 28),
      sidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PocketPainter oldDelegate) {
    return oldDelegate.side != side;
  }
}
