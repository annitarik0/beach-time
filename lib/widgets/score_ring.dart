import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/typography.dart';

/// 270° gauge that sweeps and counts up whenever [score] changes.
/// Drawn in white so it sits on the sky postcard.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    required this.color,
    this.size = 168,
    this.caption = 'out of 100',
  });

  final int score;
  final Color color;
  final double size;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // begin 0 = count up on first appear; later changes animate from the current value.
      tween: Tween(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutQuart,
      builder: (context, value, _) {
        return SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _RingPainter(value / 100, color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value.round().toString(),
                      style: AppText.display(size * .36, color: Colors.white)),
                  Text(caption,
                      style: AppText.body(size * .075,
                          color: Colors.white.withValues(alpha: .75), weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color);
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .055;
    final rect = (Offset.zero & size).deflate(stroke / 2 + 2);
    const start = math.pi * .75;
    const sweep = math.pi * 1.5;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    canvas.drawArc(rect, start, sweep, false, base..color = Colors.white.withValues(alpha: .22));

    // Tick marks every 10 points.
    final r = rect.width / 2;
    final tick = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..strokeWidth = 1.2;
    for (var i = 0; i <= 10; i++) {
      final a = start + sweep * i / 10;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(rect.center + dir * (r - stroke * 1.4), rect.center + dir * (r - stroke * 1.9), tick);
    }

    if (progress <= 0) return;
    canvas.drawArc(rect, start, sweep * progress, false, base..color = Colors.white);

    final a = start + sweep * progress;
    final tip = rect.center + Offset(math.cos(a), math.sin(a)) * r;
    canvas.drawCircle(tip, stroke * .95, Paint()..color = Colors.white);
    canvas.drawCircle(tip, stroke * .55, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}
