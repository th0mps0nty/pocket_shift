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
    this.compact = false,
  });

  final String label;
  final int count;
  final String helper;
  final CoinStyle coinStyle;
  final PocketSide side;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isLeft = side == PocketSide.left;
    final theme = Theme.of(context);

    return Semantics(
      label: '$label has $count ${coinStyle.label.toLowerCase()} coins',
      value: helper,
      child: Container(
        constraints: BoxConstraints(minHeight: compact ? 246 : 286),
        padding: EdgeInsets.fromLTRB(16, compact ? 18 : 20, 16, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLeft
                ? const [
                    Color(0xFF4671A2),
                    Color(0xFF274C76),
                    Color(0xFF1A3658),
                  ]
                : const [
                    Color(0xFF3F6897),
                    Color(0xFF23466E),
                    Color(0xFF17304E),
                  ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 34 : 24),
            topRight: Radius.circular(isLeft ? 24 : 34),
            bottomLeft: const Radius.circular(34),
            bottomRight: const Radius.circular(34),
          ),
          border: Border.all(
            color: const Color(0xFF8CB2D6).withValues(alpha: 0.24),
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 26,
              offset: Offset(0, 16),
              color: Color(0x24112541),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _PocketPainter(side: side)),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 0.92,
                          ),
                        ),
                        Text(
                          'coins',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.76),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: compact ? 16 : 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLeft
                            ? 'Pocket change still with you'
                            : 'Pocket change already noticed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(
                          count,
                          (index) => CoinVisual(
                            style: coinStyle,
                            size: compact ? 18 : 20,
                            semanticLabel: null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 16 : 20),
                Text(
                  helper,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
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
      ..color = Colors.white.withValues(alpha: 0.028)
      ..strokeWidth = 1;
    for (var x = -24.0; x < size.width + 24; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x + 16, size.height), weavePaint);
      canvas.drawLine(
        Offset(x + 12, 0),
        Offset(x - 4, size.height),
        weavePaint,
      );
    }

    final topFade = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x26FFFFFF), Color(0x00000000)],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(30)),
      topFade,
    );

    final hemPaint = Paint()
      ..color = const Color(0xFF6D97C1).withValues(alpha: 0.34)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final hemPath = Path()
      ..moveTo(24, 62)
      ..quadraticBezierTo(size.width * 0.3, 22, size.width * 0.5, 36)
      ..quadraticBezierTo(size.width * 0.7, 22, size.width - 24, 62);
    canvas.drawPath(hemPath, hemPaint);

    final stitchPaint = Paint()
      ..color = const Color(0xFFF2D0A0).withValues(alpha: 0.94)
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final metric in hemPath.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + 10).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), stitchPaint);
        distance += 16;
      }
    }

    final seamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    final leftInset = side == PocketSide.left ? 16.0 : 20.0;
    final rightInset = side == PocketSide.left ? 20.0 : 16.0;
    canvas.drawLine(
      Offset(leftInset, 84),
      Offset(leftInset, size.height - 26),
      seamPaint,
    );
    canvas.drawLine(
      Offset(size.width - rightInset, 84),
      Offset(size.width - rightInset, size.height - 26),
      seamPaint,
    );

    final rivetPaint = Paint()
      ..color = const Color(0xFFE7C48C).withValues(alpha: 0.85);
    canvas.drawCircle(Offset(28, 70), 3.6, rivetPaint);
    canvas.drawCircle(Offset(size.width - 28, 70), 3.6, rivetPaint);
  }

  @override
  bool shouldRepaint(covariant _PocketPainter oldDelegate) {
    return oldDelegate.side != side;
  }
}
