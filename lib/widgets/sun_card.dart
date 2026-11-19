import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/ph_icons.dart';

import '../logic/insights.dart';
import '../models/forecast.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import 'glass_card.dart';

/// Sun path from sunrise to sunset plus UV and sunscreen advice.
class SunCard extends StatelessWidget {
  const SunCard({super.key, required this.day, required this.now});
  final DailySummary day;
  final DateTime? now; // null when not today

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    final total = math.max(1, day.daylight.inMinutes).toDouble();
    final target = now == null ? .5 : (now!.difference(day.sunrise).inMinutes / total).clamp(0.0, 1.0);
    final advice = sunAdvice(day.uvMax);
    final golden = day.sunset.subtract(const Duration(hours: 1));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Sun & UV', icon: PhIcons.sunBold),
          SizedBox(
            height: 96,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(day.date),
              tween: Tween(begin: 0, end: target),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (_, p, __) => CustomPaint(size: Size.infinite, painter: _SunArcPainter(p)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(PhIcons.sunHorizon, 'Sunrise', fmt.format(day.sunrise)),
              _Stat(PhIcons.camera, 'Golden hour', fmt.format(golden)),
              _Stat(PhIcons.moon, 'Sunset', fmt.format(day.sunset)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: Palette.line),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: advice.color.withValues(alpha: .14),
                  border: Border.all(color: advice.color, width: 2),
                ),
                child: Text(day.uvMax.toStringAsFixed(0), style: AppText.display(22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${advice.level} UV · use ${advice.spf}', style: AppText.title(17)),
                    const SizedBox(height: 4),
                    Text(advice.tip, style: AppText.body(14, color: Palette.inkSoft)),
                    if (advice.burnMinutes != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(PhIcons.timer, size: 14, color: Palette.coral),
                          const SizedBox(width: 6),
                          Text('Fair skin burns in ~${advice.burnMinutes} min at peak',
                              style: AppText.body(12, color: Palette.coral, weight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Palette.inkSoft),
                const SizedBox(width: 4),
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: AppText.body(12, color: Palette.inkSoft))),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: AppText.display(18)),
          ],
        ),
      );
}

class _SunArcPainter extends CustomPainter {
  _SunArcPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height - 4;
    final center = Offset(size.width / 2, horizon);
    final rx = size.width / 2 - 14;
    final ry = size.height - 18;
    Offset at(double t) {
      final a = math.pi * (1 - t);
      return center + Offset(math.cos(a) * rx, -math.sin(a) * ry);
    }

    final dash = Paint()
      ..color = Palette.line
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (double t = 0; t < 1; t += .035) {
      canvas.drawLine(at(t), at(math.min(t + .015, 1)), dash);
    }

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (double t = 0; t <= progress; t += .01) {
      final p = at(t);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Palette.sun
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(Offset(0, horizon), Offset(size.width, horizon), Paint()..color = Palette.line..strokeWidth = 1.5);

    final sun = at(progress);
    canvas.drawCircle(sun, 16, Paint()..color = Palette.sun.withValues(alpha: .22));
    canvas.drawCircle(sun, 9, Paint()..color = Palette.sun);
    canvas.drawCircle(sun, 9, Paint()..color = Palette.card..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => old.progress != progress;
}
