import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../theme/ph_icons.dart';

import '../logic/insights.dart';
import '../models/forecast.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import 'glass_card.dart';

/// Tide curve for the day, drawn left-to-right on appear.
class TideCard extends StatelessWidget {
  const TideCard({super.key, required this.hours, required this.now, required this.units});
  final List<HourlyConditions> hours;
  final DateTime? now; // null when not today
  final Units units;

  @override
  Widget build(BuildContext context) {
    final levels = hours.map((h) => h.seaLevel).toList();
    if (levels.whereType<double>().length < 6) return const SizedBox.shrink();
    final events = tideEvents(hours);
    final fmt = DateFormat('HH:mm');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Tides', icon: PhIcons.wavesBold),
          SizedBox(
            height: 120,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(hours.first.time),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeInOutCubic,
              builder: (_, p, __) => CustomPaint(
                size: Size.infinite,
                painter: _TidePainter(levels, p, now == null ? null : now!.hour + now!.minute / 60),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final e in events.take(4))
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(e.isHigh ? PhIcons.arrowUpBold : PhIcons.arrowDownBold,
                              size: 12, color: e.isHigh ? Palette.sea : Palette.inkSoft),
                          const SizedBox(width: 4),
                          Text(e.isHigh ? 'HIGH' : 'LOW', style: AppText.label()),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(fmt.format(e.time), style: AppText.display(18)),
                      Text(units.height(e.height), style: AppText.body(12, color: Palette.inkSoft)),
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

class _TidePainter extends CustomPainter {
  _TidePainter(this.levels, this.progress, this.nowHour);
  final List<double?> levels;
  final double progress;
  final double? nowHour;

  @override
  void paint(Canvas canvas, Size size) {
    final values = levels.whereType<double>();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < .01 ? 1.0 : maxV - minV;
    final n = levels.length;
    final chartH = size.height - 16;

    Offset point(int i) {
      final v = levels[i] ?? minV;
      return Offset(size.width * i / (n - 1), chartH * .92 - (v - minV) / range * chartH * .8);
    }

    // Grid lines every 6 hours.
    final grid = Paint()
      ..color = Palette.line
      ..strokeWidth = 1;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final h in [0, 6, 12, 18]) {
      final x = size.width * h / (n - 1);
      canvas.drawLine(Offset(x, 0), Offset(x, chartH), grid);
      tp.text = TextSpan(text: '${h.toString().padLeft(2, '0')}:00', style: AppText.body(10, color: Palette.inkFaint));
      tp.layout();
      tp.paint(canvas, Offset(x + 3, size.height - tp.height));
    }

    final line = Path();
    for (var i = 0; i < n; i++) {
      final p = point(i);
      if (i == 0) {
        line.moveTo(p.dx, p.dy);
      } else {
        final prev = point(i - 1);
        final mid = (prev.dx + p.dx) / 2;
        line.cubicTo(mid, prev.dy, mid, p.dy, p.dx, p.dy);
      }
    }
    final fill = Path.from(line)
      ..lineTo(size.width, chartH)
      ..lineTo(0, chartH)
      ..close();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.sea.withValues(alpha: .28), Palette.sea.withValues(alpha: .02)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartH)),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = Palette.sea
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    final nh = nowHour;
    if (nh != null && progress >= 1) {
      final x = size.width * nh / (n - 1);
      final i = nh.floor().clamp(0, n - 1);
      final j = (i + 1).clamp(0, n - 1);
      final y = point(i).dy + (point(j).dy - point(i).dy) * (nh - i);
      canvas.drawLine(Offset(x, 0), Offset(x, chartH), Paint()..color = Palette.ink..strokeWidth = 1.2);
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = Palette.card);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Palette.ink);
    }
  }

  @override
  bool shouldRepaint(_TidePainter old) => old.progress != progress || old.nowHour != nowHour;
}
