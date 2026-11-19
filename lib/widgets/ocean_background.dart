import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// The hero "postcard": a time-of-day sky, a soft sun (or moon) disc and
/// three slow, looping wave layers. Lives inside a rounded card.
class SkyScene extends StatefulWidget {
  const SkyScene({super.key, required this.theme, required this.child});

  final SkyTheme theme;
  final Widget child;

  @override
  State<SkyScene> createState() => _SkySceneState();
}

class _SkySceneState extends State<SkyScene> with SingleTickerProviderStateMixin {
  late final AnimationController _t =
      AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = widget.theme;
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: th.sky,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _ScenePainter(_t, th)),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.anim, this.theme) : super(repaint: anim);
  final Animation<double> anim;
  final SkyTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;

    // Sun / moon: soft halo + disc, drifting a few pixels.
    // Sits in the top-right corner, clear of the gauge.
    final sunCenter = Offset(size.width - 44, 74 + math.sin(t * 2 * math.pi) * 2);
    const r = 15.0;
    canvas.drawCircle(
      sunCenter,
      58,
      Paint()
        ..shader = RadialGradient(colors: [
          theme.sunColor.withValues(alpha: theme.isNight ? .22 : .42),
          theme.sunColor.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: sunCenter, radius: 58)),
    );
    final disc = Path()..addOval(Rect.fromCircle(center: sunCenter, radius: r));
    if (theme.isNight) {
      // True crescent: the disc minus an offset disc (no painted "bite").
      final bite = Path()..addOval(Rect.fromCircle(center: sunCenter + const Offset(6, -4), radius: r * .88));
      canvas.drawPath(Path.combine(PathOperation.difference, disc, bite), Paint()..color = theme.sunColor);
      // A few stars.
      final star = Paint()..color = Colors.white.withValues(alpha: .7);
      for (final (dx, dy, s) in const [(.12, .08, 1.2), (.30, .05, 0.9), (.55, .12, 1.1), (.70, .04, 0.8), (.20, .22, 0.8)]) {
        final twinkle = .5 + .5 * math.sin((t * 4 + dx * 10) * math.pi);
        canvas.drawCircle(Offset(size.width * dx, size.height * dy), s * (0.6 + .4 * twinkle), star);
      }
    } else {
      canvas.drawPath(disc, Paint()..color = theme.sunColor);
    }

    // Waves, back to front.
    final layers = theme.sea;
    for (var i = 0; i < layers.length; i++) {
      final base = size.height * (.70 + i * .085);
      final amp = 4.0 + i * 2.5;
      final len = size.width / (1.3 + i * .6);
      final dir = i.isEven ? 1 : -1;
      final path = Path()..moveTo(0, size.height);
      for (double x = 0; x <= size.width + 3; x += 3) {
        final y = base +
            math.sin(x / len * 2 * math.pi + dir * t * 2 * math.pi * (i + 1) + i * 1.7) * amp +
            math.sin(x / (len * .43) * 2 * math.pi - t * 2 * math.pi) * amp * .25;
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = layers[i]);

      // Thin foam highlight on the front waves.
      if (i > 0) {
        final crest = Path();
        for (double x = 0; x <= size.width + 3; x += 3) {
          final y = base +
              math.sin(x / len * 2 * math.pi + dir * t * 2 * math.pi * (i + 1) + i * 1.7) * amp +
              math.sin(x / (len * .43) * 2 * math.pi - t * 2 * math.pi) * amp * .25;
          x == 0 ? crest.moveTo(x, y) : crest.lineTo(x, y);
        }
        canvas.drawPath(
          crest,
          Paint()
            ..color = Colors.white.withValues(alpha: .18)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.theme != theme;
}
