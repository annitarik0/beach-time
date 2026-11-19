import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/ph_icons.dart';

import '../logic/beach_score.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';

/// Arrow pointing where the wind (or swell) is going, Windy-style.
/// [fromDegrees] is the meteorological "coming from" direction.
class DirectionArrow extends StatelessWidget {
  const DirectionArrow({super.key, required this.fromDegrees, this.size = 14, this.color = Palette.inkSoft});
  final int fromDegrees;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: (fromDegrees + 180) % 360 * math.pi / 180),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (_, angle, __) => Transform.rotate(
        angle: angle,
        child: Icon(PhIcons.navigationArrowFill, size: size, color: color),
      ),
    );
  }
}

/// Coloured rating chip: EPIC / GOOD / FAIR / POOR.
class RatingChip extends StatelessWidget {
  const RatingChip({super.key, required this.score, this.onDark = false});
  final int score;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = Palette.score(score);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: onDark ? Colors.white : c.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(BeachScorer.rating(score),
              style: AppText.label(color: onDark ? Palette.ink : Palette.ink).copyWith(fontSize: 10.5)),
        ],
      ),
    );
  }
}

/// Thin animated bar on a sunk track.
class ValueBar extends StatelessWidget {
  const ValueBar({super.key, required this.value, required this.color, this.height = 8, this.delay = 0});
  final double value; // 0..1
  final Color color;
  final double height;
  final int delay; // extra ms

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: Palette.sunk,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0)),
          duration: Duration(milliseconds: 800 + delay),
          curve: Curves.easeOutQuart,
          builder: (_, v, __) => FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
            ),
          ),
        ),
      ),
    );
  }
}
